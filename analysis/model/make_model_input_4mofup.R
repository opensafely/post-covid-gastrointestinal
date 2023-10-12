library(magrittr)
library(data.table)
library(tidyverse)

# Read and filter active analyses
print('Read and filter active analyses')
active_analyses <- readr::read_rds("lib/active_analyses.rds")
active_analyses <- active_analyses%>%
filter(analysis=="sub_covid_hospitalised" &  grepl("bleeding", outcome, ignore.case = TRUE) )

# create a new acative_analyses for the new analyses


# Specify command arguments ----------------------------------------------------
print('Specify command arguments')

# name <- "cohort_vax-sub_covid_hospitalised-upper_gi_bleeding"

for (i in 1:nrow(active_analyses)) {
    cohort <- active_analyses$cohort[i]
    input <- readRDS(paste0("output/model_input-",  active_analyses[i,"name"], ".rds"))
    hosp_input <- read.csv(paste0("output/input_", cohort, "_4mo_fup.csv.gz"))
    
    input$outcome <- active_analyses[i, "outcome"]
    
    study_start <- active_analyses[i]$study_start
    
    study_stop <-  active_analyses[i]$study_stop
    
    input$fup_start <- pmax(input$index_date, study_start, na.rm = TRUE)
    input$fup_stop <- pmin(input$end_date_outcome, study_stop, na.rm = TRUE)
    
    input$fup_total <- as.numeric(input$fup_stop - input$fup_start)
    
    input <- input %>% filter(fup_total >= 120)
    
    input_hosp_4mo_throm <- input %>%
        right_join(hosp_input, by = "patient_id") %>%
        select(
            everything(),
            cov_bin_vte,
            cov_bin_ate,
            cov_bin_ate_vte_4mofup
        )
    
    active_analyses_4mofup <- rbind(active_analyses_4mofup, active_analyses[i, ])

    input_hosp_4mo_throm_True <- input_hosp_4mo_throm %>%
        filter(cov_bin_ate_vte_4mofup == TRUE)
    active_analyses_4mofup$name[nrow(active_analyses_4mofup)] <- paste0(active_analyses_4mofup$name[nrow(active_analyses_4mofup)], "_throm_True_4mofup")

    writeRDS(input_hosp_4mo_throm_True, paste0("output/model_input", active_analyses[i,"name"], "_throm_True_4mofup.rds"))
    
    input_hosp_4mo_throm_False <- input_hosp_4mo_throm %>%
        filter(cov_bin_ate_vte_4mofup == FALSE)
        active_analyses_4mofup <- rbind(active_analyses_4mofup, active_analyses[i, ])
        active_analyses_4mofup$name[nrow(active_analyses_4mofup)] <- paste0(active_analyses_4mofup$name[nrow(active_analyses_4mofup)], "_throm_False_4mofup")

    writeRDS(input_hosp_4mo_throm_False, paste0("output/model_input",active_analyses[i,"name"], "_throm_False_4mofup.rds"))
    
    input_hosp_4mo_anticoag <- input %>%
        right_join(hosp_input, by = "patient_id") %>%
        select(
            everything(),
            cov_bin_anticoagulants_4mofup_bnf
        )
    
    input_hosp_4mo_anticoag_True <- input_hosp_4mo_anticoag %>%
        filter(cov_bin_anticoagulants_4mofup_bnf == TRUE)
    active_analyses_4mofup <- rbind(active_analyses_4mofup, active_analyses[i, ])
    active_analyses_4mofup$name[nrow(active_analyses_4mofup)] <- paste0(active_analyses_4mofup$name[nrow(active_analyses_4mofup)], "anticoag_True_4mofup")

    writeRDS(input_hosp_4mo_anticoag_True, paste0("output/model_input", active_analyses[i,"name"], "anticoag_True_4mofup.rds"))
    
    input_hosp_4mo_anticoag_False <- input_hosp_4mo_anticoag %>%
        filter(cov_bin_anticoagulants_4mofup_bnf == FALSE)
    active_analyses_4mofup <- rbind(active_analyses_4mofup, active_analyses[i, ])
    active_analyses_4mofup$name[nrow(active_analyses_4mofup)] <- paste0(active_analyses_4mofup$name[nrow(active_analyses_4mofup)], "anticoag_False_4mofup")

    writeRDS(input_hosp_4mo_anticoag_False, paste0("output/model_input", name, "anticoag_False_4mofup.rds"))
}
write_rds(active_analyses_4mofup,"lib/active_analyses_4mofup.rds")


# TODO set anticaoag covar to NULL 
# Check if we need to create a new active_analyses to write actions and run
