# Save the patients who are hospitalised with at least 4 month follow up 
library(dplyr)
library(readr)

active_analyses <- readr::read_rds("lib/active_analyses.rds")
active_analyses <- active_analyses%>%
 filter(analysis=="sub_covid_hospitalised" &  grepl("bleeding", outcome, ignore.case = TRUE) )


get_4mo_followup <- function(name) {
    input <- readRDS(paste0("output/model_input-", name, ".rds"))
    
    if ("prevax" %in% name) {
        study_start <- as.Date("2020-01-01", origin = '1970-01-01')
    } else {
        study_start <- as.Date("2026-06-01", origin = '1970-01-01')
    }
    
    study_stop <- as.Date("2021-12-14", origin = '1970-01-01')
    
    input$fup_start <- pmax(input$index_date, study_start, na.rm = TRUE)
    input$fup_stop <- pmin(input$end_date_outcome, study_stop, na.rm = TRUE)
    
    input$fup_total <- as.numeric(input$fup_stop - input$fup_start)
    
    input <- input %>% 
        filter(fup_total >= 120)
    
    write_rds("output/fup4mo-",name,".rds")
}

results <- lapply(active_analyses$name, get_4mo_followup)




