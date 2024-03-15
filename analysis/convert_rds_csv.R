# convert rds stage 1 files to csv for sensitivity study definition 
library(readr)
library(dplyr)

# Specify command arguments ----------------------------------------------------
print('Specify command arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  cohort <- "unvax"
} else {
  cohort <- args[[1]]
}

stage1_df<- read_rds(paste0("output/input_",cohort,"_stage1.rds"))


# Restrict to needed variables ----------------------------------------------------
print('Restrict to needed variables')
stage1_df <- stage1_df %>%
             select(patient_id, exp_date_covid19_confirmed, end_date_outcome, index_date) %>%
             mutate(
               patient_id = as.character(patient_id),
               exp_date_covid19_confirmed = as.Date(exp_date_covid19_confirmed),
               end_date_outcome = as.Date(end_date_outcome),
               index_date = as.Date(index_date)
             )

# Save as csv.gz ----------------------------------------------------
print('Saving file')
write_csv(stage1_df, paste0("output/input_", cohort, "_stage1_sens.csv.gz"))
