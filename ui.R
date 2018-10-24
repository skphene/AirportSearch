#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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

# Define UI for application that displays table and map of nearby airports
shinyUI(
  pageWithSidebar(
    headerPanel("US Airport Search by Zip Code"),
    sidebarPanel(
      numericInput(inputId = "ZipCode", label = "Enter Valid US Zip Code", value = NULL),
      actionButton("goButton", "Go!")),
    mainPanel(
      textOutput("text"),
      tabsetPanel(
        tabPanel("List", dataTableOutput("list")),
        tabPanel("Map", leafletOutput("map"))
      )
    )
  )
)