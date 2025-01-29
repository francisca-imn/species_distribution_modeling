library(terra)
library(sp)
library(dismo)
library(tidyverse)
library(rJava)
library(raster)

# Arreglando datos de entrada ---------------------------------------------
capas_present_raster <- raster::stack(capas_present) # Convertir SpatRaster a RasterStack (para que lo acepte maxent)
capas_future_raster <- raster::stack(capas_future)

data_ocurrencias_filtered <- data_ocurrencias_filtered %>%  # Asegurar que data_ocurrencias_filtered sea un data.frame con solo coordenadas
  select(decimalLongitude, decimalLatitude) %>%  
  as.data.frame()

# 📌 Ejecutar Maxent ------------------------------------------------------
model <- maxent(capas_present_raster, data_ocurrencias_filtered)

par(mfcol = c(1, 2))  # 1 fila, 2 columnas, para graficar
pred_present <- predict(model, capas_present_raster) 
pred_future <- predict(model, capas_future_raster)

# Valos promedios de ocurrencia -------------------------------------------
prob_present_mean <- cellStats(pred_present, stat = "mean", na.rm = TRUE)
prob_future_mean <- cellStats(pred_future, stat = "mean", na.rm = TRUE)


# Visualizar --------------------------------------------------------------
plot(pred_present, main = "Probabilidad de ocurrencia \nLycalopex culpaeus 1980-2010",
     xlim = c(-75, -65), ylim = c(-56, -17), asp=1)
mtext(paste("Promedio:", round(prob_present_mean, 3)), side = 1, line = 3, cex = 1)

plot(pred_future, main = "Probabilidad de ocurrencia \nLycalopex culpaeus 2035-2065",
     xlim = c(-75, -65), ylim = c(-56, -17), asp=1)
mtext(paste("Promedio:", round(prob_future_mean, 3)), side = 1, line = 3, cex = 1)

# Respecto al modelo: -----------------------------------------------------
model@results

#Área bajo la curva
auc_value <- model@results["Training.AUC", ]
print(paste("AUC del modelo:", auc_value))

#Contibución variables ambientales
contribucion <- model@results[grep("contribution", rownames(model@results)), ]
print(contribucion)
response(model)


# Escenario delta y guardar capas -----------------------------------------
#difference <- future_pred - pred 
#plot(difference, main = "Cambio en idoneidad (Futuro - Actual)") 
#writeRaster(difference, "delta.tif", format = "GTiff", overwrite = TRUE)
#writeRaster(pred, "idoneidad_actual.tif", format = "GTiff", overwrite = TRUE)  #guardar capa
#writeRaster(future_pred, "idoneidad_futura.tif", format = "GTiff", overwrite = TRUE)  #guardar capa




