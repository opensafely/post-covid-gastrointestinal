# CREATE COMBINED (3 COHORT) TABLE 2 FOR POST-COVID MANUSCRIPTS

###############################################
# 0. Load relevant libraries and read in data #
###############################################

library(readr)
library(dplyr)
library(data.table)
library(tidyverse)
library(flextable)
library(officer)
library(scales)
library(broman)

# Specify paths ----------------------------------------------------------------
print('Specify paths')

# NOTE: 
# This file is used to specify paths and is in the .gitignore to keep your information secret.
# A file called specify_paths_example.R is provided for you to fill in.
# Please remove "_example" from the file name and add your specific file paths before running this script.

source("analysis/post_release/specify_paths.R")

###############################################
# 1. CLEAN TABLE 3 FUNCTIONS
###############################################

thrombotic_clean_table_3 <- function(df) {
  
  df <- df %>%  
    mutate(outcome = str_remove(outcome, "out_date_")) %>% 
    mutate(outcome = gsub("gi", "gastrointestinal", outcome, fixed = TRUE))%>%
    mutate(outcome = str_to_title(outcome)) %>%
    select(cohort, outcome, analysis, exposed_events_midpoint6)

  df$outcome <- str_replace_all(df$outcome, "_", " ")

  hospitalised <- aggregate(df$exposed_events_midpoint6 ~ df$outcome, df, sum)
  colnames(hospitalised)[colnames(hospitalised) == 'df$outcome'] <- 'outcome'
  df_new <- merge(df, hospitalised, by="outcome")

  df_new <- df_new %>% filter(!grepl("false", analysis))

  colnames(df_new)[colnames(df_new) == 'exposed_events_midpoint6'] <- 'events'
  df_new <- rename(df_new, 'Hospitalised' = "df$exposed_events_midpoint6")

  df_new$Npercent_derived <- paste0(df_new$events,"",
                                  paste0(" (",round(100*(df_new$events/df_new$Hospitalised),1),"%)"))

  table3 <- df_new %>%
    select(cohort, outcome, Hospitalised, Npercent_derived)
  
  colnames(table3)[colnames(table3) == 'Npercent_derived'] <- 'With thrombotic event'

return(table3)

}

anticoag_clean_table_3 <- function(df) {
  
  df <- df %>%  
    mutate(outcome = str_remove(outcome, "out_date_")) %>% 
    mutate(outcome = gsub("gi", "gastrointestinal", outcome, fixed = TRUE))%>%
    mutate(outcome = str_to_title(outcome)) %>%
    select(cohort, outcome, analysis, exposed_events_midpoint6)
  
  df$outcome <- str_replace_all(df$outcome, "_", " ")
  
  table3 <- df %>% 
    filter(!grepl("false", analysis)) %>%
    select(cohort, outcome, exposed_events_midpoint6)

  colnames(table3)[colnames(table3) == 'exposed_events_midpoint6'] <- 'With anticoagulant'
  
  return(table3)
  
}

###############################################
# 2. UPLOAD DATA
###############################################

# mistake in table 2 script whereby te (thrombotic event) was labeled anticoag and vice versa
table3_thromb_prevax <- readr::read_csv(path_table2_anticoag_prevax,
                                        show_col_types = FALSE)   
table3_thromb_vax <- readr::read_csv(path_table2_anticoag_unvax,
                                     show_col_types = FALSE)  
table3_thromb_unvax <- readr::read_csv(path_table2_anticoag_vax,
                                       show_col_types = FALSE)  

table3_anticoag_prevax <- readr::read_csv(path_table2_thromb_prevax,
                                          show_col_types = FALSE)   
table3_anticoag_vax <- readr::read_csv(path_table2_thromb_unvax,
                                       show_col_types = FALSE)  
table3_anticoag_unvax <- readr::read_csv(path_table2_thromb_vax,
                                         show_col_types = FALSE)  

###############################################
# 3. Apply clean table 3 functions
###############################################

table3_anticoag_prevax_format <- anticoag_clean_table_3(table3_anticoag_prevax)
table3_anticoag_vax_format <- anticoag_clean_table_3(table3_anticoag_vax)
table3_anticoag_unvax_format <- anticoag_clean_table_3(table3_anticoag_unvax)

table3_thromb_prevax_format <- thrombotic_clean_table_3(table3_thromb_prevax)
table3_thromb_vax_format <- thrombotic_clean_table_3(table3_thromb_vax)
table3_thromb_unvax_format <- thrombotic_clean_table_3(table3_thromb_unvax)

###############################################
# 4. Combine tables
###############################################

table3_anticoag <- rbind(table3_anticoag_prevax_format, table3_anticoag_vax_format, table3_anticoag_unvax_format)
table3_thromb <- rbind(table3_thromb_prevax_format, table3_thromb_vax_format, table3_thromb_unvax_format)

table3 <- Reduce(function (...) { merge(..., all = TRUE) },  # Full join
                 list(table3_anticoag, table3_thromb))

table3$`With anticoagulant` <- paste0(table3$`With anticoagulant`,"",
                                  paste0(" (",round(100*(table3$`With anticoagulant`/table3$Hospitalised),1),"%)"))

###############################################
# 5. Ordering table
###############################################
table3 <- table3 %>% select(outcome, cohort, Hospitalised, 'With thrombotic event', `With anticoagulant`)

table3$cohort <- ifelse(table3$cohort == "prevax", "Pre-vaccination", table3$cohort)
table3$cohort <- ifelse(table3$cohort == "vax", "Vaccinated", table3$cohort)
table3$cohort <- ifelse(table3$cohort == "unvax", "Unvaccinated", table3$cohort)

table3$cohort <- factor(table3$cohort, levels = c("Pre-vaccination",
                                                  "Vaccinated",
                                                  "Unvaccinated"))

table3$outcome<-factor(table3$outcome,levels =c("Nonvariceal gastrointestinal bleeding",
                                                "Lower gastrointestinal bleeding",
                                                "Upper gastrointestinal bleeding",
                                                "Variceal gastrointestinal bleeding"))

table3 <- table3[order(table3$outcome, table3$cohort),]

###############################################
# 5. Save table
###############################################
write.csv(table3, paste0("output/post_release/table3_format_.csv"),row.names = F)

