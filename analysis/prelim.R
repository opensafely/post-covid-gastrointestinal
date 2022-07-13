###Marwa Al Arab###
# # # # # # # # # # # # # # # # # # # # #
# This script:
#reads in the study_definit_prelim
# output and return index dates for 
#study_definition_vaccinated and 
#study_definition_unvaccinated
#study_definition_prevaccinated
# # # # # # # # # # # # # # # # # # # # #

#Load libraries using pacman
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,tictoc,purrr,lubridate,glue,tidyverse,jsonlite,here,arrow)

#json file containing vax study dates
study_dates <- fromJSON("output/vax_study_dates.json")
delta_date <- study_dates$delta_date
delta_end_date <- study_dates$omicron_date
efficacy_offset <- 14 
eligibility_offset <- 84


#Read in the output of study_definition_prelim and add dates variables
prelim_data <- arrow::read_feather("output/input_prelim.feather") 
  # Because date types are not returned consistently by cohort extractor (Elsie)
  prelim_data <- prelim_data %>%
  mutate(across(c(contains("_date")), 
                ~ floor_date(
                  as.Date(., format="%Y-%m-%d"),
                  unit = "days"))) %>%
  ##vaccinated study
  #Add 14 days to vax_date_covid_2
  mutate(vax_date_covid_2_14 = vax_date_covid_2 + days(efficacy_offset))%>% 
  rowwise() %>%
  #maximum of vax2 date and delta date
  mutate(index_vax =  max(c(vax_date_covid_2_14,as.Date(rep(delta_date,nrow(prelim_data)))),na.rm=T)) %>%
  mutate(end_vax = min(c(death_date,as.Date(rep(delta_end_date,nrow(prelim_data)))),na.rm=T)) %>%
  ungroup() %>%
  ##electively unvaccinated study
  mutate(vax_date_eligible_84 = vax_date_eligible + days(eligibility_offset)) %>%
  rowwise() %>%
  mutate(index_unvax =  max(c(vax_date_eligible_84,as.Date(rep(delta_date,nrow(prelim_data)))),na.rm=T)) %>%
  rowwise() %>%
  mutate(end_unvax = min(c(death_date,as.Date(rep(delta_end_date,nrow(prelim_data)))),na.rm=T)) %>%
  ungroup()%>%
  ##prevax dates
  mutate(index_prevax = as.Date(study_dates$pandemic_start)) %>%
  rowwise() %>%
  mutate(end_prevax = min(c(vax_date_eligible,death_date,vax_date_covid_1),na.rm=T))

#Write data to feather file 
arrow::write_feather(prelim_data, "output/index_dates.feather")




