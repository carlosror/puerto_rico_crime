---
output: html_document
---
---

#### Generales
---

Los datos fueron obtenidos de el [Portal de Interconexión de Datos Abiertos de Puerto Rico](https://data.pr.gov/), específicamente [aquí](https://data.pr.gov/en/Seguridad-P-blica/Mapa-del-Crimen-Crime-Map/bkiv-k4gu).

Para proteger la privacidad de la ciudadanía, **las ubicaciones de todos los resultados han sido modificadas ligeramente, de manera que ninguna de las ubicaciones es exacta sino aproximada**.

Para hacer una búsqueda, puede teclear una ubicación, por ejemplo, "El Viejo San Juan, PR", o "Villa Blanca, Caguas, PR", y presionar Buscar. También puede hacer clic en una ubicación del mapa. Ya que muchas direcciones en Puerto Rico, especialmente en las áreas rurales, 
son poco *ortodoxas*, e.g., "CARR 651 KM 1 HM 2 SECT LOS CAÑOS BO TANAMA, ARECIBO, PR", usted puede por ejemplo buscar "Arecibo, PR", hacer zoom en el Sector Los Caños del Barrio Tanamá, hacer clic en la ubicación que le
interese, y presionar Buscar.

Haciendo clic en una de las marquitas se pueden ver el crimen, la fecha, y la hora.

![alt text](crime_marker.png "Crime marker")


---

#### Bar plots
---

Los bar plots, o gráficos de barra, son construídos en base a los filtros y la faceta seleccionados.

Por ejemplo, a continuación se muestra el bar plot correspondiente a una búsqueda de crímenes cometidos los lunes, miércoles, y viernes en la madrugada y por la noche, con faceta de día.

![alt text](faceted_inputs_1.png "Faceted inputs")  ![alt text](faceted_result_1.png "Faceted results")    
<br>

Los mismos resultados con faceta de período.

![alt text](faceted_inputs_2.png "Faceted inputs")  ![alt text](faceted_result_2.png "Faceted results")

---
#### Mapas de densidad
---

Los mapas de densidad toman un par de segundos. Son construídos de manera similar a los bar plots, es decir, en base a los filtros y la faceta seleccionados.

![alt text](faceted_result_3.png "Faceted map density")

---

#### Tabla
---

Aquí los resultados de la búsqueda son tabulados. La tabla también se construye en base a la faceta y los filtros seleecionados.
<br><br>