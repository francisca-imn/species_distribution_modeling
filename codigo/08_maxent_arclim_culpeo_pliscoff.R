
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
presence <- read.csv("data/especies/Culpeo.csv")                                                 # Cargar puntos de presencia

presence$Especie <- NULL #Deja solo columna de lon y lat, opcional



# ejecutar maxent ---------------------------------------------------------
model <- maxent(env_layers_actual, presence)

# predicción capas actuales -----------------------------------------------
pred <- predict(model, env_layers_actual) 
plot(pred, main = "Idoneidad del hábitat - Maxent")                            #visualizar
writeRaster(pred, "maxent_culpeo.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# comparación con mapa histórico arclim -----------------------------------
arclim_map <- rast("data/arclim/lycalopex_culpaeus_historico.tif")
maxent_map <- rast("maxent_culpeo.tif")

# Verificar la compatibilidad
ext(maxent_map) == ext(arclim_map) # Extensión geográfica
res(maxent_map) == res(arclim_map) # Resolución
crs(maxent_map) == crs(arclim_map) # Sistema de coordenadas

# Si no coinciden, puedes reescalar o reproyectar
arclim_map <- resample(arclim_map, maxent_map, method = "bilinear")

# Crear un mapa combinado
par(mfrow = c(1, 2))
plot(maxent_map, main = "Mapa MAXENT culpeo")
plot(arclim_map, main = "Mapa ARClim lycalopex_culpaeus")

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