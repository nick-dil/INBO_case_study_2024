### Condensed version of the source code for the INBO case study
# author: Nick Dillen

#Load required libraries
library(rgbif)
library(geojsonio)
library(ggplot2)
library(sf)

# 1. Preparation
# download Asian hornet data from GBIF for period 2019-2021
caseStudyData = occ_data(scientificName = "Vespa velutina" ,
                         country = "BE",
                         year = "2019,2021",
                         hasCoordinate =TRUE,
                         limit = 5000)

# Define what strings in $stateProvince column are part of Flanders
flanders = c("Antwerp", "East Flanders", "Flemish Brabant", "Limburg", "Vlaanderen", "West Flanders")
# Use this to filter only observations from Flanders
dataFlanders = caseStudyData$data[caseStudyData$data$stateProvince %in% flanders,]
# Read in pre-downloaded geojson of Belgian polygon (check GADM) and convert into SF object
sfBE <- st_as_sf(geojson_read("geojson/gadm41_BEL_2.json",  what = "sp"))
#Only retain Flanders polygon
sfFLanders = sfBE[sfBE$NAME_1 == "Vlaanderen",]

# 2. Visualization/Results
# Simple barplot to show number of observations per year, save in output dir make.dir("output)
jpeg("output/case_study_Vespa_barplot.jpg")
barplot(table(dataFlanders$year),
        main="Observations of Vespa velutina in Flanders from 2019 to 2021",
        xlab = "Year", ylab = "Observation count")
dev.off()

# Simple map where observations are plotted against a polygon of Flanders
vvmap = ggplot() +
  geom_sf(data = sfFLanders) +
  geom_point(data = dataFlanders, aes(x=decimalLongitude, y=decimalLatitude), shape=1) +
  ggtitle("Vespa velutina observations in Flanders, BE (2019-2021)") +
  xlab("Longitude") + ylab("Latitude") +
  coord_sf(ylim = c(50.5, 51.6)) +
  theme_bw()

# save in output dir
ggsave("output/case_study_Vespa_map.jpg", vvmap, dpi=600)
