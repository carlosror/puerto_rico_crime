library(shiny)
library(leaflet)
library(ggmap)
crimes_vector <- c("APROPIACIÓN ILEGAL" = "Apropiación Ilegal", "AGRESIÓN AGRAVADA" = "Agresión Agravada", "ESCALAMIENTO" = "Escalamiento",
                  "ROBO" = "Robo", "VEHÍCULO HURTADO" = "Vehículo Hurtado", "ASESINATO" = "Asesinato", "VIOLACIÓN" = "Violación",
                  "INCENDIO MALICIOSO" = "Incendio Malicioso", "TRATA HUMANA" = "Trata Humana", "OTROS" = "Otros")
crimes_checked <- c("Apropiación Ilegal", "Escalamiento", "Robo", "Vehículo Hurtado")
days_vector <- c("Domingo" = "Domingo", "Lunes" = "Lunes", "Martes" = "Martes", "Miércoles" = "Miércoles", "Jueves" = "Jueves", "Viernes" = "Viernes", "Sábado" = "Sábado")
days_checked <- c("Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado") 
periods_vector <- c("MEDIANOCHE - 6:00 A.M." = "madrugada", "6:00 A.M. - MEDIODÍA" = "mañana", 
                    "MEDIODÍA - 6:00 P.M." = "tarde", "6:00 P.M. - MEDIANOCHE" = "noche")
periods_checked <- c("madrugada", "mañana", "tarde", "noche")
plots_facets_vector <- c("día" , "período" , "crimen" )
years_vector <- c("2016", "2015", "2014", "2013", "2012")
# Will select one of the following locations at random
locations_vector <- c("Calle Acosta, Caguas, 00725, Puerto Rico", "Calle Sol, Ponce, PR", "Calle Méndez Vigo, Mayagüez, Puerto Rico", 
                      "Walmart Santurce, San Juan, Puerto Rico", "Avenida Ingeniero Manuel Domenech, San Juan, Puerto Rico",
                      "Calle Parque, Río Piedras, San Juan, Puerto Rico", "Calle Derkes, Guayama, Puerto Rico",
                      "Caguas Norte, Caguas, Puerto Rico", "Calle Cristo, Patillas, Puerto Rico", "Calle Georgetti, Manatí, Puerto Rico",
                      "Calle Betances, Arecibo, Puerto Rico", "Calle Del Carmen, Morovis, Puerto Rico", "Fajardo, PR", "Humacao, PR",
                      "Calle 4, Lares, Puerto Rico", "Calle Padre Feliciano, San Sebastián, Puerto Rico", "Levittown, Toa Baja, Puerto Rico",
                      "Calle Luna, San Juan, 00901, Puerto Rico", "Calle Baldorioty, Guaynabo, 00969, Puerto Rico", "Cayey, PR",
                      "Calle Rafael Laba, Aguas Buenas, Puerto Rico", "Calle Colon, San Lorenzo, PR", "Calle Corchado, Juncos, PR",
                      "Calle San José, Gurabo, PR", "Aguadilla, Puerto Rico", "Calle Juan Hernández, Isabela, Puerto Rico")
print(sample(locations_vector, size=1, replace=TRUE))
shinyUI(fluidPage(
  titlePanel(h3("Mapa del crimen en Puerto Rico"), windowTitle = "Mapa del crimen en Puerto Rico"),
  sidebarLayout (
    sidebarPanel(
           textInput("address",label=h4("Escriba una dirección o haga clic en el mapa"),
                     value=sample(locations_vector, size=1, replace=TRUE)),
           
           sliderInput("radius",label=h4("Radio en millas"),
                       min=0.5,max=2.0,value=0.5, step=0.5),
           actionButton("goButton", "Buscar", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
           selectInput("year", label = h4("Año"), years_vector, selected = "2015"),
           checkboxGroupInput("crimes", label = h4("Crímenes"), choices = crimes_vector, selected = crimes_checked, inline = TRUE),
           checkboxGroupInput("days_of_week", label = h4("Día de la semana"), choices = days_vector, selected = days_checked, inline = TRUE),
           checkboxGroupInput("time_periods", label = h4("Período"), choices = periods_vector, selected = periods_checked, inline = TRUE),
           selectInput("plots_facets", label = h4("Facetas para bar plot"), plots_facets_vector)
    ),
    mainPanel(
        tabsetPanel(
            tabPanel("Mapa", leafletOutput("map",width="auto",height="640px")),
            tabPanel("Data", dataTableOutput("DataTable")),
            tabPanel("Barplots", plotOutput("barplots", width = "auto", height="640px")),
            tabPanel("Mapas de densidad", plotOutput("density_maps", width = "auto", height="640px")),
            tabPanel("Resumen", tableOutput("summary")),
            tabPanel("Referencias", htmlOutput("references"))
            #tabPanel("Debug", verbatimTextOutput("debug"))
        )
    )
)))