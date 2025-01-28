# arreglando java -----------------------------------------------
Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk-23") # sólo si hubo problemas con java (como yo)

# cargar librerías --------------------------------------------------------
library(terra)
library(sp)
library(dismo)
library(tidyverse)
library(rJava)

# cargar datos ------------------------------------------------------------
env_layers_actual <- stack(list.files("data/actual", pattern = ".tif$", full.names = TRUE))    #capas climáticas actuales
env_layers_future <- stack(list.files("data/future_85", pattern = ".tif$", full.names = TRUE)) #capas climáticas futuras
presence <- read.csv("data/especies/Degu.csv")                                                 # Cargar puntos de presencia

presence <- presence %>% select(-Especie)                                                      #Deja solo columna de lon y lat, opcional

# ejecutar maxent ---------------------------------------------------------
model <- maxent(env_layers_actual, presence)

# predicción capas actuales -----------------------------------------------
pred <- predict(model, env_layers_actual) 
plot(pred, main = "Idoneidad del hábitat - Maxent")                            #visualizar
writeRaster(pred, "idoneidad_actual.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# predicción capas futuras ------------------------------------------------
future_pred <- predict(model, env_layers_future) 
plot(future_pred, main = "Proyección futura - Idoneidad del hábitat")                 #visualizar
writeRaster(future_pred, "idoneidad_futura.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# delta entre escenarios --------------------------------------------------
difference <- future_pred - pred 
plot(difference, main = "Cambio en idoneidad (Futuro - Actual)") 
writeRaster(difference, "delta.tif", format = "GTiff", overwrite = TRUE)

# ESTADÍSTICAS ------------------------------------------------------------
model@results

#Área bajo la curva
auc_value <- model@results["Training.AUC", ]
print(paste("AUC del modelo:", auc_value))

#Contibución variables ambientales
contribucion <- model@results[grep("contribution", rownames(model@results)), ]
print(contribucion)
response(model)

#Idoneidad de área**
umbral <- 0.5  # ajustable
alta_idoneidad_actual <- pred > umbral
alta_idoneidad_futura <- future_pred > umbral

area_actual <- cellStats(alta_idoneidad_actual, sum) / ncell(pred) * 100
area_futura <- cellStats(alta_idoneidad_futura, sum) / ncell(future_pred) * 100

print(paste("Área con alta idoneidad actual (%):", round(area_actual, 2)))
print(paste("Área con alta idoneidad futura (%):", round(area_futura, 2)))





# https://rspatial.org/raster/sdm/ 
