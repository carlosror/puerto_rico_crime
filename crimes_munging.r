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
# Won't be using the crime code either
crimes$Delito <- NULL
# Or the Area.Policiaca
crimes$Area.Policiaca <- NULL

# Some of the rows have no location info, e.g.:
# 2016/01/09,16:24:00,6,Apropiacion Ilegal,,,,Utuado
# Remove them as well then
crimes <- subset(crimes, POINT_X != "")

# Rename some columns so they make more sense
crimes <- rename(crimes, replace=c("Delitos_code" = "categories"))
crimes <- rename(crimes, replace=c("POINT_X" = "latitude"))
crimes <- rename(crimes, replace=c("POINT_Y" = "longitude"))

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
crimes$categories <- revalue(crimes$categories, c("Agresion Agravada" = agresion_corrected, "Apropiacion Ilegal" = apropiacion_corrected, "Vehiculo Hurtado" = vehiculo_corrected, "Violacion" = violacion_corrected))


crimes$Fecha <- as.Date(crimes$Fecha) # convert column to Date class

crimes$days <- weekdays(crimes$Fecha)# vector of "Wednesday" , "Saturday", ...

# Change days of week to Spanish...
# First deal with tildes again...
miercoles <- "Miércoles"
Encoding(miercoles) <- "UTF-8"
sabado <- "Sábado"
Encoding(sabado) <- "UTF-8"
# Finally...
crimes$days <- revalue(crimes$days, c("Monday" = "Lunes", "Tuesday" = "Martes" , "Wednesday" = miercoles, "Thursday" = "Jueves", "Friday" = "Viernes", "Saturday" = sabado, "Sunday" = "Domingo"))


# Deal with errors in the hours...
# crimes_hours_function1
# About 4400 records were missing the seconds, i.e., they were given as "22:00" instead of "22:00:00"
# crimes_hours_function1 handles them
# crimes_hours_function2
# About ten records had time as "24:00:00" so crimes_hours_function2 changes them to 23:59:00 so hours() doesn't complain
# Also one record had 60:10:00 so changed it to 06:10:00, arbitrarily
crimes_hours_function1 <- function(hora) {if (nchar(as.character(hora)) < 6) paste(as.character(hora),":00", sep="") else as.character(hora)}
crimes_hours_function2 <- function(hora) {if (as.character(hora) == "24:00:00") "23:59:00" else if (as.character(hora) == "60:10:00") "06:10:00" else as.character(hora)}
crimes$Hora <- sapply(crimes$Hora, crimes_hours_function1) %>% factor()
crimes$Hora <- sapply(crimes$Hora, crimes_hours_function2) %>% factor()

crimes$Hora <- times(crimes$Hora)

crimes_hours <- hours(crimes$Hora)

# Determine periods as follows:
# Early Morning (before 6 AM): 0, Morning (between 6 AM and 12 PM): 1
# Afternoon (between noon and 6 PM): 2, Evening (between 6 PM and midnight): 3

# Deal with the "ñ" in "mañana"
manana <- "mañana"
Encoding(manana) <- "UTF-8"
hours_to_periods <- function(hour) {if (hour %/% 6 == 0) "madrugada" else if (hour %/% 6 == 1) manana else if (hour %/% 6 == 2) "tarde" else "noche"}
crimes$periods <- sapply(crimes_hours, hours_to_periods)

# Randomize the longitude and latitude to anonymize data

# The approach is to randomly add -0.0005 or 0.0005 to the longitude and latitude.
# This is equivalent to shifting the point by ~ 50 meters North or South and East or West.
# http://www.movable-type.co.uk/scripts/latlong.html
set.seed(567) #repeatability
num_samples <- length(crimes$longitude)
offset_vector <- c(-0.0005, 0.0005)
offsets_long <- sample(offset_vector, num_samples, replace = TRUE)
offsets_lat <- sample(offset_vector, num_samples, replace = TRUE)
crimes$longitude <- crimes$longitude + offsets_long
crimes$latitude <- crimes$latitude + offsets_lat

# Write to a csv which will be put in the shiny app folder
write.table(crimes, "crimes.csv", sep=",", row.names=FALSE, fileEncoding = "UTF-8")