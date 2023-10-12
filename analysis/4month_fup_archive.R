# Save the patients who are hospitalised with at least 4 month follow up 
library(dplyr)
library(readr)


# Specify command arguments ----------------------------------------------------
print('Specify command arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  cohort <- "prevax"
} else {
  cohort <- args[[1]]
}

# Read and filter active analyses
print('Read and filter active analyses')
active_analyses <- readr::read_rds("lib/active_analyses.rds")
active_analyses <- active_analyses%>%
filter(analysis=="sub_covid_hospitalised" &  grepl("bleeding", outcome, ignore.case = TRUE) )



# Function to read an combine model inputs
get_4mo_followup <- function(c) {

    active_analyses <- active_analyses%>%
                                     filter(cohort==c)
    cohort_data <- data.frame()
    
    for (i in 1:length(active_analyses)) {
    input <- readRDS(paste0("output/model_input-",name,".rds"))
    input$outcome<-active_analyses[i,"outcome"]
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
    
    cohort_data <- bind_rows(input)
}
print("Writing combined input to file")
write_rds(cohort_data,paste0("output/model_input_fup4mo_",c,".rds"))
    }

get_4mo_followup("prevax")





