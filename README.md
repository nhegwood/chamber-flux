# chamber-flux
Code to calculate CO2 and CH4 flux from chamber flux measurements with a Picarro or Los Gatos Research (LGR) analyzer. 

Quick guide: 
* Use the chamberflux_workflow.R code to run the flux processing. This is where you'll read in your chamber ID, chamber volume, and start/end times file, and set parameters for your flux calculations (which analyzer, whether to write out a file, etc.)
* You should add your own raw data files from the analyzer into the input/ directory, and specify the path in the workflow.R file
* You will also need a times_key csv file that has: a date column, a unique ID column for each chamber measurement (UniqueID), chamber volume in L (rep_vol_L), a start time (start_time), and an optional end time (end_time). You can edit these in the workflow.R script to have those specific header names and to make sure that the data are in the right format before running the calculate_chamber_flux() function  
* The calculate_chamber_flux() function uses your times_key data frame and the init list of analysis parameters to format the raw Picarro or LGR files, match the start/end times for each replicate measurement, and calculates and returns the estimated CO2 and CH4 fluxes by linear regression. 
