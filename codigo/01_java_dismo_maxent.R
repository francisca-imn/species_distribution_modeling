# https://rspatial.org/raster/sdm/ 

library(terra)
library(sp)
library(dismo)
library(tidyverse)
library(rJava)

# EJEMPLO BD CLIMA ACTUAL -------------------------------------------------
# Cargar datos
env_layers_actual <- stack(list.files("data/actual", pattern = ".tif$", full.names = TRUE))

# Cargar puntos de presencia
presence <- read.csv("data/Especies/Degu.csv") # Archivo con coordenadas
presence <- presence %>% select(-Especie)

# Ejecutar Maxent
model <- maxent(env_layers_actual, presence)

# arreglando el error -----------------------------------------------------
# Visualizar una de las capas
plot(env_layers_actual[[1]]) # Muestra la primera capa
points(presence, col = "red") # Agrega los puntos de presencia

install.packages("rJava")
maxent()

# arreglando mierda de java -----------------------------------------------

Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk-23") # Reemplaza con tu ruta
library(rJava)

# ok ahora creo que funcionó maxent ---------------------------------------
pred <- predict(model, env_layers_actual) # Predicción en las capas ambientales
plot(pred, main = "Idoneidad del hábitat - Maxent") # Visualizar el mapa

# EJEMPLO BD CLIMA FUTURO 8.5 ---------------------------------------------

env_layers_future <- stack(list.files("data/future_85", pattern = ".tif$", full.names = TRUE))
future_pred <- predict(model, env_layers_future) # Proyectar al escenario futuro
plot(future_pred, main = "Proyección futura - Idoneidad del hábitat") # Visualizar el mapa de idoneidad futura

writeRaster(future_pred, "idoneidad_futura.tif", format = "GTiff", overwrite = TRUE) #guardar mapa

# DIFERENCIA DE ESCENARIOS ------------------------------------------------
difference <- future_pred - pred # Diferencia entre escenarios
plot(difference, main = "Cambio en idoneidad (Futuro - Actual)") # Visualizar la diferencia

# ESTADÍSTICAS ------------------------------------------------------------
#Maxent calcula métricas estándar, como el AUC y la contribución de variables

model@results # Resumen del modelo calibrado

#Estadísticas del futuro
summary(values(future_pred))  # Estadísticas básicas: Muestra media, mediana, etc.

#Idoneidad?
# Calcular área de alta idoneidad
umbral <- 0.5  # Umbral de idoneidad
alta_idoneidad <- future_pred > umbral

# Proporción del área con alta idoneidad
area_alta <- cellStats(alta_idoneidad, sum) / ncell(future_pred) * 100
print(paste("Porcentaje de área con alta idoneidad:", round(area_alta, 2), "%"))

#del cambio
summary(values(difference))  # Media, máximo, mínimo del cambio

response(model) #curvas maxent


