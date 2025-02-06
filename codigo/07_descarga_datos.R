# Descarga capas climáticas -----------------------------------------------
writeRaster(capas_present_raster, "capas_clima_1980-2010.tif", overwrite = TRUE)
writeRaster(capas_future_raster, "capas_clima_1980-2010.tif", overwrite = TRUE)

# Descarga datos de ocurrencia --------------------------------------------
df_sf <- st_as_sf(data_ocurrencias_filtered, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
st_write(df_sf, "puntos_Lycalopex-griseus.shp", delete_layer = TRUE)  #cambiar nombre especie si corresponde

# Descarga SDMs de dismo() ------------------------------------------------
writeRaster(pred_present_resampled, "pred_dismo_1980-2010_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(pred_future_resampled, "pred_dismo_2035-2065_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde

# Descarga mapa diferencia (dismo - arclim) -------------------------------
writeRaster(diff_present, "dif_1980-2010_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde
writeRaster(diff_future, "dif_2035-2065_N-tarapacana.tif", overwrite = TRUE)  #cambiar nombre especie si corresponde

# Guardar los mapas binarios si es necesario
writeRaster(arclim_binary, "arclim_binary.tif", overwrite=TRUE)
writeRaster(pred_binary, "pred_binary.tif", overwrite=TRUE)

