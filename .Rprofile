##### -- Load packages -- #####
my_packages <- c("dplyr", "magrittr", ### data manipulation
                 "rgbif", "rvertnet", ### data download
                 "sp", ### spatial
                 "leaflet", "plotly" ### interactive graphics
                 )
lapply(my_packages, require, character.only=T)

##### -- Load most recently cached .RData -- #####
### List all files in cache
cache_files <- list.files("cache", full.names = TRUE)
### Isolate dates from files names in cache
cache_dates <- as.numeric(regmatches(cache_files, gregexpr("[[:digit:]]+", cache_files)))
### Load most recently cached .RData
load(cache_files[which(cache_dates == max(cache_dates, na.rm = TRUE))])
            
##### -- Write function to chache working directory -- #####
cache_RData <- function(shorthand = "processing"){
save.image(paste("cache/", shorthand, "-", format(Sys.time(), "%m%d%y"), ".RData", sep = ""))  
}
