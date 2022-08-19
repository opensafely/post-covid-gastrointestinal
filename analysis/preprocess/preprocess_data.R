# Load libraries ---------------------------------------------------------------

library(magrittr)
library(dplyr)
library(tidyverse)
library(lubridate)

# Specify command arguments ----------------------------------------------------

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  # use for interactive testing
  cohort_name <- "vaccinated"
} else {
  cohort_name <- args[[1]]
}

fs::dir_create(here::here("output", "not-for-review"))
fs::dir_create(here::here("output", "review"))


# Read cohort dataset 
args[[1]]<- "vaccinated"
df <- arrow::read_feather(file = paste0("output/input_",args[[1]],".feather") )

print("Dataset has been read successfully")

# Format columns -----------------------------------------------------
# dates, numerics, factors, logicals

df <- df %>%
  mutate(across(c(contains("_date")), ~ floor_date(as.Date(., format="%Y-%m-%d"), unit = "days")),
         across(contains('_birth_year'), ~ format(as.Date(.), "%Y")),
         across(contains('_num'), ~ as.numeric(.)),
         across(contains('_cat'), ~ as.factor(.)),
         across(contains('_bin'), ~ as.logical(.)))


# Overwrite vaccination information for dummy data only ------------------------

if(Sys.getenv("OPENSAFELY_BACKEND") %in% c("", "expectations") && args[[1]] %in% c("vaccinated", "unvaccinated")) {
  source("analysis/preprocess/modify_dummy_vax_data.R")
  print("Vaccine information overwritten successfully")
}


# Describe data --------------------------------------------------------------

sink(paste0("output/not-for-review/describe_",cohort_name,".txt"))
print(Hmisc::describe(df))
sink()



#Combine BMI variables to create one history of obesity variable ---------------

df$cov_bin_obesity <-ifelse(df$cov_bin_obesity==TRUE | df$cov_cat_bmi_groups=="Obese",TRUE,FALSE)
df[,c("cov_num_bmi")] <- NULL

# QC for consultation variable
#max to 365 (average of one per day)
df <- df %>%
  mutate(cov_num_consulation_rate = replace(cov_num_consulation_rate, cov_num_consulation_rate > 365, 365))%>%
  dplyr::select(- c(cov_cat_bmi_groups))



df <- df %>%
  mutate(sub_cat_covid19_hospital = 
           ifelse(!is.na(exp_date_covid19_confirmed) &
                    !is.na(sub_date_covid19_hospital) &
                    sub_date_covid19_hospital - exp_date_covid19_confirmed >= 0 &
                    sub_date_covid19_hospital - exp_date_covid19_confirmed < 29, "hospitalised",
                  ifelse(!is.na(exp_date_covid19_confirmed), "non_hospitalised", 
                         ifelse(is.na(exp_date_covid19_confirmed), "no_infection", NA)))) %>%
  mutate(across(sub_cat_covid19_hospital, factor))
df <- df[!is.na(df$patient_id),]
df[,c("sub_date_covid19_hospital")] <- NULL

print("COVID19 severity determined successfully")


# Restrict columns and save analysis dataset ---------------------------------


df1 <- df%>% select(patient_id,"death_date",starts_with("index_date_"), starts_with("end_date_"),
             contains("sub_"), # Subgroups
             contains("exp_"), # Exposures
             contains("out_"), # Outcomes
             contains("cov_"), # Covariates
             contains("qa_"), # Quality assurance
             #contains("step"), # diabetes steps
             contains("vax_date_eligible"), # Vaccination eligibility
             contains("vax_date_"), # Vaccination dates and vax type 
             #contains("vax_cat_")# Vaccination products
)


df1[,colnames(df)[grepl("tmp_",colnames(df))]] <- NULL

saveRDS(df1, file = paste0("output/input_",cohort_name,".rds"))

print("Input data saved successfully")

# Describe data --------------------------------------------------------------

sink(paste0("output/not-for-review/describe_input_",cohort_name,"_stage0.txt"))
print(Hmisc::describe(df1))
sink()

# Restrict columns and save Venn diagram input dataset -----------------------


df2 <- df %>% select(starts_with(c("patient_id","tmp_out_date","out_date")))

# Describe data --------------------------------------------------------------

sink(paste0("output/not-for-review/describe_venn_",cohort_name,".txt"))
print(Hmisc::describe(df2))
sink()

saveRDS(df2, file = paste0("output/venn_",cohort_name,".rds"))

print("Venn diagram data saved successfully")
