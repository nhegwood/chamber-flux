# Naomi's attempt to create clean script

# Workflow for processing raw LGR/Picarro data and calculating
# chamber flux on different dates at different soil chambers

#-------Required libraries and functions----------
library(tidyverse)
library(lubridate)
library(data.table)

#set working directory
setwd("~/Stem_flux")

# Load local functions
#update this line with your local pathname
file_sources <- list.files("functions", pattern="*.R", full.names = TRUE)
sapply(file_sources, source, .GlobalEnv)

#-----------------------------------#
#-----------------------------------#
#----Prepare Date and Time Data------
#-----------------------------------#
#-----------------------------------#
# Load file with sampling dates and start times for flux measurements
# update with your local pathname
date_time <- read_csv("data/summer_2024.csv") %>%
  mutate(dates = lubridate::mdy(Date),
         UniqueID = paste(UniqueID),
         start_time = lubridate::ymd_hms(paste0(dates,comp_start_time)),
         end_time = lubridate::ymd_hms(paste0(dates,comp_end_time)),
         rep_vol_L = Rep_vol_L,
         soil_temp = `Soil temp`,
         real_start = `Real start`) %>%
  filter(!is.na(comp_start_time)) 
#UniqueID = paste(UniqueID) #trees
#UniqueID = paste(Tree_tag, Height, Type, repnumber),

# Clean up date_time dataframe by removing unnecessary columns
date_time <- date_time %>% 
  subset(select = c('UniqueID', 'start_time', 'end_time',
                    'rep_vol_L','dates','Tree','Vwc_avg',
                    'soil_temp','real_start'))


#-----------------------------------#
#-----------------------------------#
#---------Prepare Raw Data-----------
#-----------------------------------#
#-----------------------------------#
# File names for raw data from the LGR analyzer
# update this line with your local pathname
data_path <- "~/Stem_flux/data2" # local path to raw data
raw_files <- list.files(data_path, full.names=TRUE)

# load in example raw data files
conc_data <- format_LGR_output(data_path)


#-----------------------------------#
#-----------------------------------#
#------------Prepare Time Data------------
#-----------------------------------#
#-----------------------------------#
# necessary constants
lgr_volume <- .2 #.2 Liters

# calculate system volume and total mols in the system
# add surface area values
date_time <- date_time %>%
  mutate(vol_system = lgr_volume+rep_vol_L, # volume of LGR + chamber
         nmol = (739*vol_system)/(62.363577*298.15),
         # n = (P (mmHg AKA torr) * vol_system) / (R (L torr/kgmol)* T (Kelvin))
         surfarea = pi*(4*2.54/2)^2 / 100^2 #m^2, 4-inch pvc collars
         )

#-----------------------------------#
#-----------------------------------#
#-------Processing Settings----------
#-----------------------------------#
#-----------------------------------#
# Flux processing settings - change these for your application
init <- list()
init$plotslope <- 0 # make a plot with the slope: 0 = off, save images?? pdf (looP) dev.off
init$outputfile <- 1 # write an output file: 0 = off
init$outfilename <- "fluxdatamonthly.csv"


#-----------------------------------#
#-----------------------------------#
#----------Calculate Flux!-----------
#-----------------------------------#
#-----------------------------------#
# Calculate CO2 & CH4 flux for each measurement date
flux_data_monthly <- calculate_chamber_flux(conc_data, date_time, init)   
#dev.off()

test <- read_csv("output/fluxdatamonthly.csv")
