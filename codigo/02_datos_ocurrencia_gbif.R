library(rgbif)
library(tidyverse)
library(httr)
library(jsonlite)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(rJava)

# verificando la existencia de la especie en GBIF -------------------------
especie_info <- name_backbone(name = "Lycalopex culpaeus")  #cambiar el nombre por el de la especie de interés
print(especie_info)
taxon_key <- especie_info$usageKey

especie_data <- occ_search(taxonKey = taxon_key,
                          country = "CL",
                          hasCoordinate = TRUE,
                          limit = 5000)  #la cantidad de datos puede variar

data_ocurrencias <- especie_data$data

# en base a observaciones -------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias %>%
  filter(basisOfRecord %in% c("HUMAN_OBSERVATION", "MACHINE_OBSERVATION"))

# mmm veamos issues mejor -------------------------------------------------
unique(data_ocurrencias$issues)

data_ocurrencias_filtered <- data_ocurrencias %>%  #OJO, ESTO ELIMINA TODOS LOS DATOS
  filter(issues == "")  # Solo registros sin problemas reportados


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

print(org_info) # Ver los resultados y analizar si alguno no corresponde

#28eb1a3f-1c15-4a95-931a-4af90ecb574d      1f00d75c-f6fc-4224-a595-975e82d7689c      e2e717bf-551a-4917-bdc9-4fa0f342c530 
#         "iNaturalist.org"              "Xeno-canto Foundation for Nature Sounds"        "Cornell Lab of Ornithology"


# Eliminar datos de iNaturalist.org ---------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(publishingOrgKey != "28eb1a3f-1c15-4a95-931a-4af90ecb574d")  #esto es equivalente a references, reemplazar por los códigos que no son fuentes confiables

# Precisión espacial adecuada ---------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(coordinateUncertaintyInMeters <= 1000 | is.na(coordinateUncertaintyInMeters))  # Incertidumbre < 1 km

# Fecha (actuales) --------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%  #esto no porque el modelo actual abarca hartos años
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
