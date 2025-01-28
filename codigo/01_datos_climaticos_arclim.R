library(httr)
library(terra)
library(sf)
library(dismo)
library(jsonlite)

url_base <- "https://arclim.mma.gob.cl/api/datos"  # URL base de la API ARClim

variables <- c("eto_mean", "pr_sum", "rsds_mean", "tasmin_mean", "tasmax_mean")  # Lista de variables climáticas a descargar

raster_list <- list()  # Crear una lista vacía para almacenar los rasters

for (var in variables) {  # Descargar y procesar cada variable climática
  atributos <- paste0("$CLIMA$", var, "$annual$present")  # Construir la URL con el nombre de la variable
  url <- paste0(url_base, "/arclim_raster_5km/geojson/?attributes=", URLencode(atributos))
  
  response <- GET(url)  # Realizar la consulta a la API
  
  if (status_code(response) == 200) {  # Verificar si la respuesta fue exitosa
    
    geojson_file <- tempfile(fileext = ".geojson")  # Guardar datos descargados como archivo temporal
    writeBin(content(response, "raw"), geojson_file)
    
    vect_data <- vect(geojson_file)  # Cargar los datos como un objeto SpatVector
    
    raster_data <- rast(vect_data, resolution = 0.05)  # Crear un raster con la misma resolución para todas las capas
    raster_data <- rasterize(vect_data, raster_data, field = atributos)  # Usa la variable correcta
    
    raster_list[[var]] <- raster_data  # Guardar raster en la lista con el nombre de la variable
    
  } else {
    print(paste("❌ Error al descargar", var, "- Código:", status_code(response)))
  }
}

raster_stack <- rast(raster_list)  # Combinar todas las capas en un solo objeto SpatRaster

print(raster_stack)  # Mostrar información del stack
plot(raster_stack)


