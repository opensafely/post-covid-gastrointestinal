library(magrittr)
library(data.table)
library(tidyverse)

# Read and filter active analyses
print('Read and filter active analyses')
active_analyses<- readr::read_rds("lib/active_analyses_4mofup.rds")
active_analyses <- active_analyses %>% filter(cohort == "prevax")%>%
 filter(grepl("cohort_prevax-sub_covid_hospitalised-lower_gi_bleeding",name))


# Specify command arguments ----------------------------------------------------
print('Specify command arguments')

name_suffixes <- c("_throm_True_4mofup", "_throm_False_4mofup", "_anticoag_True_4mofup", "_anticoag_False_4mofup")
analyses <- unique(active_analyses$analysis)
for (i in 1:nrow(active_analyses)) {
    cohort <- active_analyses$cohort[i]
    name_4mofup <- active_analyses[i, "name"]
    name <- gsub(paste(name_suffixes, collapse = "|"), "", name_4mofup)
    input <- readRDS(paste0("output/model_input-", name, ".rds"))
    hosp_input <- read.csv(paste0("output/input_", cohort, "_4mofup.csv.gz"))
    
    input$outcome <- active_analyses[i, "outcome"]
    
    study_start <- active_analyses[i]$study_start
    
    study_stop <-  active_analyses[i]$study_stop
    
    input$fup_start <- pmax(input$index_date, study_start, na.rm = TRUE)
    input$fup_stop <- pmin(input$end_date_outcome, study_stop, na.rm = TRUE)
    
    input$fup_total <- as.numeric(input$fup_stop - input$fup_start)
    
    input <- input %>% filter(fup_total >= 120)
    if (grepl("throm", active_analyses$analysis)){
    input_hosp_4mo_throm <- input %>%
        right_join(hosp_input, by = "patient_id") %>%
        select(
            everything(),
            cov_bin_vte,
            cov_bin_ate,
            cov_bin_ate_vte_4mofup
        )
    
    if (active_analyses$analysis[i]=="throm_True_4mofup"){
    input_hosp_4mo_throm_True <- input_hosp_4mo_throm %>%
        filter(cov_bin_ate_vte_4mofup == TRUE)

    writeRDS(input_hosp_4mo_throm_True, paste0("output/model_input", active_analyses[i,"name"], "_throm_True_4mofup.rds"))
    }else{
    input_hosp_4mo_throm_False <- input_hosp_4mo_throm %>%
        filter(cov_bin_ate_vte_4mofup == FALSE)
        
    writeRDS(input_hosp_4mo_throm_False, paste0("output/model_input",active_analyses[i,"name"], "_throm_False_4mofup.rds"))
    }
    }
    if (grepl("anticoag", active_analyses$analysis)){
    input_hosp_4mo_anticoag <- input %>%
        right_join(hosp_input, by = "patient_id") %>%
        select(
            everything(),
            cov_bin_anticoagulants_4mofup_bnf
        )
    if (active_analyses$analysis[i]=="anticoag_True_4mofup"){
    input_hosp_4mo_anticoag_True <- input_hosp_4mo_anticoag %>%
        filter(cov_bin_anticoagulants_4mofup_bnf == TRUE)
    
    writeRDS(input_hosp_4mo_anticoag_True, paste0("output/model_input", active_analyses[i,"name"], "anticoag_True_4mofup.rds"))
    }else{
    input_hosp_4mo_anticoag_False <- input_hosp_4mo_anticoag %>%
        filter(cov_bin_anticoagulants_4mofup_bnf == FALSE)
    
    writeRDS(input_hosp_4mo_anticoag_False, paste0("output/model_input", name, "anticoag_False_4mofup.rds"))
}
    }
}


