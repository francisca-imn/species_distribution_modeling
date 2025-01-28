# Crear el modelo Bioclim
bioclim_model <- bioclim(env_layers_actual, presence)

# Predecir idoneidad
bioclim_pred <- predict(bioclim_model, env_layers_actual)

# Visualizar el mapa
plot(bioclim_pred, main = "Modelo Bioclim")

# CAPAS FUTURAS -----------------------------------------------------------

# Cargar las capas climáticas futuras
env_layers_future <- stack(list.files("data/future", pattern = ".tif$", full.names = TRUE)) 

# Predecir idoneidad en el escenario futuro
bioclim_pred_future <- predict(bioclim_model, env_layers_future)

# Visualizar el mapa proyectado
plot(bioclim_pred_future, main = "Bioclim - Escenario Futuro")

# ANALIZAR RESULTADOS -----------------------------------------------------

summary(values(bioclim_pred_future))  # Resumen estadístico del mapa futuro

#área alta idoneidad
umbral <- 0.5
alta_idoneidad_bioclim <- bioclim_pred_future > umbral

# Proporción del área con alta idoneidad
area_alta_bioclim <- cellStats(alta_idoneidad_bioclim, sum) / ncell(bioclim_pred_future) * 100
print(paste("Porcentaje de área con alta idoneidad:", round(area_alta_bioclim, 2), "%"))

# COMPARAR CON FUTURO -----------------------------------------------------

# Calcular la diferencia entre mapas
cambio <- bioclim_pred_future - bioclim_pred

# Visualizar los cambios
plot(cambio, main = "Cambio en Idoneidad (Futuro - Actual)")

# GUARDAR RESULTADOS ------------------------------------------------------

# Guardar el mapa futuro
writeRaster(bioclim_pred_future, "bioclim_futuro.tif", format = "GTiff", overwrite = TRUE)

# Guardar el cambio
writeRaster(cambio, "bioclim_cambio.tif", format = "GTiff", overwrite = TRUE)

