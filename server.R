#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#load libraries
library(data.table)
library(shiny)
library(leaflet)
library(tidyr)
library(geosphere)

#load, clean Zip Code data
zipcodes <- read.csv(file = "zipcode-database.csv", header = TRUE)
zipcodes <- data.table(zipcodes)
zipcodes <- zipcodes[(Country == "US"),]
columns <- c("Zipcode", "Long", "Lat", "LocationText")
zipcodes <- zipcodes[,..columns]
names(zipcodes) <- c("ZipCode","Longitude","Latitude","Name")

#load, clean Airport data
airports <- read.csv(file = "airports.csv", header = TRUE)
airports <- data.table(airports)
airports <- airports[(iso_country == "US"),]
columns <- c("type","name","longitude_deg","latitude_deg")
airports <- airports[,..columns]
names(airports) <- c("Type","Name","Longitude","Latitude")
airports <- airports[
  !(Type == "closed"|Type == "heliport"|Type == "balloonport"|Type == "seaplane_base"),]

#check if valid zip code
valid <- function(zc){
  if(!(zc %in% zipcodes$ZipCode)) {
    return(paste0("Invalid US Zip Code!"))
  } else {
    return(paste0("Valid US Zip Code!"))
  }
}

#calculate top 10 closest airports given any US zip code
nearby_airports <- function(zc) { 
  user_coord <- unique(
    subset(zipcodes, ZipCode == zc, select = c("Longitude", "Latitude"), drop = TRUE))
  nearest <- airports
  nearest$distance <- c(distm(
    user_coord[,c("Longitude", "Latitude")],
    nearest[,c("Longitude", "Latitude")]))
  nearest <- nearest[order(distance),][1:10,]
  nearest$Name <- paste0("#", rank(nearest$distance), ": ", nearest$Name)
  nearest <- nearest[,c("Name", "Longitude", "Latitude")]
  return(nearest)
}

# Define server logic required to create app
shinyServer(
  function(input, output) {
  output$text <- renderText({
    input$goButton
    isolate(valid(input$ZipCode))
  })
  output$list <- renderDataTable({
    input$goButton
    isolate(nearby_airports(input$ZipCode))
  })
  output$map <- renderLeaflet({
    nrst <- nearby_airports(input$ZipCode)
    leaflet(data = nrst) %>% clearShapes() %>%
      addProviderTiles(
        providers$OpenStreetMap.BlackAndWhite,
        options = providerTileOptions()) %>%
      addTiles() %>% 
      addMarkers(lng = ~Longitude, lat = ~Latitude, popup = ~Name)
  })
}
)