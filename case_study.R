#######################
### CASE STUDY INBO ###
#######################

# By Nick Dillen

# A recurring question you get from invasive species researchers is to produce a map or bar chart
# per year of known observations of Asian hornets (Vespa velutina) in Flanders. They typically
# want to filter this information on a year range.

## Data retrieval
# 1. To define a year range (e.g. 2019-2021).
# 2. To retrieve occurrences from the Global Biodiversity Information Facility (GBIF) for that
# year range of Vespa velutina in Flanders.


# Use R API for GBIF dataset
#install.packages("rgbif") # CRAN version
library(rgbif)

# Look up taxon key for "Vespa velutina"
taxonKey <- name_backbone("Vespa velutina")$usageKey
# Look up country code for Belgium, I did this manually
# enumeration_country()

caseStudyDf = occ_data(taxonKey = taxonKey,
                       country = "BE",
                       year = "2019,2021",
                       hasCoordinate =TRUE,
                       limit = 100000)

# Check data from FLANDERS only
# TODO!

# Quick and dirty: check $stateProvince
table(caseStudyDf$data$stateProvince, useNA = "ifany") 
# for this dataset we can manually make a list of Flanders provinces
flanders = c("Antwerp", "East Flanders", "Flemish Brabant", "Limburg", "Vlaanderen", "West Flanders")
dataFlanders = caseStudyDf$data[caseStudyDf$data$stateProvince %in% flanders,]

# Note, a lot of data has NA values for $stateProvince, this gets lost (887 records)

# 4. To present the result as a bar chart of observations per year.
# basic bar plot
year_table = table(dataFlanders$year)
barplot(year_table,
        main="Observations of Vespa velutina in Belgium from 2019 to 2021",
        xlab = "Year", ylab = "Observation count")

#map
library(geojsonio)
library(mapproj)
library(ggspatial)
library(sp)
library(broom)
library(ggplot2)
library(sf)
# download from https://gadm.org/
# ref; https://r-graph-gallery.com/168-load-a-shape-file-into-r.html
# https://r-spatial.org/r/2018/10/25/ggplot2-sf.html
spdf <- geojson_read("geojson/gadm41_BEL_2.json",  what = "sp")

# use SF as nicely integrated with ggplot
sfBE = st_as_sf(spdf)
sfFLanders = sfBE[sfBE$NAME_1 == "Vlaanderen",]
#Only retain Flanders
ggplot() + geom_sf(data = sfFLanders)

ggplot() +
  geom_sf(data = sfFLanders) +
  ggtitle("Vespa velutina observations in Flanders (2019-2021)") +
  xlab("Longitude") + ylab("Latitude") +
  geom_point(data = dataFlanders, aes(x = decimalLongitude, y=decimalLatitude)) +
  coord_sf(ylim = c(50.5, 51.6))+
  annotation_scale(location = "bl",width_hint = 0.2, pad_x = unit(2,"cm")) +
  theme_bw()

