# map-el-salv-gsheet.r
# andy south 201907

# script to load data referenced by municipio from a googlesheet and make a map from them
# you should be able to edit data in the googlesheet and rerun to get a different map

# this could be first steps to a simple surveillance system

# next steps
# ODK form to modify the googlesheet
# shinyapp to allow replotting of map from the web
# add date column to the googlesheet

# possible to get shinyapp to check for changes in the gsheet ?
# but even as it is, is great



library(sf)
library(tidyverse)
library(tmap)
library(googledrive)



folder <- 'data\\'
# uses gadm polygons, there are also some local ones available that may be more accurate
poly_file <- paste0(folder,'gadm36_SLV_2.shp') #or could load data from GADM package

# read polygons into R
sfpolys <- sf::st_read(poly_file)

# url of googlesheet containing data referenced by municipio name
# should be able to go to this url and modify data to change the map 
gsheet_url <- "https://docs.google.com/spreadsheets/d/1C8RkT5XeD4F7gL35yJQzyxgrzvf1OymoZkO04ahOdjg/edit?usp=sharing"

# wow this worked and sorted authentication for me
# saves csv locally - but do I need to save, can I just read directly into R object ?
googledrive::drive_download("el-salvador-municipios-r-test", type = "csv",overwrite=TRUE)

#read data from the saved csv
df_munis <- read_csv("el-salvador-municipios-r-test.csv")


# join data to polygons
sfcases <- df_munis %>%
  left_join(sfpolys, by = c(Municipio = 'NAME_2')) %>%
  st_sf()

# static plot
# plot borders first then polygons with cases
tmap_mode(mode = "plot")
tmap::tm_shape(sfpolys) + tm_borders() +
  tm_shape(sfcases) + tm_polygons("dengue") 

# or create interactive plot (here via tmap, could use mapview too)
# popupvars show when you click on hover
tmap_mode(mode = "view")
tm <- tmap::tm_shape(sfpolys) + tm_borders() +
            tm_shape(sfcases) + tm_polygons("dengue", popup.vars = c("dengue","zika"))
            

print(tm)
