library(terra)

zip_path <- "data/arclim_lycalopex_culpaeus.zip"  #cambiar por la especie correspondiente

# Listar los archivos dentro del ZIP
files_in_zip <- unzip(zip_path, list = TRUE)

tif_files <- files_in_zip$Name[grepl("\\.tif$", files_in_zip$Name)] # Filtrar solo los archivos .tif dentro del ZIP



# Crear un directorio temporal para extraer los archivos
temp_dir <- tempdir()

# Extraer los archivos .tif en la carpeta temporal
unzip(zip_path, files = tif_files, exdir = temp_dir)

# Cargar los rasters desde la carpeta temporal
rasters <- lapply(tif_files, function(file) {
  rast(file.path(temp_dir, file))
})

# Asignar nombres a los rasters
names(rasters) <- c("arclim_present", "arclim_future")  # Ajusta los nombres según corresponda

# Extraer los mapas en variables individuales
arclim_present <- rasters[[1]]
arclim_future <- rasters[[2]]

# Verificar los datos cargados
print(arclim_present)
print(arclim_future)

par(mfcol = c(1,2))
plot(arclim_present, main = "Prob. ocurrencia ARCLIM \nLycalopex culpaeus PRESE",
     xlim = c(-75, -65), ylim = c(-56, -17), asp=1)
mtext(paste("Promedio:", round(prob_delta_mean, 3)), side = 1, line = 3, cex = 1)
