#######################
### CASE STUDY INBO ###
####################### 
# By Nick Dillen

# Required packages
# Use `install.packages("<package name>")` if not installed
library(rgbif)
library(geojsonio)
library(ggplot2)
library(sf)
library(ggspatial)
library(leaflet)


#####
# ASSIGNMENT:
# A recurring question you get from invasive species researchers is to produce a map or bar chart
# per year of known observations of Asian hornets (Vespa velutina) in Flanders. They typically
# want to filter this information on a year range.

#####
# DATA ACQUISITION
# 1. To define a year range (e.g. 2019-2021).
# 2. To retrieve occurrences from the Global Biodiversity Information Facility (GBIF) for that
# year range of Vespa velutina in Flanders.


# Use R API for GBIF dataset: rgbif
# First look up taxon key for "Vespa velutina"
taxonKey <- name_backbone("Vespa velutina")$usageKey
# Look up country code for Belgium, I did this manually from:
# enumeration_country() #-> "BE"

# Get data from GBIF. NOTE!: For serious research projects use rgbif::occ_download()
caseStudyData = occ_data(taxonKey = taxonKey,
                       country = "BE",
                       year = "2019,2021",
                       hasCoordinate =TRUE,
                       limit = 100000)

# SELECT DATA FROM FLANDERS ONLY
# Quick and dirty approach: use the $stateProvince column to make a selection of the data for "Vlaanderen" only
table(caseStudyData$data$stateProvince, useNA = "ifany") 
# for this dataset we can manually make a list of Flanders provinces based on table above
flanders = c("Antwerp", "East Flanders", "Flemish Brabant", "Limburg", "Vlaanderen", "West Flanders")
# Then make a slice to only include entries from Flanders
dataFlanders = caseStudyData$data[caseStudyData$data$stateProvince %in% flanders,]
print(nrow(dataFlanders))
# [1] 2124

# Note, a lot of observations have NA for $stateProvince (887 records), this data would be excluded even if
# it would have coordinates in Flanders.
# A more robust way to detect observations in Flanders might be to check coordinates against a Flanders polygon.
# You can download that shape data from https://gadm.org/ -> Belgium (level 1 or greater)
# References used;
# https://r-graph-gallery.com/168-load-a-shape-file-into-r.html
# https://r-spatial.org/r/2018/10/25/ggplot2-sf.html

# Download and unzip geojson data from GADM. Check that you are working in source file directory #getwd()
temp = tempfile()
download.file("https://geodata.ucdavis.edu/gadm/gadm4.1/json/gadm41_BEL_2.json.zip", temp)
dir.create("geojson")
unzip(temp, exdir = "geojson/")
unlink(temp)
# set working directory accordingly to read in geojson data downloaded from GADM
spBE <- geojson_read("geojson/gadm41_BEL_2.json",  what = "sp")
# Quick plot to check we have what we need
# plot(spBE)

# use SF as it facilitates using ggplot later on
sfBE = st_as_sf(spBE)
#Only retain Flanders
sfFLanders = sfBE[sfBE$NAME_1 == "Vlaanderen",]
# ggplot() + geom_sf(data=sfFLanders)

# Now we can filter the observation data to exclude entries with coordinates that are outside of the Flanders polygon
# Convenient way to do this is by also converting the data to an sf object
dataBE = st_as_sf(caseStudyData$data, coords = c("decimalLongitude","decimalLatitude"))
# set CRS to WGS 84
st_crs(dataBE) = st_crs(sfFLanders)
# and finally filter data based on 'sfFlanders' polygon. NOTE: this overwrites the data in 'dataFlanders'
dataFlanders = st_filter(dataBE, sfFLanders)
print(nrow(dataFlanders))
# [1] 2148

# We gained 2148-2124=24 data points, but is this correct? (see #Extra below)
# Also note that this code can be rerun and will (generally) be able to identify data points from Flanders
# even if other languages or spelling are used in the $stateProvince column 

#####
# DATA VISUALISATION
# A. To present the result as a bar chart of observations per year.
# basic bar plot from tabulation of $year
year_table = table(dataFlanders$year)
barplot(year_table,
        main="Observations of Vespa velutina in Belgium from 2019 to 2021",
        xlab = "Year", ylab = "Observation count")

# B. To present the result as a map of observations
# We build a ggplot object with the Flanders polygon and plot the observations
# from our selected data as points
vvmap = ggplot() +
  geom_sf(data = sfFLanders) +
  geom_sf(data = dataFlanders, shape=1) +
  ggtitle("Vespa velutina observations in Flanders (2019-2021)") +
  xlab("Longitude") + ylab("Latitude") +
  coord_sf(ylim = c(50.5, 51.6)) +
  annotation_scale(location = "bl",width_hint = 0.2, pad_x = unit(2,"cm")) +
  theme_bw()

vvmap

# We can also make an interactive map with leaflet, a lot of options here, would depend on the research question.
# I chose to include the $occurrenceRemarks and $year data to give a little bit more info about the data points.
# If you click on an observation in the leaflet map a popup should appear with the appropriate text.
# A white stroke corresponds to markers with a non-NA (i.e. interesting) remark.

leaflet(data=dataFlanders) %>% addTiles() %>%
  addCircleMarkers(stroke = ~!is.na(occurrenceRemarks),
                   fillOpacity = 0.5,
                   opacity = 0.5 ,
                   fillColor  = 'navy',
                   color = 'white',
                   popup = ~paste0(year, " - ",occurrenceRemarks))



#####
# Extra
# We can do a small check of the observations with possible "mislabeled" $stateProvince. This is easier in leaflet
# because its interactive and you can zoom in.
table(dataFlanders$stateProvince, useNA = "ifany")
# some (4) "Waalse" observations and 24 'NA' are detected as observations from Flanders
# We could call these points "False Negatives" if we assume the more "robust" method used above as truth (spoiler: its not)
FNdata = dataFlanders[!dataFlanders$stateProvince %in% flanders,]
# but also the other way around, points labelled as "vlaanderen" but coordinates outside the Flanders polygon exist.
# Call them "False Positives".
FPdata = st_as_sf(
  caseStudyData$data[caseStudyData$data$stateProvince %in% flanders & !caseStudyData$data$key %in% dataFlanders$key,],
  coords = c("decimalLongitude","decimalLatitude")
)
st_crs(FPdata) = st_crs(sfFLanders)



# visualize predicted FN and FP on map. Also load polygon of Belgium to verify.
leaflet(sfBE) %>% addTiles() %>% addPolygons(stroke = TRUE, 
                                             label = ~paste(NAME_2)
                                             ) %>%
  addCircleMarkers(data = FPdata, stroke = FALSE, fillOpacity = 0.5, color='red',
                   label=~paste0(stateProvince)) %>%
  addCircleMarkers(data = FNdata, stroke = FALSE, fillOpacity = 0.5, color='black', label=~paste0(stateProvince))
  

## !ATTENTION! it seems that the Flanders polygon is low resolution, resulting in some false positives/negatives when 
# using it to select data from Flanders only! Everything with an nonNA $stateProvince is correctly labeled. 
# But there are also some observations the have an NA $stateProvince that should be in the Flanders selection. 
# We need to get a higher res shape of the Belgian regions to resolve this correctly.
# For now I would just work with the "quick and dirty" approach of filtering Flanders data as it yields only 
# "True Positive" Flanders observations (but it misses some point with NA vale in $stateProvince)

  
 
