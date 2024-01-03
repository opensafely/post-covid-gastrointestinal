library(dplyr)
library(stringr)
library(readr)
library(tidyr)

# Specify redaction threshold --------------------------------------------------
print('Specify redaction threshold')

threshold <- 6

# Source common functions ------------------------------------------------------
print('Source common functions')

source("analysis/utility.R")

# Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  analysis <- "anticoag"
} else {
  analysis <- args[[1]]
}

# Load active analyses ---------------------------------------------------------
print('Load active analyses')

active_analyses <- readr::read_rds("lib/active_analyses_sensitivity.rds")
active_analyses <- active_analyses[ grepl(analysis,active_analyses$analysis),]

# Combine data frames ---------------------------------------------------------
print('Combine data frames')
df_list <- list()
for (i in 1:nrow(active_analyses)){
if ( file.exists(paste0("output/model_input-",active_analyses$name[i],".rds"))){
df <- readRDS(paste0("output/model_input-",active_analyses$name[i],".rds")) 
if (analysis=="throm"){
df<-df%>%
select(c("patient_id", "cov_bin_ate_vte_4mofup","exp_date","out_date","end_date_outcome","index_date","end_date_exposure"))
}else if (analysis=="anticoag") {
   df<-df%>%
   select(c("patient_id","cov_bin_anticoagulants_4mofup_bnf","exp_date","out_date","end_date_outcome","index_date","end_date_exposure" ))%>% 
   mutate(cov_bin_anticoagulants_4mofup_bnf=as.numeric(cov_bin_anticoagulants_4mofup_bnf))
}
df$outcome <- active_analyses$outcome[i]
df$cohort<- active_analyses$cohort[i]

# Set to NA exposure  date where they are outside defined boundaries--------------------------
 df <- df %>% 
    dplyr::mutate(exp_date = replace(exp_date, which(exp_date>end_date_exposure | exp_date<index_date), NA))
                  
  
  ## Create exposed variable -------------------------------------------------------
  
  df$exposed <- ifelse(!is.na(df$exp_date),TRUE,FALSE)
  
df_list[[i]] <- df
}

combined_df <- bind_rows(df_list) 

# Count events ---------------------------------------------------------
perform_analysis <- function(data,analysis) {
    if (analysis=="anticoag"){
    sa_anticoag <- data %>%
        group_by(outcome, cov_bin_anticoagulants_4mofup_bnf,exposed) %>%
        summarize(count = n_distinct(patient_id, na.rm = TRUE)) %>%
        pivot_wider(names_from = cov_bin_anticoagulants_4mofup_bnf, values_from = count,
                    names_prefix = "n_anticoag_", values_fill = list(count = 0))
    }else if (analysis=="throm") {
    
    sa_throm <- data %>%
        group_by(outcome, cov_bin_ate_vte_4mofup,exposed) %>%
        summarize(count = n_distinct(patient_id, na.rm = TRUE)) %>%
        pivot_wider(names_from = cov_bin_ate_vte_4mofup, values_from = count,
                    names_prefix = "n_throm_", values_fill = list(count = 0))
    }
}

# Perform analysis for each cohort and store the results------------------
results<-list()
cohorts<-c("prevax","unvax","vax")
for (c in cohorts) {
    cohort_data <- combined_df %>% filter(cohort==c)
    results[[c]] <- perform_analysis(cohort_data,analysis)

# Perform redaction---------------------------------------------- 
    rounded_cols <- setdiff(colnames(results[[c]]), c("outcome"))

    results[[c]][rounded_cols] <- lapply(
        results[[c]][rounded_cols],
        FUN = function(y) { roundmid_any(as.numeric(y), to = threshold) }
    )

    # Renaming the columns by adding '_midpoint6'
    new_names <- paste0(rounded_cols, "_midpoint6")
    names(results[[c]])[match(rounded_cols, names(results[[c]]))] <- new_names

    # Reassign the modified data frame back to the results list
    write.csv(results[[c]],paste0("output/sensitivity_",c,"_",analysis,"_midpoint6.csv"),row.names=FALSE)
}



