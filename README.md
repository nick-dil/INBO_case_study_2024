Case study
===========
***For the position of Research Software Engineer (biologging - invasive species)***

As part of the job interview for the position of Research Software Engineer at EV INBO, we
would like you to prepare the following case study. The topic of the study is invasive species, but
the required skills apply to both biologging and invasive species.

## Description
A recurring question you get from invasive species researchers is to produce a map or bar chart
per year of known observations of Asian hornets (Vespa velutina) in Flanders. They typically
want to filter this information on a year range.

## Objectives
Create R code that allows:
1. To define a year range (e.g. 2019-2021).
2. To retrieve occurrences from the Global Biodiversity Information Facility (GBIF) for that
year range of Vespa velutina in Flanders.
3. To present the result as a map of observations.
4. To present the result as a bar chart of observations per year.
Your code should be documented and tested. Your code should be maintained on GitHub

## This repository
- `case_study.R` contains analysis of case study
- `case_study_lite.R` contains condensed version for quick analysis results
- `geojson/` directory to store geojson file(s)
- `output/` directory to store data products
