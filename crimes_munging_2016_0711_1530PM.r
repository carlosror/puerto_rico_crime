################################
# Tidying up the data
################################
library(chron) # for dealing with chronological objects
library(magrittr) # pipe operator
library(plyr) # rename

crimes <- read.csv("crime_data_puerto_rico_2012-2016.csv", encoding="UTF-8")

# The Location column has the same information as the columns POINT_X and POINT_Y
# Remove it then to save space
crimes$Location <- NULL

# Some of the rows have no location info, e.g.:
# 2016/01/09,16:24:00,6,Apropiacion Ilegal,,,,Utuado
# Remove them as well then
crimes <- subset(crimes, POINT_X != "")

# Rename some columns so they make more sense
crimes <- rename(crimes, replace=c("Delito" = "Codigo"))
crimes <- rename(crimes, replace=c("Delitos_code" = "Delito"))

# Dealing with tildes
# Always a mess
agresion_corrected <- "Agresión Agravada"
Encoding(agresion_corrected) <- "UTF-8"
apropiacion_corrected <- "Apropiación Ilegal"
Encoding(apropiacion_corrected) <- "UTF-8"
vehiculo_corrected <- "Vehículo Hurtado"
Encoding(vehiculo_corrected) <- "UTF-8"
violacion_corrected <- "Violación"
Encoding(violacion_corrected) <- "UTF-8"
# Finally...
crimes$Delito <- revalue(crimes$Delito, c("Agresion Agravada" = agresion_corrected, "Apropiacion Ilegal" = apropiacion_corrected, "Vehiculo Hurtado" = vehiculo_corrected, "Violacion" = violacion_corrected))


crimes$Fecha <- as.Date(crimes$Fecha) # convert column to Date class

crimes$days <- weekdays(crimes$Fecha)# vector of "Wednesday" , "Saturday", ...

# Deal with errors in the hours...
# crimes_hours_function1
# About 4400 records were missing the seconds, i.e., they were given as "22:00" instead of "22:00:00"
# which 
# crimes_hours_function1 handles them
# crimes_hours_function2
# About ten records had time as "24:00:00"
crimes_hours_function1 <- function(hora) {if (nchar(as.character(hora)) < 6) paste(as.character(hora),":00", sep="") else as.character(hora)}
crimes_hours_function2 <- function(hora) {if (as.character(hora) == "24:00:00") "23:59:00" else if (as.character(hora) == "60:10:00") "06:10:00" else as.character(hora)}
crimes_hours <- sapply(crimes$Hora, crimes_hours_function1) %>% factor()
crimes_hours <- sapply(crimes_hours, crimes_hours_function2) %>% factor()
crimes$Hora <- crimes_hours

# crimes$Hora <- times(crimes$Hora)

# crimes_hours <- hours(crimes$Hora)

# hours_to_periods <- function(hour) {if (hour %/% 6 == 0) "early_morning" else if (hour %/% 6 == 1) "morning" else if (hour %/% 6 == 2) "afternoon" else "evening"}

# crimes$periods <- sapply(crimes_hours, hours_to_periods)