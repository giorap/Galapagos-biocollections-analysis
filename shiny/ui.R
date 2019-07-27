#######################################################
##### -- California Coast Explorer R Shiny App -- #####
#######################################################
################################
##### -- User Interface -- #####
################################

##### Load packages
library(shiny)
library(leaflet)
library(shinydashboard)
library(highcharter)
library(plotly)
library(shinycssloaders)
library(shinyWidgets)

##### Load static data
galapagos_occurrence_data <- readRDS("galapagos_occurrence_data.rds")

options(shiny.suppressMissingContextError = TRUE)

         navbarPage(title = "Galapagos Biocollections Dashboard", 
           windowTitle = "Galapagos Biocollections Dashboard", 
           id="nav", theme = "style.css",

           tabPanel("Gap Analysis", height = 750, div(class="outer", 
               tags$head(
                 # Include custom CSS
                 includeScript("gomap.js")
                 ),
                                               
               tags$style(type="text/css",
                          ".shiny-output-error { visibility: hidden; }",
                          ".shiny-output-error:before { visibility: hidden; }"),
          
                    fluidRow(
                      column(width = 6,
                             box(width = NULL, solidHeader = TRUE,
                                 leafletOutput("galapagos_map", height = 900) %>% withSpinner(type = 6, color="#33A1DE")      
                             )
                      ),
                      column(width = 6,
                             fluidRow(
                               column(12,
                                      br(),
                                      selectInput("institutionCode", label = "Select Institution: ", choices = c("All", unique(galapagos_occurrence_data$institutionCode))),
                                      plotlyOutput("galapagos_time_plot", height = 400) %>% withSpinner(type = 6, color="#33A1DE"),
                                      highchartOutput("galapagos_taxa_donut", height = 400) %>% withSpinner(type = 6, color="#33A1DE"))
                               )
                             )
                      )
                    )
           )
)
