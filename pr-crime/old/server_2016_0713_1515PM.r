#########################
# To run in RStudio: 
# library(shiny)
# library(leaflet)
# runApp("shiny")
#########################

library(shiny)
library(ggplot2)
library(ggmap)
library(leaflet)
library(chron) # for dealing with chronological objects

shinyServer(function(input, output, session) {
    
    
    # Render Leaflet map
    # http://rstudio.github.io/leaflet/
    dataClicked <- reactiveValues()
    filter_data <- reactive({
        input$goButton
        calls <- read.csv("crimes.csv")
        
        # vector of coordinates c(long, lat) from user input
        # using <<- makes the variable global
        location <<- isolate(as.numeric(geocode(input$address, source="google"))) 
        # vector of crime types from user, e.g., c("arson", "assault", "battery", ...)
        # they are the crime types selected by the user
        crimes_set <- isolate(input$crimes)
        # vector of days of week selected by user, e.g., c("weekday"), or c("weekday", "weekend"), or c("weekend")
        crimes_days <- isolate(input$days_of_week)
        print(crimes_days)
        # vector of crime periods, e.g., c("early_morning", "morning", "afternoon", "evening"), or some combination thereof
        crimes_periods <- isolate(input$time_periods)
        # year
        crimes_year <- isolate(input$year)
        # Call function to filter data based on user inputs
        filtered_data <- data_filter(calls, location, crimes_set, crimes_days, crimes_periods, crimes_year)
        # print(table(filtered_data$periods))
        # print(str(filtered_data$periods))
        # print(levels(filtered_data$periods))
        # print(table(filtered_data$days))
        # print(unique(filtered_data$crimes_periods))
        # Order the levels of the periods and days factors
        # levels(filtered_data$periods) <- c("early_morning", "morning", "afternoon", "evening")
        # filtered_data$periods <- factor(filtered_data$periods, labels = c("Early AM", "Morning", "Afternoon", "Evening"))
        # print(table(filtered_data$days))
        # print(table(filtered_data$periods))
        # levels(filtered_data$days) <- c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
        # Re-order factors so that days appear in order:
        # http://www.r-bloggers.com/reorder-factor-levels-2/
        filtered_data$days <- factor(filtered_data$days, levels(filtered_data$days)[c(1, 3:5, 2, 7, 6)])
        filtered_data$periods <- factor(filtered_data$periods, levels(filtered_data$periods)[c(2, 4, 1, 3)])
        # print(table(filtered_data$days))
        # print(table(filtered_data$periods))
                
        filtered_data
    })
    
    dist_equi <- function (long1, lat1, long2, lat2) {
        # Equirectangular approximation of distance between 2 points
        # http://www.movable-type.co.uk/scripts/latlong.html
        # Not as accurate as Haversine or Spherical Law of Cosines methods but
        # for intra-city distance computations is good enough, I think,
        # and much less computationally intensive.
        
        R = 6371000 # radius of the Earth
        
        # Convert latitudes to radians
        theta1 = lat1 * pi / 180.0
        theta2 = lat2 * pi / 180.0
        
        # Compute difference between two points and convert to radians
        # delta_theta = (lat2 - lat1) * pi / 180.0 
        delta_theta = theta2 - theta1
        delta_lambda = (long2 - long1) * pi / 180.0
        
        x = delta_lambda * cos((theta1 + theta2)/2.0)
        y = delta_theta
        
        # Compute distance, convert it to miles and return it
        return(R * sqrt(x*x + y*y) / 1609.34)
    }
    
    data_filter <- function(calls, location, crimes_set, crimes_days, crimes_periods, crimes_year) {
        ###################################################################################################################################
        # Function that subsets a calls data frame based on the user inputs
        # 
        # Inputs:
        # calls: a data frame of police calls
        # location: vector of coordinates c(long, lat) from user input
        # crimes_set: vector of crime types from user, e.g., c("arson", "assault", "battery", ...)
        # crimes_days: vector of days of week selected by user, e.g., c("weekday"), or c("weekday", "weekend"), or c("weekend")
        # crimes_periods: vector of crime periods, e.g., c("early_morning", "morning", "afternoon", "evening"), or some combination thereof
        # 
        # Outputs:
        # relevant_data, a subset of the original calls data frame
        ###################################################################################################################################
        # Filter by year
        relevant_data <- subset(calls, years(Fecha) == crimes_year)
        # Filter by crime types
        relevant_data <- subset(relevant_data, categories %in% crimes_set) 
        # Filter by days of week
        # print(str(relevant_data))
        relevant_data <- subset(relevant_data, days %in% crimes_days)
        # Filter by day period
        relevant_data <- subset(relevant_data, periods %in% crimes_periods) 
        # Filter by distance:
        relevant_data <- subset(relevant_data, (dist_equi(location[1], location[2], longitude, latitude) < isolate(input$radius))) 
        relevant_data
    }
    # Render Leaflet map
    # http://rstudio.github.io/leaflet/
    output$map<-renderLeaflet({
        input$goButton
        # Fetch relevant data
        relevant_data <- filter_data()
        
        # Use some of the columns as markers for the leaflet() function
        relevant_data_markers <- relevant_data[c("Fecha", "Hora", "longitude", "latitude", "categories")]
        zoom_value <- isolate(if (input$radius == 0.5) 15 else if (input$radius <= 1.5) 14 else 13) # set map zoom based on user-selected radius
        # Generate map
        leaflet(data = relevant_data_markers) %>% addTiles() %>% addMarkers(~longitude, ~latitude, popup=~paste("<b style='color:DarkRed;'>Event:</b>", categories, "<b style='color:DarkRed;'>Fecha y Hora:</b>", Fecha, sep = "<br/>"), clusterOptions = markerClusterOptions()) %>% setView(location[1], location[2], zoom=zoom_value) %>% addCircles(lng = location[1], lat =location[2], radius = isolate(input$radius) * 1609.34)
    })
    observeEvent(input$map_click,{
               dataClicked$clickedMap <- input$map_click
               # print(dataClicked$clickedMap$lat)
               # print(dataClicked$clickedMap$lng)
               lat_clicked <- dataClicked$clickedMap$lat
               lng_clicked <- dataClicked$clickedMap$lng
               updateTextInput(session, inputId = "address", value=paste(lat_clicked, ",", lng_clicked))
               }
               )
    output$DataTable <- renderDataTable({
        # Fetch relevant data
        relevant_data <- filter_data()
        
        # Use relevant columns for table
        relevant_data_table <- relevant_data[c("event_time", "reason", "categories", "days")]
        relevant_data_table
    })
    # Render barplots
    # "R in a Nutshell, Second Edition", Chapter 15
    output$barplots <- renderPlot({
        # Fetch relevant data
        relevant_data <- filter_data()
        # print(table(relevant_data$days))
        # Find out top crime categories, will plot top 6 only
        categories_table_sorted <- table(relevant_data$categories) %>% sort(decreasing = TRUE)
        categories_top <- names(categories_table_sorted)
        relevant_data <- subset(relevant_data, categories %in% categories_top[1:6])
        
        # Use ggplot2's qplot to plot using days of week as facets
        # qplot(x=days, data=relevant_data, geom = "bar", fill=categories, position = "dodge", ylab = "Police calls") + facet_grid(periods ~.)
        
        crime_barplot <- ggplot(data = relevant_data) + ggtitle(paste("Number of police calls in", isolate(input$year), "faceted by", isolate(input$plots_facets[1]))) # basic plot + title
        # Arrange variables in the barplot according to user-selected facets
        crime_barplot <- if (isolate(input$plots_facets[1]) == "crime category") crime_barplot + geom_bar( aes(x = periods, fill = days), position="dodge") + facet_grid( categories~. ) 
                         else if (isolate(input$plots_facets[1]) == "day of week") crime_barplot + geom_bar( aes(x = periods, fill = categories), position="dodge") + facet_grid( days~. ) 
                         else crime_barplot + geom_bar( aes(x = days, fill = categories), position="dodge") + facet_grid( periods~. )
        # Format plot text using theme()
        crime_barplot + theme(plot.title = element_text(size = 24, face = "bold"), strip.text = element_text(size = 14), axis.title.x = element_blank(), axis.title.y = element_blank())
    })
    # Summary table
    output$summary <- renderTable({
        # Fetch relevant data
        relevant_data <- filter_data()
        
        relevant_data$categories <- as.character(relevant_data$categories) #converts from factor levels characters for tabulation
        
        summary_table <- table(relevant_data$categories, relevant_data$periods)
        summary_table
    })
    # Render barplots
    # "R in a Nutshell, Second Edition", Chapter 15
    output$density_maps <- renderPlot({
        # Fetch relevant data
        relevant_data <- filter_data()
        
        # Find out top crime categories, will plot top 6 only
        categories_table_sorted <- table(relevant_data$categories) %>% sort(decreasing = TRUE)
        categories_top <- names(categories_table_sorted)
        relevant_data <- subset(relevant_data, categories %in% categories_top[1:6])
        
        zoom_value <- if (input$radius == 0.5) 15 else if (input$radius <= 1.5) 14 else 13 # set map zoom based on user-selected radius
        
        
        location_map <- get_map(location = input$address, source= "google", zoom = zoom_value + 1, color = "color") %>% ggmap(extent = "panel")
        # location_map
        # ggmap(location_map, extent = "panel")
        # location_map <- qmap(input$address,  zoom = zoom_value, color = "bw", source = "osm", extent = "panel")
        # location_map + geom_point(aes(x = longitude, y = latitude, color = categories), data = relevant_data, size = 3) + facet_wrap(~ periods)
        location_map <- location_map + stat_density2d(aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..), bins = 20, geom = "polygon", data = relevant_data) + scale_fill_gradient(low = "yellow", high = "red") 
        location_map <- if (input$plots_facets[1] == "crime category") location_map + facet_wrap(~ categories) else if (input$plots_facets[1] == "day of week") location_map + facet_wrap(~ days) else location_map + facet_wrap(~ periods)
        location_map <- location_map + theme(plot.title = element_text(size = 24, face = "bold"), strip.text.x = element_text(size = 16), legend.position = "none", axis.text.x = element_blank(), axis.title.x = element_blank(), axis.ticks.x = element_blank(),  axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())
        location_map + ggtitle(paste(input$year, "Density maps faceted by", input$plots_facets[1]))
        # location_map + stat_density2d(aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..), bins = 5, geom = "polygon", data = relevant_data) + facet_wrap(~ categories) + theme(legend.position = "none")
        
        # location_map + geom_point(aes(x = location[1], y = location[2], color = categories), data = relevant_data)
    })
    output$references <- renderUI({includeHTML("References.html")})
    output$debug <- renderPrint({
        # updateTextInput(session, inputId = "address", value=paste(lat_clicked, ",", lng_clicked))
        unique(filtered_data$crimes_periods)
    })
    
    
})