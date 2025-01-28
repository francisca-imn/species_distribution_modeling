library(rgbif)
library(tidyverse)
library(httr)
library(jsonlite)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)

# verificando la existencia de la especie en GBIF -------------------------
especie_info <- name_backbone(name = "Lycalopex culpaeus")
print(especie_info)
taxon_key <- especie_info$usageKey

culpeo_data <- occ_search(taxonKey = taxon_key,
                                country = "CL",
                                hasCoordinate = TRUE,
                                limit = 5000)

data_ocurrencias <- culpeo_data$data

# filtrar datos: eliminar inaturalist -------------------------------------
data_ocurrencias_filtered <- data_ocurrencias %>%   # Filtrar registros eliminando los provenientes de iNaturalist
  filter(
    !grepl("inaturalist.org", references, ignore.case = TRUE)  # Excluir iNaturalist
  )

# en base a observaciones -------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(basisOfRecord %in% c("HUMAN_OBSERVATION", "MACHINE_OBSERVATION"))

# mmm veamos issues mejor -------------------------------------------------
unique(data_ocurrencias$issues)

data_ocurrencias_filtered <- data_ocurrencias %>%
  filter(issues == "")  # Solo registros sin problemas reportados

# Ver cantidad de registros filtrados
nrow(data_filtered)

# mmmmmm aber, viendo instituciones de origen -----------------------------
unique(data_ocurrencias$publishingOrgKey)

get_org_name <- function(org_key) {              # Función para obtener el nombre de la organización por su publishingOrgKey
  url <- paste0("https://api.gbif.org/v1/organization/", org_key)
  response <- fromJSON(content(GET(url), "text"), flatten = TRUE)
  return(response$title)
}

# Aplicar la función a los códigos únicos en tus datos
org_names <- unique(data_ocurrencias$publishingOrgKey)
org_info <- sapply(org_names, get_org_name)

print(org_info) # Ver los resultados

#28eb1a3f-1c15-4a95-931a-4af90ecb574d      1f00d75c-f6fc-4224-a595-975e82d7689c      e2e717bf-551a-4917-bdc9-4fa0f342c530 
#         "iNaturalist.org"              "Xeno-canto Foundation for Nature Sounds"        "Cornell Lab of Ornithology"


# Eliminar datos de iNaturalist.org ---------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(publishingOrgKey != "28eb1a3f-1c15-4a95-931a-4af90ecb574d")

# Precisión espacial adecuada ---------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(coordinateUncertaintyInMeters <= 1000 | is.na(coordinateUncertaintyInMeters))  # Incertidumbre < 1 km

# Fecha (actuales) --------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(year >= 2023)  # Solo registros de los últimos 2 años

# cautiverio o zoo --------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(!grepl("zoo|captive|rescue", locality, ignore.case = TRUE))

# calidad taxonómica ------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(taxonRank == "SPECIES", taxonomicStatus == "ACCEPTED")

# evitar duplicados -------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  distinct(decimalLongitude, decimalLatitude, year, .keep_all = TRUE)

# uso de suelo ------------------------------------------------------------

uso_suelo <- st_read("data/regiones/cut_2001_2021_R09/cut_2001_2021_R09.shp")
# Verificar la estructura de la capa
print(uso_suelo)       # Ver un resumen general de la capa
colnames(uso_suelo)    # Ver los nombres de todas las columnas
ncol(uso_suelo)        # Contar el número de columnas


# Filtrar solo áreas naturales para la especie
uso_suelo_natural <- uso_suelo %>%
  filter(DES_USO_01 %in% c(
    "Bosques, Bosque Nativo, Adulto-Renoval",
    "Bosques, Bosque Nativo, Achaparrado",
    "Bosques, Bosque Mixto, Nativo-Plantación",
    "Praderas y Matorrales, Praderas, Pradera Perenne",
    "Humedales, Otros Terrenos Húmedos"
  ))


# Convertir el dataframe de ocurrencias a objeto espacial sf (WGS84)
data_ocurrencias_sf <- st_as_sf(data_ocurrencias_filtered, 
                                coords = c("decimalLongitude", "decimalLatitude"), 
                                crs = 4326)  # WGS84 (lat/lon)

# Revisar la estructura después de la conversión
print(st_crs(data_ocurrencias_sf))  # Confirmar CRS correcto

#si el CRS de la capa de uso de suelo es diferente, reproyectar los puntos:
uso_suelo_natural <- st_transform(uso_suelo_natural, crs = st_crs(data_ocurrencias_sf))

#cruzar ocurrencias con la capa de uso de suelo natural --> ERRORRRRRRRR
data_ocurrencias_filtradas <- st_intersection(data_ocurrencias_sf, uso_suelo_natural)

# Verificar cuántos registros se mantuvieron después del cruce
nrow(data_ocurrencias_filtradas)

# viendo error ------------------------------------------------------------
# Revisar si hay geometrías inválidas
sum(!st_is_valid(uso_suelo_natural))  # Devuelve el número de geometrías inválidas

# Visualizar las filas con geometrías inválidas
uso_suelo_natural[!st_is_valid(uso_suelo_natural), ]





# cargar datos ------------------------------------------------------------
env_layers_actual <- stack(list.files("data/actual", pattern = ".tif$", full.names = TRUE))    #capas climáticas actuales
env_layers_future <- stack(list.files("data/future_85", pattern = ".tif$", full.names = TRUE)) #capas climáticas futuras
presence <- read.csv("data/especies/culpeo_gbif.csv")                                                 # Cargar puntos de presencia

presence <- presence %>% select(-Especie)                                                      #Deja solo columna de lon y lat, opcional

# ejecutar maxent ---------------------------------------------------------
model <- maxent(env_layers_actual, presence)

# predicción capas actuales -----------------------------------------------
par(mfcol = c(1, 2))  # 1 fila, 2 columnas
pred <- predict(model, env_layers_actual) 
plot(pred, main = "GBIF datos filtrados", 
     xlim = c(-80, -60))                           #visualizar
writeRaster(pred, "idoneidad_actual.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# predicción capas futuras ------------------------------------------------
future_pred <- predict(model, env_layers_future) 
plot(future_pred, main = "Proyección futura - Idoneidad del hábitat")                 #visualizar
writeRaster(future_pred, "idoneidad_futura.tif", format = "GTiff", overwrite = TRUE)  #guardar capa

# delta entre escenarios --------------------------------------------------
difference <- future_pred - pred 
plot(difference, main = "Cambio en idoneidad (Futuro - Actual)") 
writeRaster(difference, "delta.tif", format = "GTiff", overwrite = TRUE)

# ESTADÍSTICAS ------------------------------------------------------------
model@results

#Área bajo la curva
auc_value <- model@results["Training.AUC", ]
print(paste("AUC del modelo:", auc_value))

#Contibución variables ambientales
contribucion <- model@results[grep("contribution", rownames(model@results)), ]
print(contribucion)
response(model)

#Idoneidad de área**
umbral <- 0.5  # ajustable
alta_idoneidad_actual <- pred > umbral
alta_idoneidad_futura <- future_pred > umbral

area_actual <- cellStats(alta_idoneidad_actual, sum) / ncell(pred) * 100
area_futura <- cellStats(alta_idoneidad_futura, sum) / ncell(future_pred) * 100

print(paste("Área con alta idoneidad actual (%):", round(area_actual, 2)))
print(paste("Área con alta idoneidad futura (%):", round(area_futura, 2)))





# https://rspatial.org/raster/sdm/ 
