###Marwa Al Arab###
# # # # # # # # # # # # # # # # # # # # #
# This script:
#reads in the study_definit_prelim
# output and return index dates for 
#study_definition_vaccinated and 
#study_definition_unvaccinated
# # # # # # # # # # # # # # # # # # # # #

#Load libraries using pacman
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,tictoc,purrr,lubridate,glue,tidyverse,jsonlite,here)


#json file containing vax study dates
study_dates <- fromJSON("output/vax_study_dates.json")
delta_date <- study_dates$delta_date

#Read in the output of study_definition_prelim
prelim_data <- arrow::read_feather("output/input_prelim.feather") %>%
  # Because date types are not returned consistently by cohort extractor (Elsie)
  mutate(across(c(contains("_date")), 
                ~ floor_date(
                  as.Date(., format="%Y-%m-%d"),
                  unit = "days")
  ),
  ##vaccinated study
  #Add 14 days to vax_date_covid_2
  vax_date_covid_2_14 = vax_date_covid_2 + days(14),
  #maximum of vax2 date and 
  index_vax = data.table::fifelse(as.Date(
    vax_date_covid_2_14) > as.Date(delta_date,format="%Y-%m-%d"),
    as.Date(vax_date_covid_2_14),
    as.Date(delta_date,format="%Y-%m-%d")),
  ##electively unvaccinated study
  vax_date_eligible_84 = vax_date_eligible + days(84),
  index_unvax = data.table::fifelse(as.Date(
    vax_date_eligible_84) > as.Date(delta_date,format="%Y-%m-%d"),
    as.Date(vax_date_eligible_84),
    as.Date(delta_date,format="%Y-%m-%d")),
  
  ##prevax index date
  index_prevax = as.Date(study_dates$pandemic_start)
    
  )

arrow::write_feather(prelim_data, "./output/index_dates.feather")




