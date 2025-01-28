library(biomod2)
library(stats)
library(utils)
library(methods)
library(terra)
library(sp)
library(tidyverse)
library(reshape)
library(reshape2)
library(tidyterra)

env_act <- terra::unwrap(bioclim_current)
env_fut <- terra::unwrap(bioclim_future)

# Paso 1: Cargar datos de ejemplo
# Cargar datos de ocurrencias de especies y variables bioclimáticas
data(DataSpecies)  # Incluido en biomod2
head(DataSpecies)  # Datos de especies (incluye presencia/ausencia y coordenadas)

# Nombre de la especie a modelar
myRespName <- "GuloGulo"  # Cambia según tu especie

# Datos de presencia/ausencia
myResp <- as.numeric(DataSpecies[, myRespName])

# Coordenadas geográficas
myRespXY <- DataSpecies[, c("X_WGS84", "Y_WGS84")]

# Cargar variables explicativas (bioclimáticas)
data(bioclim_current)  # Variables incluidas en biomod2
myExpl <- rast(bioclim_current)  # Convertir a SpatRaster

# Paso 2: Formatear datos para el modelado
# Filtrar presencias... filtrar ausencias reales y trabajar solo con presencias
presence_idx <- myResp == 1
myRespFiltered <- myResp[presence_idx]
myRespXYFiltered <- myRespXY[presence_idx, ]

# Formatear datos
myBiomodData <- BIOMOD_FormatingData(
  resp.var = myRespFiltered,
  expl.var = myExpl,
  resp.xy = myRespXYFiltered,
  resp.name = myRespName,
  PA.nb.rep = 2,            # Número de conjuntos de pseudo-ausencias
  PA.strategy = "random",   # Estrategia para seleccionar pseudo-ausencias
  PA.nb.absences = 1000     # Cantidad de pseudo-ausencias
)

#Define los modelos que deseas usar (como GLM, RF, GBM) y otras configuraciones.
myBiomodOptions <- bm_ModelingOptions(
  data.type = "binary",
  models = c("GLM", "RF", "GBM", "ANN"),
  strategy = "default",
  bm.format = myBiomodData  # Proporciona el objeto formateado
)

#Ajustar modelos individuales
myBiomodModelOut <- BIOMOD_Modeling(
  bm.format = myBiomodData,    # Datos formateados
  modeling.id = "TestModel",   # Identificador para el conjunto de modelos
  models = c("GLM", "RF", "GBM", "ANN"),  # Modelos definidos
  bm.options = myBiomodOptions,  # Opciones configuradas
  CV.strategy = "random",      # Validación cruzada aleatoria
  CV.nb.rep = 2,               # Número de repeticiones de validación cruzada
  CV.perc = 0.8,               # Porcentaje de datos para calibración
  metric.eval = c("TSS", "ROC"),  # Métricas de evaluación
  var.import = 3,              # Permutaciones para calcular importancia de variables
  seed.val = 42                # Semilla para reproducibilidad
)

#crear modelos en conjunto
myBiomodEM <- BIOMOD_EnsembleModeling(
  bm.mod = myBiomodModelOut,  # Modelos individuales ajustados
  models.chosen = "all",      # Usar todos los modelos ajustados
  em.by = "all",              # Estrategia para combinar modelos
  em.algo = c("EMmean", "EMca"),  # Algoritmos de combinación
  metric.select = c("TSS"),       # Selección basada en la métrica TSS
  metric.select.thresh = c(0.7)   # Umbral para incluir modelos
)

#proyectar modelos
myBiomodProj <- BIOMOD_Projection(
  bm.mod = myBiomodModelOut,   # Modelos ajustados
  proj.name = "Current",       # Nombre del proyecto
  new.env = myExpl,            # Variables climáticas actuales
  models.chosen = "all",       # Proyectar todos los modelos
  metric.binary = "TSS",       # Umbral para resultados binarios
  build.clamping.mask = TRUE   # Generar máscara para valores extrapolados
)

#evaluar y visualizar resultados
get_evaluations(myBiomodModelOut)

#variables mas importantes
get_variables_importance(myBiomodModelOut)

#gráficos de evaluación
bm_PlotEvalMean(myBiomodModelOut)  # Promedio de evaluación
bm_PlotEvalBoxplot(myBiomodModelOut)  # Boxplot de métricas de evaluación

#proyección resultados
plot(myBiomodProj)
