# Load packages ----------------------------------------------------------------
print('Load packages')
library(magrittr)
library(data.table)
library(dplyr)

# Source functions -------------------------------------------------------------
print('Source functions')
source("analysis/model/fn-check_vitals.R")

# Make directory ---------------------------------------------------------------
print('Make directory')
fs::dir_create(here::here("output", "model_input"))

#Load data
input <- readr::read_rds("output/input_vax_stage1_gi_bleeds.rds")


# Restrict to required variables -----------------------------------------------
print('Restrict to required variables')

# Assuming that the structure of your local data is similar
# Assuming 'input' is your original dataframe
input <- input[, c("patient_id",
                          "index_date",
                          "end_date_exposure",
                          "end_date_outcome",
                          "exp_date_covid19_confirmed",
                          "out_date_upper_gi_bleeding",
                          "out_date_lower_gi_bleeding",
                          "out_date_variceal_gi_bleeding",
                          "out_date_nonvariceal_gi_bleeding",
                          "cov_num_age",
                          "cov_cat_sex",
                          "cov_cat_ethnicity",
                          "cov_cat_region",
                          "cov_cat_deprivation",
                          "cov_cat_smoking_status",
                          "cov_bin_carehome_status",
                          "cov_bin_obesity",
                          "cov_bin_healthcare_worker",
                          "cov_bin_alcohol_above_limits",
                          "cov_bin_cholelisthiasis",
                          "cov_bin_nsaid_bnf",
                          "cov_bin_aspirin_bnf",
                          "cov_bin_h_pylori_infection",
                          "cov_bin_anticoagulants_bnf",
                          "cov_bin_antidepressants_bnf",
                          "cov_bin_gi_operations",                                                            
                          "sub_cat_covid19_hospital", 
                          "sub_bin_covid19_confirmed_history")]



# Remove outcomes outside of follow-up time ------------------------------------
print('Remove outcomes outside of follow-up time')

input <- dplyr::rename(input,
                       out_date_upper = out_date_upper_gi_bleeding,
                       out_date_lower = out_date_lower_gi_bleeding,
                       out_date_variceal = out_date_variceal_gi_bleeding,
                       out_date_nonvariceal = out_date_nonvariceal_gi_bleeding,
                       exp_date = exp_date_covid19_confirmed)

input <- input %>% 
  dplyr::mutate(
    out_date_upper = replace(out_date_upper, which(out_date_upper > end_date_outcome | out_date_upper < index_date), NA),
    out_date_lower = replace(out_date_lower, which(out_date_lower > end_date_outcome | out_date_lower < index_date), NA),
    out_date_variceal = replace(out_date_variceal, which(out_date_variceal > end_date_outcome | out_date_variceal < index_date), NA),
    out_date_nonvariceal = replace(out_date_nonvariceal, which(out_date_nonvariceal > end_date_outcome | out_date_nonvariceal < index_date), NA),
    exp_date = replace(exp_date, which(exp_date > end_date_exposure | exp_date < index_date), NA)
  )

# Update end date to be outcome date where applicable --------------------------
print('Update end date to be outcome date where applicable')
input <- input %>% 
  dplyr::rowwise() %>% 
  dplyr::mutate(end_date_outcome = min(end_date_outcome, out_date_upper, out_date_lower, out_date_variceal, out_date_nonvariceal, na.rm = TRUE))



# Save the output
readr::write_rds(input, file.path("output", "model_input-cohort_vax_gi_bleeds.rds"), compress = "gz")
print("Saved: output/model_input-cohort_vax_gi_bleeds.rds")




