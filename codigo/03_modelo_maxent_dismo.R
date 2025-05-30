library(sp)
library(dismo)
library(raster)

# Arreglando datos de entrada ---------------------------------------------
capas_present_raster <- raster::stack(capas_present) # Convertir SpatRaster a RasterStack (para que lo acepte maxent)
capas_future_raster <- raster::stack(capas_future)

data_ocurrencias_filtered <- data_ocurrencias_filtered %>%  # Asegurar que data_ocurrencias_filtered sea un data.frame con solo coordenadas
  select(decimalLongitude, decimalLatitude) %>%  
  as.data.frame()

# 📌 Ejecutar Maxent ------------------------------------------------------
model <- maxent(capas_present_raster, data_ocurrencias_filtered)

pred_present <- predict(model, capas_present_raster) 
pred_future <- predict(model, capas_future_raster)

# Valos promedios de ocurrencia -------------------------------------------
prob_present_mean <- cellStats(pred_present, stat = "mean", na.rm = TRUE)
prob_future_mean <- cellStats(pred_future, stat = "mean", na.rm = TRUE)


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
#pred_delta <- pred_future - pred_present
#prob_delta_mean <- cellStats(pred_delta, stat = "mean", na.rm = TRUE)

#par(mfcol = c(1, 1))
#plot(pred_delta, main = "Probabilidad de ocurrencia \nLycalopex culpaeus DELTA",
#     xlim = c(-75, -65), ylim = c(-56, -17), asp=1)
#mtext(paste("Promedio:", round(prob_delta_mean, 3)), side = 1, line = 3, cex = 1)