library(terra)

# cargar capas de arclim --------------------------------------------------
zip_path <- "data/arclim_lycalopex_culpaeus.zip"  #cambiar por la especie correspondiente
files_in_zip <- unzip(zip_path, list = TRUE) # Listar los archivos dentro del ZIP
tif_files <- files_in_zip$Name[grepl("\\.tif$", files_in_zip$Name)] # Filtrar solo los archivos .tif dentro del ZIP

temp_dir <- tempdir()  # Crear un directorio temporal para extraer los archivos
unzip(zip_path, files = tif_files, exdir = temp_dir)  # Extraer los archivos .tif en la carpeta temporal

rasters <- lapply(tif_files, function(file) {  # Cargar los rasters desde la carpeta temporal
  rast(file.path(temp_dir, file))
})

names(rasters) <- c("arclim_present", "arclim_future")  # Ajustar los nombres según corresponda

arclim_present <- rasters[[1]] # Extraer los mapas en variables individuales
arclim_future <- rasters[[2]]


# probabilidades ----------------------------------------------------------
prob_present_mean_arclim <- global(arclim_present, "mean", na.rm = TRUE)
prob_future_mean_arclim <- global(arclim_future, "mean", na.rm = TRUE)


# ajustar mapas hechos por dismo ------------------------------------------

pred_present_spat <- rast(pred_present)  # Convertir pred_present (RasterLayer) a SpatRaster
pred_present_proj <- project(pred_present_spat, arclim_present, method = "bilinear")  # Reproyectar pred_present para que tenga la misma proyección que arclim_present
pred_present_resampled <- resample(pred_present_proj, arclim_present, method = "bilinear")  # Ajustar resolución y extensión para que coincidan con arclim_present
pred_present_resampled <- extend(pred_present_resampled, arclim_present)  # Asegurar que la extensión es exactamente la misma

common_range <- range(values(arclim_present), values(pred_present_resampled), na.rm = TRUE)

pred_future_spat <- rast(pred_future)  # Convertir pred_present (RasterLayer) a SpatRaster
pred_future_proj <- project(pred_future_spat, arclim_future, method = "bilinear")  # Reproyectar pred_present para que tenga la misma proyección que arclim_present
pred_future_resampled <- resample(pred_future_proj, arclim_future, method = "bilinear")  # Ajustar resolución y extensión para que coincidan con arclim_present
pred_future_resampled <- extend(pred_future_resampled, arclim_future)  # Asegurar que la extensión es exactamente la misma

common_range_future <- range(values(arclim_future), values(pred_future_resampled), na.rm = TRUE)


# graficar comparacion arclim-dismo 1980-2010 -----------------------------
library(RColorBrewer)
my_palette <- colorRampPalette(brewer.pal(9, "YlGnBu"))  # Amarillo - Verde - Azul

par(mfcol = c(1,2))

plot(pred_present_resampled, 
     main = "Probabilidad de ocurrencia \nL. culpaeus DISMO 1980-2010",
     xlim = c(-77, -66), ylim = c(-56, -17), asp=1,
     zlim = common_range,
     col = my_palette(100),  
     cex.main = 0.85)  
mtext(paste("Promedio:", round(prob_present_mean_arclim, 3)), side = 1, line = 3, cex = 0.8)

plot(arclim_present, 
     main = "Probabilidad ocurrencia ARCLIM \nL. culpaeus ARCLIM 1980-2010",
     xlim = c(-77, -66), ylim = c(-56, -17), asp=1,
     zlim = common_range,
     col = my_palette(100),  
     cex.main = 0.85)  
mtext(paste("Promedio:", round(prob_present_mean, 3)), side = 1, line = 3, cex = 0.8)


# grafica comparacion arclim-dismo 2035-2065 ------------------------------
par(mfcol = c(1,2))

plot(pred_future_resampled, 
     main = "Probabilidad de ocurrencia \nL. culpaeus DISMO 2035-2065",
     xlim = c(-77, -66), ylim = c(-56, -17), asp=1,
     zlim = common_range,
     col = my_palette(100),  
     cex.main = 0.85)  
mtext(paste("Promedio:", round(prob_future_mean_arclim, 3)), side = 1, line = 3, cex = 0.8)

plot(arclim_future, 
     main = "Probabilidad ocurrencia ARCLIM \nL. culpaeus ARCLIM 2035-2065",
     xlim = c(-77, -66), ylim = c(-56, -17), asp=1,
     zlim = common_range,
     col = my_palette(100),  
     cex.main = 0.85)  
mtext(paste("Promedio:", round(prob_future_mean, 3)), side = 1, line = 3, cex = 0.8)







