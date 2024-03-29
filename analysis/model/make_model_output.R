# Load packages ----------------------------------------------------------------
print('Load packages')

library(magrittr)
library(dplyr)
library(stringr)

# Load active analyses ---------------------------------------------------------
print('Load active analyses')

active_analyses <- readr::read_rds("lib/active_analyses.rds")

# Specify redaction threshold --------------------------------------------------
print('Specify redaction threshold')

threshold <- 6

# Source common functions ------------------------------------------------------
print('Source common functions')

source("analysis/utility.R")

# List available model outputs -------------------------------------------------
print('List available model outputs')

files <- list.files("output", pattern = "model_output-")
# Exclude files ending with "gi_bleeds.csv" (gi bleeds project)
files_to_exclude <- grepl("gi_bleeds\\.csv$", files)
filtered_files <- files[!files_to_exclude]

# Combine model outputs --------------------------------------------------------
print('Combine model outputs')

df <- NULL
symptoms<- c("nausea", "vomiting", "bloody_stools", "abdominal_paindiscomfort", "abdominal_distension", "diarrhoea")

for (i in filtered_files) {
  ## Load model output if it is not a symptom
  if (!any(str_detect(i, symptoms))) {
  
  tmp <- readr::read_csv(paste0("output/",i))
  
  ## Handle errors
  
  if (colnames(tmp)[1] == "error") {
    
    dummy <- data.frame(model = "",
                        exposure = "",
                        outcome = gsub(".*-","",gsub(".csv","",i)),
                        term = "",
                        lnhr = NA,
                        se_lnhr = NA,
                        hr = NA,
                        conf_low = NA,
                        conf_high = NA,
                        N_total = NA,
                        N_exposed = NA,
                        N_events = NA,
                        person_time_total = NA,
                        outcome_time_median = NA,
                        strata_warning = "",
                        surv_formula = "",
                        input = "",
                        error = tmp$error)
    
    tmp <- dummy
    
  } else {
    
    tmp$error <- ""
    
  }
  
  ## Add source file name
  
  tmp$name <- gsub("model_output-","",gsub(".csv","",i))
  
  ## Append to master dataframe
  
  df <- plyr::rbind.fill(df,tmp)
}
}

# Add details from active analyses ---------------------------------------------
print('Add details from active analyses')

df[,c("exposure","outcome")] <- NULL

df <- merge(df, 
            active_analyses[,c("name","cohort","outcome","analysis")], 
            by = "name", all.x = TRUE)

df$outcome <- gsub("out_date_","",df$outcome)


# Apply midpoint 6 rounding   --------------------------------------------------
print('Apply rounding')
df[,c("N_total","N_exposed","N_events")] <- lapply(df[,c("N_total","N_exposed","N_events")],
                                                 FUN=function(y){roundmid_any(as.numeric(y), to=threshold)})
 # Save model output ------------------------------------------------------------
print('Save model output')

df <- df[,c("name","cohort","outcome","analysis","error","model","term",
            "lnhr","se_lnhr","hr","conf_low","conf_high",
            "N_total","N_exposed","N_events","person_time_total",
            "outcome_time_median","strata_warning","surv_formula")]

readr::write_csv(df, "output/model_output.csv")                                               
# Rename rounded columns -------------------------------------------------------
df<- df%>% 
rename(
    N_total_midpoint6 = N_total,
    N_exposed_midpoint6 = N_exposed,
    N_events_midpoint6 = N_events
  )
  
# Save model output ------------------------------------------------------------
print('Save model output')
df <- df[,c("name","cohort","outcome","analysis","error","model","term",
            "lnhr","se_lnhr","hr","conf_low","conf_high",
            "N_total_midpoint6","N_exposed_midpoint6","N_events_midpoint6","person_time_total",
            "outcome_time_median","strata_warning","surv_formula")]

readr::write_csv(df, "output/model_output_midpoint6.csv")
