library(magrittr)
library(data.table)
library(dplyr)
library(readr)


#  Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  name <- "all" # prepare datasets for all active analyses 
   name <- "cohort_prevax-sub_covid_hospitalised-nonvariceal_gi_bleeding_throm_True_sensitivity" # prepare datasets for all active analyses whose name contains X
} else {
  name <- args[[1]]
}

active_analyses<-read_rds("lib/active_analyses_sensitivity.rds")
# Identify model inputs to be prepared -----------------------------------------
print('Identify model inputs to be prepared')

if (name=="all") {
  prepare <- active_analyses$name
} else if(grepl(";",name)) {
  prepare <- stringr::str_split(as.vector(name), ";")[[1]]
} else {
  prepare <- active_analyses[grepl(name,active_analyses$name),]$name
}
active_analyses <- active_analyses[active_analyses$name %in% prepare,]
# Specify command arguments ----------------------------------------------------
print('Specify command arguments')

name_suffixes <- c("_throm_True_sensitivity", "_throm_False_sensitivity", "_anticoag_True_sensitivity", "_anticoag_False_sensitivity")
for (i in 1:nrow(active_analyses)) {
    cohort <- active_analyses$cohort[i]
    name_sensitivity <- active_analyses[i, "name"]
    name <- gsub(paste(name_suffixes, collapse = "|"), "", name_sensitivity)
    input <- readRDS(paste0("output/model_input-", name, ".rds"))
    hosp_input <- read.csv(paste0("output/input_", cohort, "_4mofup.csv.gz"))
    hosp_input <- hosp_input %>%mutate(
        patient_id=as.character(patient_id)
    )
    
    
    study_start <- active_analyses[i, "study_start"]
    
    study_stop <-  active_analyses[i, "study_stop"]
    
    input$fup_start <- pmax(input$index_date, study_start, na.rm = TRUE)
    input$fup_stop <- pmin(input$end_date_outcome, study_stop, na.rm = TRUE)
    
    input$fup_total <- as.numeric(input$fup_stop - input$fup_start)
    
    if (grepl("throm", active_analyses$analysis)){

    hosp_input <- hosp_input %>% 
    dplyr::select(patient_id,
                cov_bin_vte,
                cov_bin_ate,
                cov_bin_ate_vte_4mofup
    )
    input_hosp_4mo_throm <- input %>%
        right_join(hosp_input, by = "patient_id") 
    
    if (active_analyses$analysis[i]=="sub_covid_hospitalised_throm_True_sensitivity"){
    input_hosp_4mo_throm_True <- input_hosp_4mo_throm %>%
        filter(cov_bin_ate_vte_4mofup == TRUE)

    write_rds(input_hosp_4mo_throm_True, paste0("output/model_input-", active_analyses[i,"name"],".rds"))
    }else{
    input_hosp_4mo_throm_False <- input_hosp_4mo_throm %>%
        filter(cov_bin_ate_vte_4mofup == FALSE)
        
    write_rds(input_hosp_4mo_throm_False, paste0("output/model_input-",active_analyses[i,"name"],".rds"))
    }
    }
    if (grepl("anticoag", active_analyses$analysis)){
    input <- input %>% filter(fup_total >= 120)

    hosp_input<- hosp_input %>%dplyr::select(
        patient_id,
        cov_bin_anticoagulants_4mofup_bnf
    )
        input_hosp_4mo_anticoag <- input %>% 
        right_join(hosp_input, by = "patient_id")
        
    if (active_analyses$analysis[i]=="sub_covid_hospitalised_anticoag_True_sensitivity"){
    input_hosp_4mo_anticoag_True <- input_hosp_4mo_anticoag %>%
        filter(cov_bin_anticoagulants_4mofup_bnf == TRUE)
    
    writeRDS(input_hosp_4mo_anticoag_True, paste0("output/model_input-", active_analyses[i,"name"], "anticoag_True_sensitivity.rds"))
    }else{
    input_hosp_4mo_anticoag_False <- input_hosp_4mo_anticoag %>%
        filter(cov_bin_anticoagulants_4mofup_bnf == FALSE)
    
    writeRDS(input_hosp_4mo_anticoag_False, paste0("output/model_input-", name, "anticoag_False_sensitivity.rds"))
}
    }
}


