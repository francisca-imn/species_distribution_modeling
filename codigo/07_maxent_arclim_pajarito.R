
# cargar librerías --------------------------------------------------------
library(terra)
library(sp)
library(dismo)
library(tidyverse)
library(rJava)
library(caret)

# cargar datos ------------------------------------------------------------
env_layers_actual <- stack(list.files("data/actual", pattern = ".tif$", full.names = TRUE))    #capas climáticas actuales
env_layers_future <- stack(list.files("data/future_85", pattern = ".tif$", full.names = TRUE)) #capas climáticas futuras

data <- read.csv("data/especies/enicognathus_leptorhynchus.csv", sep = "\t", stringsAsFactors = FALSE) # descargado de GBIF
presence <- data[, c("decimalLongitude", "decimalLatitude")] # Extraer las columnas de longitud y latitud
                                          # Cargar puntos de presencia

# ejecutar maxent ---------------------------------------------------------
model <- maxent(env_layers_actual, presence)

# predicción capas actuales -----------------------------------------------
pred <- predict(model, env_layers_actual) 
plot(pred, main = "Idoneidad del hábitat - Maxent")                            #visualizar
writeRaster(pred, "maxent_enicognathus_leptorhynnchus.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# comparación con mapa histórico arclim -----------------------------------
arclim_map <- rast("data/arclim/enicognathus_leptorhynchus_historico.tif")
maxent_map <- rast("maxent_enicognathus_leptorhynnchus.tif")

# Verificar la compatibilidad
ext(maxent_map) == ext(arclim_map) # Extensión geográfica
res(maxent_map) == res(arclim_map) # Resolución
crs(maxent_map) == crs(arclim_map) # Sistema de coordenadas

# Si no coinciden, puedes reescalar o reproyectar
arclim_map <- resample(arclim_map, maxent_map, method = "bilinear")

# Crear un mapa combinado
par(mfrow = c(1, 2))
plot(maxent_map, main = "Mapa MAXENT (dismo)")
plot(arclim_map, main = "Mapa ARClim")

# índice de correlación de pearson o spearman
cor(values(maxent_map), values(arclim_map), method = "pearson") #no funciona

#ahora otra cosa!!
# Crear mapas binarios con un umbral (ajusta según corresponda)
maxent_pa <- maxent_map > 0.5
arclim_pa <- arclim_map > 0.5

# Convertir los mapas binarizados a vectores
maxent_values <- values(maxent_pa)
arclim_values <- values(arclim_pa)

# Remover valores NA para evitar problemas en la comparación
valid_indices <- !is.na(maxent_values) & !is.na(arclim_values)
maxent_values <- maxent_values[valid_indices]
arclim_values <- arclim_values[valid_indices]

# Crear la tabla cruzada
confusion_matrix <- table(maxent_values, arclim_values)

# Mostrar la tabla cruzada
print(confusion_matrix)

# Calcular índice Kappa usando caret
# Calcular matriz de confusión con caret
conf_matrix <- confusionMatrix(confusion_matrix)

# Mostrar el índice de Kappa
print(conf_matrix$overall["Kappa"])

# Crear mapa de comparación
comparison_map <- (maxent_pa * 2) + arclim_pa

# Colores para las categorías
# 0 = TN (blanco), 1 = FN (rojo), 2 = FP (azul), 3 = TP (verde)
plot(comparison_map, main = "Mapa de Comparación", 
     col = c("white", "red", "blue", "green"),
     legend.args = list(text = c("TN", "FN", "FP", "TP")))

# predicción capas futuras ------------------------------------------------
future_pred <- predict(model, env_layers_future) 
plot(future_pred, main = "Proyección futura - Idoneidad del hábitat")                 #visualizar
writeRaster(future_pred, "maxent_enicognathus_leptorhynnchus_futuro.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# delta entre escenarios --------------------------------------------------
difference <- future_pred - pred 
plot(difference, main = "Cambio en idoneidad (Futuro - Actual)") 
writeRaster(difference, "maxent_enicognathus_leptorhynnchus_delta.tif", format = "GTiff", overwrite = TRUE)

# comparación con mapa histórico arclim -----------------------------------
arclim_future_map <- rast("data/arclim/enicognathus_leptorhynchus_futuro.tif")
maxent_future_map <- rast("maxent_enicognathus_leptorhynnchus_futuro.tif")

# Verificar la compatibilidad
ext(maxent_future_map) == ext(arclim_future_map) # Extensión geográfica
res(maxent_future_map) == res(arclim_future_map) # Resolución
crs(maxent_future_map) == crs(arclim_future_map) # Sistema de coordenadas

# Si no coinciden, puedes reescalar o reproyectar
arclim_future_map <- resample(arclim_future_map, maxent_future_map, method = "bilinear")

# Crear un mapa combinado
par(mfrow = c(1, 2))
plot(maxent_future_map, main = "Mapa MAXENT (dismo) 2035-2065")
plot(arclim_future_map, main = "Mapa ARClim 2035-2065")

#ahora otra cosa!!
# Crear mapas binarios con un umbral (ajusta según corresponda)
maxent_pa_future <- maxent_future_map > 0.5
arclim_pa_future <- arclim_future_map > 0.5

# Convertir los mapas binarizados a vectores
maxent_values_future <- values(maxent_pa_future)
arclim_values_future <- values(arclim_pa_future)

# Remover valores NA para evitar problemas en la comparación
valid_indices_future <- !is.na(maxent_values_future) & !is.na(arclim_values_future)
maxent_values_future <- maxent_values[valid_indices_future]
arclim_values_future <- arclim_values[valid_indices_future]

# Crear la tabla cruzada
confusion_matrix_future <- table(maxent_values_future, arclim_values_future)

# Mostrar la tabla cruzada
print(confusion_matrix_future)

# Calcular índice Kappa usando caret
# Calcular matriz de confusión con caret
conf_matrix_future <- confusionMatrix(confusion_matrix_future)

# Mostrar el índice de Kappa
print(conf_matrix_future$overall["Kappa"])

# Crear mapa de comparación
comparison_map_future <- (maxent_pa_future * 2) + arclim_pa_future

# Colores para las categorías
# 0 = TN (blanco), 1 = FN (rojo), 2 = FP (azul), 3 = TP (verde)
par(mfrow = c(1, 1))
plot(comparison_map_future, main = "Mapa de Comparación", 
     col = c("white", "red", "blue", "green"),
     legend.args = list(text = c("TN", "FN", "FP", "TP")))























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
