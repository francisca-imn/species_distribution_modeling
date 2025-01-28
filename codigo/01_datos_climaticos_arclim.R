library(httr)
library(terra)
library(sf)
library(dismo)

url_base <- "https://arclim.mma.gob.cl/api/datos"

capa <- "arclim_raster_5km"
formato <- "geojson"
atributos <- "$CLIMA$eto_mean$annual$present"

# Corregir el nombre del parámetro en la URL
url <- paste0(url_base, "/", capa, "/", formato, "/?attributes=", URLencode(atributos))

response <- GET(url)

# Verificar si la API responde correctamente
print(content(response, "text"))


# Verifica si la consulta fue exitosa
if (status_code(response) == 200) {
  # Guarda los datos descargados como un archivo temporal
  geojson_file <- tempfile(fileext = ".geojson")
  writeBin(content(response, "raw"), geojson_file)
  
  # Carga los datos GeoJSON como un objeto de tipo SpatRaster (raster en terra)
  vect_data <- vect(geojson_file)
  
  # Convierte el vector a raster
  raster_data <- rast(vect_data, resolution = 0.05)  # Cambia la resolución si es necesario
  raster_data <- rasterize(vect_data, raster_data, field = "$CLIMA$eto_mean$annual$present")  # Usa el campo relevante
  
  # Muestra un resumen del raster cargado
  print(raster_data)
  plot(raster_data)
} else {
  # Manejo de errores si la consulta falla
  print(paste("Error al descargar los datos. Código de estado:", status_code(response)))
}
