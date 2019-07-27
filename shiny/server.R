#######################################################
##### -- California Coast Explorer R Shiny App -- #####
#######################################################
########################
##### -- Server -- #####
########################

##### Load packages
library(shiny)
library(dplyr)
library(tidyr)
library(leaflet)
library(shinyLP)
library(highcharter)
library(plotly)
library(RColorBrewer)
library(magrittr)
library(sp)
library(raster)
library(ggmap)
library(htmlwidgets)
library(shinyWidgets)
library(shinyjs)

##### Load static data
galapagos_occurrence_data <- readRDS("galapagos_occurrence_data.rds")

#### Load custom functions
source("custom_functions.R")

#### Shiny app body
function(input, output, session) {
  
  filter_occurrence_data <- reactive({
    if (input$institutionCode == "All"){
      df <- galapagos_occurrence_data
      } else {
        df <- galapagos_occurrence_data %>%
          dplyr::filter(institutionCode == input$institutionCode)
        }
    return(df)
    })
    
  #### Generate map
  output$galapagos_map <- renderLeaflet({
    
    filtered_occurrence_data <- filter_occurrence_data()
    
    galapagos_occurrence_data_map(occurrence_data = filtered_occurrence_data)
    
  })

  output$galapagos_time_plot <- renderPlotly({
    
    filtered_occurrence_data <- filter_occurrence_data()
  
    plot_occurrence_data_over_time(occurrence_data = filtered_occurrence_data)
    
  })
  
  output$galapagos_taxa_donut <- renderHighchart({
    
    filtered_occurrence_data <- filter_occurrence_data()
    
    plot_taxa_donut(occurrence_data = filtered_occurrence_data)
    
  })
}