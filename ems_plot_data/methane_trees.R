library(tidyverse)
library(here)
library(dplyr)
library(rgdal)

# load in archive data
treedat <- read_csv("GitHub/Dendrometer/2022_archive/ems-tree-summ.csv")

# remove dead trees
treedat <- filter(treedat, tree_type != 'dead')

# rename columns
treedat <- treedat %>%
  rename('dbh' = 'dbh_cm',
         'basal_area' = 'basal_area_cm2',
         'kgc' = 'biomass_kgc')

# read in collared trees file
collars <- read_csv("GitHub/Dendrometer/collared_trees.csv")

# create plottag column
collars <- collars %>% 
  mutate(plottag = paste(Plot, Tag, sep = "-"))

# subset treedat to only include methane trees
methane <- subset(treedat, plottag %in% collars$plottag)

# export as a csv
write_csv(methane, "GitHub/Dendrometer/collared_trees_ems.csv")
