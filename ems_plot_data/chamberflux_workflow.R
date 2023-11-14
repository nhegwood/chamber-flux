# Workflow for processing raw LGR/Picarro data and calculating
# chamber flux on different dates at different soil chambers

library(tidyverse)
library(lubridate)

# Load local functions
file_sources <- list.files("R/functions/", pattern="*.R", full.names = TRUE)
sapply(file_sources, source, .GlobalEnv)

# File names for raw data from the LGR/Picarro analyzers
data_path <- "input/forecasting_raw_data/" # local path to raw data
raw_files <- list.files(data_path, full.names=TRUE)

# # Load file with sampling dates and start times for flux measurements
# FM test time file - Picarro
date_time <- read_csv("input/times_key2.csv") %>%
  mutate(dates = lubridate::ymd(Date),
    start_time = lubridate::ymd_hms(paste0(dates,start_time)),
    UniqueID = paste0(UniqueID,"-",lubridate::yday(dates))) %>%
  rename(rep_vol_L = Rep_vol_L) # might not need to rename if rep_vol_L in orig

# # JG test time file - LGR
# date_time <- read_csv("input/times_key_JGsubset.csv") %>%
#   mutate(dates = lubridate::ymd(Date),
#          UniqueID = paste(Plot,Tree_ID,`Measurement height`,
#                           `Chamber ID`),
#          start_time = lubridate::ymd_hms(paste0(dates,HMS_Start)),
#          end_time = lubridate::ymd_hms(paste0(dates,HMS_End)),
#          rep_vol_L = 0.3*0.001+ pi*0.00175^2*(1.62+1.70) + 0.0002 * 1000) %>%
#   filter(!is.na(start_time))

# Flux processing settings - change these for your application
init <- list()
init$analyzer <- "picarro" # can be "picarro" or "lgr"
init$data_path <- data_path # path to analyzer files
init$startdelay <- 20 # 20s delay for Picarro
init$fluxend   <- 3 # minutes to include data after start (will ignore if end times are in date_time)
init$surfarea  <- pi*(4*2.54/2)^2 / 100^2 #m^2, 4-inch pvc collars
init$vol_system <- 0.315 + 0.001 # interior volume of picarro = 0.0316 L 
init$plotslope <- 1 # make a plot with the slope: 0 = off
init$outputfile <- 1 # write an output file: 0 = off
init$outfilename <- "example5.csv"

# Calculate soil CO2 & CH4 flux for each measurement date & replicate
flux_data <- calculate_chamber_flux(raw_files, date_time, init)          

# AFTER THIS YOU CAN EDIT TO MERGE WHATEVER OTHER DATA YOU WANT
# by the UniqueID column
########
# Merge temperature & moisture dataset with clean flux data
temp_moist  <- read.csv("input/TF_insttempmoisture.csv", 
                        header=TRUE, stringsAsFactors = FALSE) 

temp_moist$date <- as.Date(temp_moist$date, "%m/%d/%y") %>% 
  format(.,"%Y-%m") %>% 
  as.character()

flux_env <- merge(flux_clean, temp_moist, by.x = c("fmonth", "fid"),
                     by.y = c("date","collar"), all=TRUE) 

