# Descarga capas climáticas -----------------------------------------------
writeRaster(capas_present_raster, "capas_clima_1980-2010.tif", overwrite = TRUE)
writeRaster(capas_future_raster, "capas_clima_1980-2010.tif", overwrite = TRUE)

# Descarga datos de ocurrencia --------------------------------------------
df_sf <- st_as_sf(data_ocurrencias_filtered, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
st_write(df_sf, "puntos_M-coypus.shp", delete_layer = TRUE)  #cambiar nombre especie si corresponde

# Descarga SDMs de dismo() ------------------------------------------------
writeRaster(pred_present_resampled, "pred_dismo_1980-2010_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(pred_future_resampled, "pred_dismo_2035-2065_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde

# Descarga mapa diferencia (dismo - arclim) -------------------------------
writeRaster(diff_present, "dif_1980-2010_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(diff_future, "dif_2035-2065_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde

















# 📌 URL base de la API ARClim
url_base <- "https://arclim.mma.gob.cl/api/datos"

# Definir la capa y el formato de salida
capa <- "arclim_raster_5km"  # Capa de resolución 5 km
formato <- "geotiff"  # Formato GeoTIFF

# Definir variable climática y periodo
variable <- "pr_sum"  # Precipitación total
season <- "annual"  # Datos anuales
period <- "present"  # Periodo histórico (1980-2010)

# Construir la URL correcta
url_request <- paste0(url_base, "/", capa, "/", formato, "/?attributes=$CLIMA$", variable, "$", season, "$", period)

# Realizar la consulta
response <- GET(url_request)

# Verificar si la respuesta fue exitosa
if (status_code(response) == 200) {
  
  # Extraer la URL del archivo GeoTIFF desde la respuesta JSON
  datos <- fromJSON(content(response, as = "text"), flatten = TRUE)
  
  # Verificar que la respuesta contiene una URL de descarga
  if (!is.null(datos$url)) {
    
    # Descargar el archivo GeoTIFF
    download.file(datos$url, destfile = "pr_sum_1980-2010.tif", mode = "wb")
    
    # Cargar el raster en R con terra
    raster_capa <- rast("pr_sum_1980-2010.tif")
    
    # Mostrar información del raster
    print(raster_capa)
    
  } else {
    print("Error: No se encontró la URL del archivo GeoTIFF en la respuesta.")
  }
  
} else {
  print(paste("Error en la solicitud. Código de estado:", status_code(response)))
}







  

  











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