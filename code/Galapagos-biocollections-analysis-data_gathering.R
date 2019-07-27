###################################################
##### -- Galapagos biocollections analysis -- #####
###################################################
################## GATHER DATA ####################
##### -- Cal Academy -- #####
### Only queriable via Monarch at https://monarch.calacademy.org/collections/misc/collprofiles.php
### Search: "State/Province: Galapagos"

##### -- Vertnet -- #####
### Search URL: http://portal.vertnet.org/search?q=Galapagos+OR+Gal%C3%A1pagos
### This search will send the full result via email
vertnet_records <- bigsearch("Galápagos OR Galapagos", 
                             rfile = "vertnet_galapagos_occurrence_records",
                             email = "giorapac@gmail.com"
                             )

##### -- GBIF -- #####
#### Search URL: https://www.gbif.org/occurrence/search?state_province=galapagos
gbif_records <- occ_search(stateProvince = "Galapagos",
                           limit = 199999)

################## PROCESS DATA ###################
##### -- Cal Academy -- #####
### Load data
cas_occurrence_data <- read.csv("data/cas_galapagos_occurrence_data.csv", header = TRUE, stringsAsFactors = FALSE)
### Filter data
cas_occurrence_data <- cas_occurrence_data %>% 
  dplyr::filter(!(collectionCode == "FOSSIL")) %>% ## Filter out fossil data
  dplyr::select(institutionCode, collectionID, occurrenceID, taxonRank, kingdom, phylum, class, order, family, genus, scientificName, locality, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, eventDate, day, month, year, basisOfRecord) ## Select useful fields

##### -- Vertnet -- #####
### Load data
vertnet_occurrence_data <- read.delim("data/vertnet_galapagos_occurrence_records-16b4415d0478437d9b6399640f197d3a.txt", header = TRUE, stringsAsFactors = FALSE)
### Filter data
vertnet_occurrence_data <- vertnet_occurrence_data %>% 
  dplyr::filter(!(institutioncode == "CAS")) %>% ## Filter out all CAS occurrences
  dplyr::select(institutioncode, gbifdatasetid, catalognumber, taxonrank, kingdom, phylum, class, order, family, genus, scientificname, locality, decimallatitude, decimallongitude, coordinateuncertaintyinmeters, eventdate, day, month, year, basisofrecord) ## Select useful fields
### Match CAS names
names(vertnet_occurrence_data) <- names(cas_occurrence_data)

##### -- GBIF -- #####
### Load data
gbif_occurrence_data <- read.delim("data/gbif_galapagos_occurrence_data.csv", header = TRUE, stringsAsFactors = FALSE)
### Filter out all CAS, CDF, citizen science-based, and fossil occurrences
gbif_occurrence_data <- gbif_occurrence_data %>%
  dplyr::filter(!(institutionCode %in% c("CAS", "iNaturalist", "CLO", "Natusfera", "Pangaea", "CDF"))) %>%
  dplyr:: filter(!(basisOfRecord %in% c("FOSSIL_SPECIMEN", "MACHINE_OBSERVATION", "UNKNOWN"))) %>%
  dplyr::select(institutionCode, datasetKey, occurrenceID, taxonRank, kingdom, phylum, class, order, family, genus, scientificName, locality, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, eventDate, day, month, year, basisOfRecord)
### Match CAS names
names(gbif_occurrence_data) <- names(cas_occurrence_data)

################# INTEGRATE DATA ##################
### Merge datasets
galapagos_occurrence_data <- rbind(cas_occurrence_data, vertnet_occurrence_data, gbif_occurrence_data)
### Update fields
galapagos_occurrence_data$decimalLongitude <- galapagos_occurrence_data$decimalLongitude %>% as.numeric()
galapagos_occurrence_data$decimalLatitude <- galapagos_occurrence_data$decimalLatitude %>% as.numeric()

### Remove duplicates
galapagos_occurrence_data <- galapagos_occurrence_data %>% 
  dplyr::filter(!(galapagos_occurrence_data %>% 
                  dplyr::select(institutionCode, collectionID, occurrenceID, scientificName, decimalLatitude, decimalLongitude, eventDate) %>%
                  duplicated()
                  )
                )

### Filter by bounding box
galapagos_occurrence_data <- galapagos_occurrence_data %>%
  dplyr::filter(decimalLongitude <= -87.77441 & decimalLongitude >= -94.21191) %>%
  dplyr::filter(decimalLatitude <= 2.14942 & decimalLatitude >= -2.16245) 





