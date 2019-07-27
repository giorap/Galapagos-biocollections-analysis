###################################################
##### -- Galapagos biocollections analysis -- #####
###################################################
################### FUNCTIONS #####################
galapagos_occurrence_data_map <- function(occurrence_data){
  
  points <- occurrence_data %>% 
    dplyr::select(decimalLongitude, decimalLatitude) %>%
    dplyr::filter(complete.cases(.)) %>%
    SpatialPoints(proj4string = CRS("+init=epsg:4326"))
  
  hexagons <- points %>%
    spsample(type="hexagonal", cellsize = 0.08) %>%
    HexPoints2SpatialPolygons()
  
  hex_over <- sp::over(points, hexagons)
  full_hexagons <- hexagons[as.numeric(na.omit(unique(hex_over)))]
  
  pid <- sapply(slot(full_hexagons, "polygons"), function(x) slot(x, "ID"))
  p.df <- data.frame(ID=1:length(full_hexagons), row.names = pid)
  full_hexagons <- SpatialPolygonsDataFrame(full_hexagons, p.df)
  proj4string(full_hexagons) <- CRS("+init=epsg:4326")
  points_over_hex <- sp::over(points, full_hexagons)
  full_hexagons@data$iNat_observation_count <- as.numeric(table(points_over_hex)[full_hexagons@data$ID])
  
  col_pal <- colorNumeric("Reds", log10(full_hexagons@data$iNat_observation_count), na.color = "transparent")
  
  hex_map <- leaflet() %>% 
    setView(median(-95.21191, -86.77441), median(-3.16245, 2.24942), zoom = 10) %>%
    fitBounds(-94.21191, -2.16245, -87.77441, 2.14942) %>%
    addProviderTiles(providers$Esri.DeLorme) %>%
    addPolygons(data = full_hexagons,
                layerId = ~ID,
                color = "#333333",
                fillColor = col_pal(log10(full_hexagons@data$iNat_observation_count)),
                fillOpacity = 0.7,
                smoothFactor = 0.5,
                weight = 0.9,
                highlightOptions = highlightOptions(color = "#999999", 
                                                    fillOpacity = 0.25, weight = 2, bringToFront = TRUE),
                label = paste(as.character(full_hexagons@data$iNat_observation_count), "records", sep = " "), labelOptions = labelOptions(textOnly = FALSE, direction = "right", textsize = "14px", sticky = FALSE, style = list("color" = "black")),
    ) %>%
    addLegend("topleft", 
              pal = col_pal,
              values = log10(full_hexagons@data$iNat_observation_count),
              title = "Occurrence <br> records",
              labFormat = function(type = "numeric", cuts){
                c("least", rep("", 3), "most")
              },
              labels = c("least", "", "", "", "most")
    )
 
  hex_map 
}

plot_occurrence_data_over_time <- function(occurrence_data, taxonomic_resolution = "class"){
  
  names(occurrence_data)[which(names(occurrence_data) == taxonomic_resolution)] <- "taxonomic_resolution"
  
  occurrence_data$taxonomic_resolution[is.na(occurrence_data$taxonomic_resolution) | occurrence_data$taxonomic_resolution == ""] <- "Other"
  
  occurrence_data_by_date <- occurrence_data %>%
    group_by(year, taxonomic_resolution) %>%
    summarise(count = n(), na.rm = TRUE) %>%
    dplyr::select(year, taxonomic_resolution, count) %>%
    as.data.frame()
  
  p <- plot_ly(occurrence_data_by_date, x = ~year) %>%
    add_bars(y = ~count, color = ~taxonomic_resolution, marker = list(size = length(unique(occurrence_data_by_date$taxonomic_resolution)), line = list(width = 12)), text= ~count, hoverinfo = 'text') %>%
    config(displayModeBar = FALSE) %>%
    layout(
      xaxis = list(
        barmode = "stack",
        range = c(min(occurrence_data_by_date$year), max(occurrence_data_by_date$year)),
        rangeselector = list(enabled = FALSE),
        rangeslider = list(type = "date", 
                           font = list(family = "Helvetica", size = 13),
                           bgcolor = grey(0.9)),
        tickfont = list(family = "Helvetica", size = 14),
        ticklen = 8,
        tickcolor = "white",
        title = ""
      ),
      yaxis = list(title = "Number of occurrence records", 
                   titlefont = list(family = "Helvetica", size = 14), 
                   tickfont = list(family = "Helvetica", size = 14)),
      legend = list(font = list(family = "Helvetica", size = 13)
      )
      
    )
  
  p
}
  
  
  plot_taxa_donut <- function(occurrence_data, taxonomic_resolution = "class"){
    
    names(occurrence_data)[which(names(occurrence_data) == taxonomic_resolution)] <- "taxonomic_resolution"
    
    occurrence_data$taxonomic_resolution[is.na(occurrence_data$taxonomic_resolution) | occurrence_data$taxonomic_resolution == ""] <- "Other"
    
    plot_data <- occurrence_data %>%
      group_by(taxonomic_resolution) %>%
      summarize(count = n())
    
    highchart() %>%
      hc_title(text = paste0(nrow(occurrence_data), " records"),
               verticalAlign = "middle",
               margin = 20,
               style = list(color = "#144746", fontSize = "17px", fontFamily = "Helvetica", useHTML = TRUE)) %>%
      hc_chart(type = "pie") %>%
      hc_add_series_labels_values(labels = plot_data$taxonomic_resolution, 
                                  dataLabels = list(style = list(fontSize = "12px", fontFamily = "Helvetica")),
                                  values = plot_data$count, 
                                  name = "Species", 
                                  innerSize = "80%") 

}
