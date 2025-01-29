library(httr)
library(terra)
library(sf)
library(dismo)
library(jsonlite)

# 📌 Variables actuales (presente) -------------------------------------------
url_base <- "https://arclim.mma.gob.cl/api/datos"  # URL base de la API ARClim

variables <- c("eto_mean", "pr_sum", "rsds_mean", "tasmin_mean", "tasmax_mean")  # Lista de variables climáticas a descargar

raster_list_present <- list()  # Crear una lista vacía para almacenar los rasters

for (var in variables) {  # Descargar y procesar cada variable climática
  atributos_present <- paste0("$CLIMA$", var, "$annual$present")  # Construir la URL con el nombre de la variable
  url_present <- paste0(url_base, "/arclim_raster_5km/geojson/?attributes=", URLencode(atributos_present))
  
  response_present <- GET(url_present)  # Realizar la consulta a la API
  
  if (status_code(response_present) == 200) {  # Verificar si la respuesta fue exitosa
    
    geojson_file_present <- tempfile(fileext = ".geojson")  # Guardar datos descargados como archivo temporal
    writeBin(content(response_present, "raw"), geojson_file_present)
    
    vect_data_present <- vect(geojson_file_present)  # Cargar los datos como un objeto SpatVector
    
    raster_data_present <- rast(vect_data_present, resolution = 0.05)  # Crear un raster con la misma resolución para todas las capas
    raster_data_present <- rasterize(vect_data_present, raster_data_present, field = atributos_present)  # Usa la variable correcta
    
    raster_list_present[[var]] <- raster_data_present  
    
  } else {
    print(paste("❌ Error al descargar", var, "- Código:", status_code(response_present)))  # ✅ Error corregido
  }
}

capas_present <- rast(raster_list_present) # Combinar todas las capas en un solo objeto SpatRaster

print(capas_present)
plot(capas_present)  



# 📌 Variables tiempo futuro ----------------------------------------------
# 📌 Variables futuras (proyecciones) -------------------------------------------
url_base <- "https://arclim.mma.gob.cl/api/datos"  # URL base de la API ARClim

variables <- c("eto_mean", "pr_sum", "rsds_mean", "tasmin_mean", "tasmax_mean")  # Lista de variables climáticas a descargar

raster_list_future <- list()  # Crear una lista vacía para almacenar los rasters

for (var in variables) {  # Descargar y procesar cada variable climática futura
  atributos_future <- paste0("$CLIMA$", var, "$annual$future")  # ✅ CORREGIDO: "futuro" en lugar de "future"
  url_future <- paste0(url_base, "/arclim_raster_5km/geojson/?attributes=", URLencode(atributos_future))
  
  response_future <- GET(url_future)  # Realizar la consulta a la API
  
  if (status_code(response_future) == 200) {  # Verificar si la respuesta fue exitosa
    
    geojson_file_future <- tempfile(fileext = ".geojson")  # Guardar datos descargados como archivo temporal
    writeBin(content(response_future, "raw"), geojson_file_future)
    
    vect_data_future <- vect(geojson_file_future)  # Cargar los datos como un objeto SpatVector
    
    raster_data_future <- rast(vect_data_future, resolution = 0.05)  # Crear un raster con la misma resolución para todas las capas
    raster_data_future <- rasterize(vect_data_future, raster_data_future, field = atributos_future)  # Usa la variable correcta
    
    raster_list_future[[var]] <- raster_data_future  # ✅ Guardar raster correctamente en la lista
    
  } else {
    print(paste("❌ Error al descargar", var, "- Código:", status_code(response_future)))  # ✅ CORREGIDO: error de sintaxis
  }
}

# 📌 Combinar todas las capas en un solo objeto SpatRaster
capas_future <- rast(raster_list_future)

# 📊 Mostrar información del stack futuro
print(capas_future)
plot(capas_future)  # ✅ Graficar correctamente las capas