# Load packages ----------------------------------------------------------------
print('Load packages')

library(magrittr)
library(data.table)
library(tidyverse)

# Defining variables -----------------------------------------------------------
study_end_date = as.Date("2021/12/14")


# Source functions -------------------------------------------------------------
print('Source functions')

source("analysis/model/fn-check_vitals.R")

# Make directory ---------------------------------------------------------------
print('Make directory')

fs::dir_create(here::here("output", "model_input"))


# Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  # name <- "all" # prepare datasets for all active analyses 
  name <- "cohort_vax-main-upper_gi_bleeding" # prepare datasets for all active analyses whose name contains X
} else {
  name <- args[[1]]
}

# Load active analyses ---------------------------------------------------------
print('Load active analyses')

active_analyses <- readr::read_rds("lib/active_analyses_gi_bleeds.rds")

# Identify model inputs to be prepared -----------------------------------------
print('Identify model inputs to be prepared')

if (name=="all") {
  prepare <- active_analyses$name
} else if(grepl(";",name)) {
  prepare <- stringr::str_split(as.vector(name), ";")[[1]]
} else {
  prepare <- active_analyses[grepl(name,active_analyses$name),]$name
}

# Filter active_analyses to model inputs to be prepared ------------------------
print('Filter active_analyses to model inputs to be prepared')

active_analyses <- active_analyses[active_analyses$name %in% prepare,]
for (i in 1:nrow(active_analyses)) {
  
  i <- 1
  # Load data --------------------------------------------------------------------
  print(paste0("Load data for ",active_analyses$name[i]))
  
  
  input <- dplyr::as_tibble(readr::read_rds(paste0("output/input_",active_analyses$cohort[i],"_stage1_gi_bleeds.rds")))
  print (paste0("nrow after read : ",nrow(input)))
  print(summary(input$cov_num_age))
  # Restrict to required variables -----------------------------------------------
  print('Restrict to required variables')
  
  
  input <- input[,unique(c("patient_id",
                           "index_date",
                           "end_date_exposure",
                           "end_date_outcome",
                           active_analyses$exposure[i], 
                           active_analyses$outcome[i],
                           unlist(strsplit(active_analyses$strata[i], split = ";")),
                           unlist(strsplit(active_analyses$covariate_other[i], split = ";"))[!grepl("_priorhistory_",unlist(strsplit(active_analyses$covariate_other[i], split = ";")))],
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
                           "sub_bin_covid19_confirmed_history"))]
  
  print (paste0("nrow after restrict to required variables : ",nrow(input)))
  print(summary(input$cov_num_age))
  
  input <- dplyr::rename(input, 
                         "out_date" =active_analyses$outcome[i],
                         "exp_date" = active_analyses$exposure[i])
  print (paste0("nrow after rename : ",nrow(input)))
  
  #End_Date outcome and End_Date exposure 
  
  input <- input %>% 
           mutate(end_date_outcome = ifelse(!is.na(out_date), out_date, study_end_date))
                      
  input <- input %>% 
    mutate(end_date_exposure = ifelse(!is.na(exp_date), exp_date, study_end_date))
                                   
  input <- input %>% 
    dplyr::mutate(out_date = replace(out_date, which(out_date>end_date_outcome | out_date<index_date), NA),
                  exp_date =  replace(exp_date, which(exp_date>end_date_exposure | exp_date<index_date), NA),
                  sub_cat_covid19_hospital = replace(sub_cat_covid19_hospital, which(is.na(exp_date)),"no_infection"))
  
  print (paste0("nrow after replace : ",nrow(input)))
  
  # Update end date to be outcome date where applicable ------------------------
  print('Update end date to be outcome date where applicable')
  
  input <- input %>% 
    dplyr::rowwise() %>% 
    dplyr::mutate(end_date_outcome = min(end_date_outcome, out_date, na.rm = TRUE))
  
  print (paste0("nrow after Update end date to be outcome date : ",nrow(input)))
  
  
  # Make model input: main -------------------------------------------------------
  
  if (active_analyses$analysis[i]=="main") {
    
    print('Make model input: main')
    df <- input[input$sub_bin_covid19_confirmed_history==FALSE,]
    df[,colnames(df)[grepl("sub_",colnames(df))]] <- NULL
    check_vitals(df)
    readr::write_rds(df, file.path("output", paste0("model_input-",active_analyses$name[i],".rds")),compress="gz")
    print(paste0("Saved: output/model_input-",active_analyses$name[i],".rds"))
    rm(df)
    
  }
}
  