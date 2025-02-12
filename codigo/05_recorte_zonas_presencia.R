# PRESENT TIME (1980-2010) -------------------------------------------------------------
# Transformar los mapas a binario con umbral de 0.1
arclim_binary <- arclim_present >= 0.1
pred_binary <- pred_present_resampled >= 0.1

# Encontrar los píxeles con valor 1 en cada mapa
arclim_cells <- which(arclim_binary[] == 1)
pred_cells <- which(pred_binary[] == 1)

# Obtener coordenadas de los píxeles con valor 1
coords_arclim <- xyFromCell(arclim_binary, arclim_cells)
coords_pred <- xyFromCell(pred_binary, pred_cells)

# Encontrar los extremos NORTE y SUR de CADA MAPA
extremes_arclim <- list(
  norte = coords_arclim[which.max(coords_arclim[,2]),],  # Latitud máxima
  sur = coords_arclim[which.min(coords_arclim[,2]),]     # Latitud mínima
)

extremes_pred <- list(
  norte = coords_pred[which.max(coords_pred[,2]),],  # Latitud máxima
  sur = coords_pred[which.min(coords_pred[,2]),]     # Latitud mínima
)

# Seleccionar la coordenada extrema global SOLO EN LATITUD
extreme_global <- list(
  norte = if (extremes_arclim$norte[2] > extremes_pred$norte[2]) extremes_arclim$norte else extremes_pred$norte,
  sur = if (extremes_arclim$sur[2] < extremes_pred$sur[2]) extremes_arclim$sur else extremes_pred$sur
)

# Definir la extensión del recorte SOLO EN LATITUD
recorte_extent <- ext(
  xmin(arclim_binary),   # Mantener la longitud completa
  xmax(arclim_binary),   # Mantener la longitud completa
  extreme_global$sur[2], # Recortar por la latitud sur
  extreme_global$norte[2] # Recortar por la latitud norte
)

# Recortar ambos mapas con la nueva extensión
arclim_recortado <- crop(arclim_binary, recorte_extent)
pred_recortado <- crop(pred_binary, recorte_extent)

# Imprimir resultados
print("Extremos Globales (máximos entre ambos mapas, solo en latitud):")
print(extreme_global)

print("Archivos .tif generados: arclim_recortado.tif y pred_recortado.tif")

# Visualización de los mapas binarios recortados
png("reportes/mapas_binarios_A-atacamensis.png", width = 1200, height = 600, res = 150)  # Ajustar tamaño y resolución
par(mfcol = c(1,2))
plot(pred_recortado, main="Mapa Predicción 1980-2010")
plot(arclim_recortado, main="Mapa ARClim 1980-2010")
dev.off()



# FUTURE TIME (2035-2065) -------------------------------------------------
# Transformar los mapas a binario con umbral de 0.1
arclim_binary_future <- arclim_future >= 0.1
pred_binary_future <- pred_future_resampled >= 0.1

# Encontrar los píxeles con valor 1 en cada mapa
arclim_cells_future <- which(arclim_binary_future[] == 1)
pred_cells_future <- which(pred_binary_future[] == 1)

# Obtener coordenadas de los píxeles con valor 1
coords_arclim_future <- xyFromCell(arclim_binary_future, arclim_cells_future)
coords_pred_future <- xyFromCell(pred_binary_future, pred_cells_future)

# Encontrar los extremos NORTE y SUR de CADA MAPA
extremes_arclim_future <- list(
  norte = coords_arclim_future[which.max(coords_arclim_future[,2]),],  # Latitud máxima
  sur = coords_arclim_future[which.min(coords_arclim_future[,2]),]     # Latitud mínima
)

extremes_pred_future <- list(
  norte = coords_pred_future[which.max(coords_pred_future[,2]),],  # Latitud máxima
  sur = coords_pred_future[which.min(coords_pred_future[,2]),]     # Latitud mínima
)

# Seleccionar la coordenada extrema global SOLO EN LATITUD
extreme_global_future <- list(
  norte = if (extremes_arclim_future$norte[2] > extremes_pred_future$norte[2]) extremes_arclim_future$norte else extremes_pred_future$norte,
  sur = if (extremes_arclim_future$sur[2] < extremes_pred_future$sur[2]) extremes_arclim_future$sur else extremes_pred_future$sur
)

# Definir la extensión del recorte SOLO EN LATITUD (manteniendo longitud completa)
recorte_extent_future <- ext(
  xmin(arclim_binary_future),   # Mantener la longitud completa
  xmax(arclim_binary_future),   # Mantener la longitud completa
  extreme_global_future$sur[2], # Recortar por la latitud sur
  extreme_global_future$norte[2] # Recortar por la latitud norte
)

# Recortar ambos mapas con la nueva extensión
arclim_recortado_future <- crop(arclim_binary_future, recorte_extent_future)
pred_recortado_future <- crop(pred_binary_future, recorte_extent_future)

# Imprimir resultados
print("Extremos Globales (máximos entre ambos mapas, solo en latitud):")
print(extreme_global_future)

# Visualización de los mapas binarios recortados
png("reportes/mapas_binarios_future_A-atacamensis.png", width = 1200, height = 600, res = 150)  # Ajustar tamaño y resolución
par(mfcol = c(1,2))
plot(pred_recortado_future, main="Mapa Dismo 2035-2065")
plot(arclim_recortado_future, main="Mapa ARClim 2035-2065")
dev.off()
