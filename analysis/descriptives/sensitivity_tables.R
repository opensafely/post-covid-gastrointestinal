library(dplyr)
library(stringr)

#  Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  # name <- "all" # prepare datasets for all active analyses 
  name <- "cohort_prevax-sub_covid_hospitalised-upper_gi_bleeding_throm_True_4mofup" # prepare datasets for all active analyses whose name contains X
} else {
  name <- args[[1]]
}

active_analyses<-read_rds("lib/active_analyses_4mofup.rds")
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

extract_outcome <- function(file_name) {
    # extract outcome name from file name
    pattern <- "hospitalised-(.+_bleeding)"
    match <- str_match(file_name, pattern)
    if (is.na(match[,2])) {
        return(NA)
    } else {
        return(match[,2])
    }
}

# Function to add outcome to each data frame and combine them
add_outcome_and_combine <- function(file_list, df_list) {
    for (i in seq_along(file_list)) {
        outcome <- extract_outcome(file_list[i])
        print(outcome)
        df_list[[i]] <- df_list[[i]] %>% mutate(outcome = outcome)
    }
    bind_rows(df_list)
}
# Function to read rds files and keep the columns needed
read_rds_keep_columns <- function(file_name, columns) {
  readRDS(file_name) %>% 
    select(all_of(columns))
}

#  Columns to keep
needed_columns <- c("patient_id", "cov_bin_vte", "cov_bin_anticoagulants_bnf")

file_list <- list.files(path = "output", pattern = "*4mofup\\.rds", full.names = TRUE)
throm_files <- grep("throm", file_list, value = TRUE)
anticoag_files <- grep("anticoag", file_list, value = TRUE)
df_throm <- lapply(throm_files, read_rds_keep_columns, columns = needed_columns)
df_anticoag <- lapply(anticoag_files, read_rds_keep_columns, columns = needed_columns)






# Add outcome to each data frame and combine
combined_throm <- add_outcome_and_combine(throm_files, df_throm)
combined_anticoag <- add_outcome_and_combine(anticoag_files, df_anticoag)

library(tidyr)

# Perform the sensitivity analysis for Anticoagulant Group
sa_anticoag <- combined_anticoag %>%
    group_by(outcome, cov_bin_anticoagulants_bnf) %>%
    summarize(
        count = n_distinct(patient_id, na.rm = TRUE),
        .groups = 'drop'
    )

# Pivot to wide format
sa_anticoag_wide <- sa_anticoag %>%
    pivot_wider(
        names_from = cov_bin_anticoagulants_bnf,
        values_from = count,
        names_prefix = "n_",
        values_fill = list(count = 0)
    )

# Rename columns for clarity
colnames(sa_anticoag_wide) <- c("Outcome", "n_Anticoagulants", "n_No_Anticoagulants")

# Print the result
print("Sensitivity Analysis - Anticoagulant Group (Wide Format):")
print(sa_anticoag_wide)

# Perform the sensitivity analysis for Thrombotic Group
sa_throm <- combined_throm %>%
    group_by(outcome, cov_bin_vte) %>%
    summarize(
        count = n_distinct(patient_id, na.rm = TRUE),
        .groups = 'drop'
    )

# Pivot to wide format
sa_throm_wide <- sa_throm %>%
    pivot_wider(
        names_from = cov_bin_vte,
        values_from = count,
        names_prefix = "n_",
        values_fill = list(count = 0)
    )

# Rename columns 
colnames(sa_throm_wide) <- c("Outcome", "n_Thrombotic_Event", "n_No_Thrombotic_Event")

# Print the result
print("Sensitivity Analysis - Thrombotic Group (Wide Format):")
print(sa_throm_wide)

# Write to files 
write.csv(sa_anticoag_wide,"output/anticoag_events_sensitivity.csv",row.names=FALSE)
write.csv(sa_throm_wide,"output/thromobotic_events_sensitivity.csv",row.names=FALSE)