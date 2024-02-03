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

# 4. To present the result as a bar chart of observations per year.
# basic bar plot
year_table = table(caseStudyDf$data$year)
barplot(year_table,
        main="Observations of Vespa velutina in Belgium from 2019 to 2021",
        xlab = "Year", ylab = "Observation count")

#map
library(geojsonio)
library(sp)
library(broom)
spdf <- geojson_read("geojson/gadm41_BEL_1.json",  what = "sp")
plot(spdf)
newdf =tidy(spdf)

ggplot() +
  geom_polygon(data = newdf, aes( x = long, y = lat, group = group), fill="white", color="grey") +
  geom_point(data = caseStudyDf$data, aes(x = decimalLongitude, y=decimalLatitude))

ggplot(caseStudyDf$data, aes(x = decimalLongitude, y=decimalLatitude)) + geom_point() +geom_ma

