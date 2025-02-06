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

# Encontrar los extremos de CADA MAPA
extremes_arclim <- list(
  norte = coords_arclim[which.max(coords_arclim[,2]),],
  sur = coords_arclim[which.min(coords_arclim[,2]),],
  este = coords_arclim[which.max(coords_arclim[,1]),],
  oeste = coords_arclim[which.min(coords_arclim[,1]),]
)

extremes_pred <- list(
  norte = coords_pred[which.max(coords_pred[,2]),],
  sur = coords_pred[which.min(coords_pred[,2]),],
  este = coords_pred[which.max(coords_pred[,1]),],
  oeste = coords_pred[which.min(coords_pred[,1]),]
)

# Seleccionar la coordenada extrema global
extreme_global <- list(
  norte = if (extremes_arclim$norte[2] > extremes_pred$norte[2]) extremes_arclim$norte else extremes_pred$norte,
  sur = if (extremes_arclim$sur[2] < extremes_pred$sur[2]) extremes_arclim$sur else extremes_pred$sur,
  este = if (extremes_arclim$este[1] > extremes_pred$este[1]) extremes_arclim$este else extremes_pred$este,
  oeste = if (extremes_arclim$oeste[1] < extremes_pred$oeste[1]) extremes_arclim$oeste else extremes_pred$oeste
)

# Definir la extensión del recorte basado en el cuadrado rojo
recorte_extent <- ext(extreme_global$oeste[1], extreme_global$este[1], extreme_global$sur[2], extreme_global$norte[2])

# Recortar ambos mapas al cuadrado definido
arclim_recortado <- crop(arclim_binary, recorte_extent)
pred_recortado <- crop(pred_binary, recorte_extent)

# Guardar los mapas recortados como archivos .tif
#writeRaster(arclim_recortado, "arclim_recortado.tif", overwrite=TRUE)
#writeRaster(pred_recortado, "pred_recortado.tif", overwrite=TRUE)

# Imprimir resultados
print("Extremos Globales (máximos entre ambos mapas):")
print(extreme_global)

print("Archivos .tif generados: arclim_recortado.tif y pred_recortado.tif")

# Visualización de los mapas binarios recortados
plot(pred_recortado, main="Mapa Predicción 1980-2010")
plot(arclim_recortado, main="Mapa ARClim 1980-2010")



# FUTURE TIME (2035-2065) -------------------------------------------------------------------------
# Transformar los mapas a binario con umbral de 0.1
arclim_binary_future <- arclim_future >= 0.1
pred_binary_future <- pred_future_resampled >= 0.1

# Encontrar los píxeles con valor 1 en cada mapa
arclim_cells_future <- which(arclim_binary_future[] == 1)
pred_cells_future <- which(pred_binary_future[] == 1)

# Obtener coordenadas de los píxeles con valor 1
coords_arclim_future <- xyFromCell(arclim_binary_future, arclim_cells_future)
coords_pred_future <- xyFromCell(pred_binary_future, pred_cells_future)

# Encontrar los extremos de CADA MAPA
extremes_arclim_future <- list(
  norte = coords_arclim_future[which.max(coords_arclim_future[,2]),],
  sur = coords_arclim_future[which.min(coords_arclim_future[,2]),],
  este = coords_arclim_future[which.max(coords_arclim_future[,1]),],
  oeste = coords_arclim_future[which.min(coords_arclim_future[,1]),]
)

extremes_pred_future <- list(
  norte = coords_pred_future[which.max(coords_pred_future[,2]),],
  sur = coords_pred_future[which.min(coords_pred_future[,2]),],
  este = coords_pred_future[which.max(coords_pred_future[,1]),],
  oeste = coords_pred_future[which.min(coords_pred_future[,1]),]
)

# Seleccionar la coordenada extrema global
extreme_global_future <- list(
  norte = if (extremes_arclim_future$norte[2] > extremes_pred_future$norte[2]) extremes_arclim_future$norte else extremes_pred_future$norte,
  sur = if (extremes_arclim_future$sur[2] < extremes_pred_future$sur[2]) extremes_arclim_future$sur else extremes_pred_future$sur,
  este = if (extremes_arclim_future$este[1] > extremes_pred_future$este[1]) extremes_arclim_future$este else extremes_pred_future$este,
  oeste = if (extremes_arclim_future$oeste[1] < extremes_pred_future$oeste[1]) extremes_arclim_future$oeste else extremes_pred_future$oeste
)

# Definir la extensión del recorte basado en el cuadrado rojo
recorte_extent_future <- ext(extreme_global_future$oeste[1], extreme_global_future$este[1], extreme_global_future$sur[2], extreme_global_future$norte[2])

# Recortar ambos mapas al cuadrado definido
arclim_recortado_future <- crop(arclim_binary_future, recorte_extent_future)
pred_recortado_future <- crop(pred_binary_future, recorte_extent_future)

# Guardar los mapas recortados como archivos .tif
#writeRaster(arclim_recortado, "arclim_recortado.tif", overwrite=TRUE)
#writeRaster(pred_recortado, "pred_recortado.tif", overwrite=TRUE)

# Imprimir resultados
print("Extremos Globales (máximos entre ambos mapas):")
print(extreme_global_future)

# Visualización de los mapas binarios recortados
plot(pred_recortado_future, main="Mapa Dismo 2035-2065")
plot(arclim_recortado_future, main="Mapa ARClim 2035-2065")