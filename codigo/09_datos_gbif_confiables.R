library(rgbif)
library(tidyverse)
library(httr)
library(jsonlite)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)

# si queremos de chile, por ej --------------------------------------------
resultados_chile <- occ_search(scientificName = "Pinus radiata", country = "CL")
resultados_chile$data

# verificando la existencia de la especie en GBIF -------------------------
especie_info <- name_backbone(name = "Enicognathus leptorhychus")
print(especie_info)
taxon_key <- especie_info$usageKey

enicognathus_data <- occ_search(taxonKey = taxon_key,
                                country = "CL",
                                hasCoordinate = TRUE,
                                limit = 5000)

data_ocurrencias <- enicognathus_data$data

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

data_ocurrencias_filtered <- data_ocurrencias_filtered %>% 
  select(decimalLongitude, decimalLatitude)
write.csv(data_ocurrencias_filtered, "C:data/culpeo_gbif.csv", row.names = FALSE)


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














# Revisar la estructura de la capa vectorial
plot(uso_suelo["categoria"], main = "Uso de Suelo por Categoría")




# Verificar registros después del filtrado
table(data_ocurrencias_filtered$publishingOrgKey)

# Visualizar datos confiables ---------------------------------------------
chile <- ne_countries(country = "Chile", scale = "medium", returnclass = "sf")  # Obtener datos geográficos de Chile
plot(st_geometry(chile))  # Revisar la geometría de Chile

ggplot() +
  geom_sf(data = chile, fill = "gray90", color = "black") +  # Mapa de Chile
  geom_point(data = data_ocurrencias_filtered, 
             aes(x = decimalLongitude, y = decimalLatitude),
             color = "blue", alpha = 0.3, size = 1) +  # Puntos de ocurrencia
  coord_sf(xlim = c(-75, -66), ylim = c(-56, -17)) +  # Limitar a Chile
  theme_minimal() +
  labs(title = "Distribución de Enicognathus leptorhynchus en Chile",
       x = "Longitud", y = "Latitud")