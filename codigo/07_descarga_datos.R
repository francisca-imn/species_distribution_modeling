# Descarga capas climáticas -----------------------------------------------
writeRaster(capas_present_raster, "capas_clima_1980-2010.tif", overwrite = TRUE)
writeRaster(capas_future_raster, "capas_clima_2035-2010.tif", overwrite = TRUE)

# Descarga datos de ocurrencia --------------------------------------------
df_sf <- st_as_sf(data_ocurrencias_filtered, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
st_write(df_sf, "puntos_Lycalopex-griseus.shp", delete_layer = TRUE)  #cambiar nombre especie si corresponde

# Descarga SDMs de dismo() ------------------------------------------------
writeRaster(pred_present_resampled, "data/resultados/pred_dismo_1980-2010_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(pred_future_resampled, "data/resultados/pred_dismo_2035-2065_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde

# Descarga mapas binarios en zonas de interés -----------------------------
writeRaster(pred_recortado, "data/resultados/pred_dismo_1980-2010_recortado_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(arclim_recortado, "data/resultados/pred_arclim_1980-2010_recortado_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(pred_recortado_future, "data/resultados/pred_dismo_2035-2065_recortado_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(arclim_recortado_future, "data/resultados/pred_arclim_2035-2065_recortado_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde

# Descarga mapa binario diferencia (dismo - arclim) -----------------------
writeRaster(diff_present_recortado, "data/resultados/dif_1980-2010_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(diff_future, "data/resultados/dif_2035-2065_A-atacamensis.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde


