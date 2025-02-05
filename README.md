# species_distribution_modeling
Ejemplos de modelamiento de distribución de especies desarrollados durante práctica profesional. El objetivo es replicar metodología utilizada en Arclim (Atlas de Riesgo Climático, fuente oficial chilena) y comparar con otros modelos. Incluye métodos estadísticos, escenarios climáticos actuales y futuros y uso principal del paquete dismo en R.

## Uso
Los códigos deben ser corridos en orden ya que son dependientes de otros. 

- Código 01: Obtención de variables climáticas de Arclim (evapotranspiración promedio anual, precipitación acumulada anual, promedio anual de la insolación solar diaria, promedio anual de la temperatura mínima diaria y promedio anual de la temperatura máxima diaria).
- Código 02: Obtención de datos de ocurrencia desde GBIF, son filtrados a partir de distintos parámetros. **Se debe cambiar de manualmente el nombre científico de la especie de interés**.
- Código 03: Se ejecuta modelo MAXENT con el paquete dismo con las variables obtenidas.
- Código 04: Se cargan los SDMs de Arclim, se encuentran en la carpeta 'data'. **Se debe cambiar de manualmente el nombre científico de la especie de interés**. 
- Código 05: Se realiza una comparación estadística entre el modelo obtenido en el código 03 y el cargado en el código 04. 
- Código 06: *Opcional.* Descarga de datos climáticos y ocurrencias, también de los SDMs obtenidos. 