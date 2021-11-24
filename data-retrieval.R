###################################################
## data retreival for exploring census data ##
###################################################

rm(list=ls())

## import libraries
library(tidyverse)
library(tidycensus)
options(tigris_use_cache = TRUE)
library(sf)
library(tmap)

#define data directory
datadir <- file.path('/Users/dhardy/Dropbox/r_data/census-explorer')

## define equal area projection for area estimates
alb <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-84 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" ## http://spatialreference.org/ref/sr-org/albers-conic-equal-area-for-florida-and-georgia/

## define census year, geography, & variables
DAT <- 'pl'
YR <- 2020
ST <- c('GA')
CNTY <- c('Chatham')
# VAR = c(white = "B03002_003E", black = "B03002_004E",
#         native_american = "B03002_005E", asian = "B03002_006E",
#         hawaiian = "B03002_007E", other = "B03002_008E",
#         multiracial = "B03002_009E", latinx = "B03002_012E", total = "B03002_001E",
#         medhhinc = "B19049_001E", agghhinc = "B19025_001E", hu = "B25001_001E")

dat <- load_variables(YR, DAT)

## get county level data
cnty<- get_acs(geography = "county",
               variables = VAR,
               state = ST,
               county = CNTY,
               year = YR,
               output = 'wide',
               geometry = TRUE,
               keep_geo_vars = TRUE)

## get block group data 
bg <- get_decennial(geography = "block",
                 variables = 	'P1_001N',
                 state = ST,
                 county = CNTY,
                 year = YR,
                 output = 'wide',
                 geometry = TRUE,
                 keep_geo_vars = TRUE)

## tidy BG census data
bg2 <- bg %>%
  st_sf() %>%
  st_transform(alb) %>%
  mutate(sqkm_bg = as.numeric(st_area(geometry)) / 1e6, mnhhinc = agghhinc/hu,
         propPOC = 1 - (white/total)) %>%
  dplyr::select(GEOID, ALAND, AWATER, sqkm_bg, total, white, black, native_american, asian, hawaiian,
                other, multiracial, latinx, propPOC, medhhinc, agghhinc, hu, mnhhinc) %>%
  filter(GEOID != 130519900000)

## quick map of census data
tm_shape(bg2) + 
  tm_polygons(col = 'propPOC')

## interactive map of census data
tmap_mode(mode = c('view'))
tm_shape(bg) + 
  tm_polygons(col = 'P1_001N')