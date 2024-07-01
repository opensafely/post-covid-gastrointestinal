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
# 1. CLEAN TABLE 2 FUNCTION
###############################################

clean_table_2 <- function(df) {
  
  df <- df %>%
    mutate(outcome = str_remove(outcome, "out_date_")) %>% 
    mutate(outcome = gsub("gi", "gastrointestinal", outcome, fixed = TRUE))%>%
    mutate(outcome = str_to_title(outcome)) %>%
    select(outcome, analysis, unexposed_person_days, unexposed_events_midpoint6, exposed_person_days, exposed_events_midpoint6, total_person_days, total_events_derived, day0_events_midpoint6, total_exposed_midpoint6, sample_size_midpoint6) %>%
    filter(analysis %in% c("sub_covid_hospitalised", "sub_covid_nonhospitalised"))
  
  df$outcome <- str_replace_all(df$outcome, "_", " ")
  
  #unexposed
  df_unexposed <- df %>% select(outcome, analysis, unexposed_person_days,	unexposed_events_midpoint6)
  df_unexposed$period <- "unexposed"
  df_unexposed <- df_unexposed %>% rename(event_count = unexposed_events_midpoint6,
                                         person_days = unexposed_person_days)
  
  #exposed
  df_exposed <- df %>% select(outcome, analysis, exposed_person_days,	exposed_events_midpoint6)
  df_exposed$period <- "exposed"
  df_exposed <- df_exposed %>% rename(event_count = exposed_events_midpoint6,
                                      person_days = exposed_person_days)
  
  #bind rows
  table2 <- rbind(df_unexposed, df_exposed)
  rm(df_unexposed, df_exposed)

  table2 <- table2 %>% mutate(across(c("event_count","person_days"), as.numeric))
  
  # Add in incidence rate
  table2[,"Incidence rate*"] <- add_commas(round((table2$event_count/(table2$person_days/365.25))*100000))
  table2[,"Event/person-years"] <- paste0(add_commas(table2$event_count), "/", add_commas(round((table2$person_days/365.25))))
  
  table2$period <- ifelse(table2$period == "unexposed", "No COVID-19", table2$period)
  table2$period <- ifelse(table2$period == "exposed" & table2$analysis == "sub_covid_hospitalised", "Hospitalised COVID-19", table2$period)
  table2$period <- ifelse(table2$period == "exposed" & table2$analysis == "sub_covid_nonhospitalised", "Non-hospitalised COVID-19", table2$period)
  
  table2[,c("analysis","person_days")] <- NULL
  table2 <- table2[!duplicated(table2),]

  # Re-order columns -----------------------------------------------------------
  table2 <- table2 %>% select("outcome","period","Event/person-years","Incidence rate*")

  return(table2)
  
}

#Load files

table2_prevax <- readr::read_csv(path_table2_prevax,
                      show_col_types = FALSE) 
table2_vax <- readr::read_csv(path_table2_vax,
                      show_col_types = FALSE) 
table2_unvax <- readr::read_csv(path_table2_unvax,
                      show_col_types = FALSE) 

table2_anticoag_prevax <- readr::read_csv(path_table2_anticoag_prevax,
                      show_col_types = FALSE)   
table2_anticoag_vax <- readr::read_csv(path_table2_anticoag_unvax,
                      show_col_types = FALSE)  
table2_anticoag_unvax <- readr::read_csv(path_table2_anticoag_vax,
                      show_col_types = FALSE)  

table2_thromb_prevax <- readr::read_csv(path_table2_thromb_prevax,
                      show_col_types = FALSE)   
table2_thromb_vax <- readr::read_csv(path_table2_thromb_unvax,
                      show_col_types = FALSE)  
table2_thromb_unvax <- readr::read_csv(path_table2_thromb_vax,
                      show_col_types = FALSE)  

#reformatting additional analysis table 2 --------------------------------------------------
# column names
colnames(table2_anticoag_prevax)[colnames(table2_anticoag_prevax) == 'total_events_midpoint6_derived'] <- 'total_events_derived'
colnames(table2_anticoag_vax)[colnames(table2_anticoag_vax) == 'total_events_midpoint6_derived'] <- 'total_events_derived'
colnames(table2_anticoag_unvax)[colnames(table2_anticoag_unvax) == 'total_events_midpoint6_derived'] <- 'total_events_derived'

colnames(table2_thromb_prevax)[colnames(table2_thromb_prevax) == 'total_events_midpoint6_derived'] <- 'total_events_derived'
colnames(table2_thromb_vax)[colnames(table2_thromb_vax) == 'total_events_midpoint6_derived'] <- 'total_events_derived'
colnames(table2_thromb_unvax)[colnames(table2_thromb_unvax) == 'total_events_midpoint6_derived'] <- 'total_events_derived'

# re-specifying outcome variable
table2_anticoag_prevax$stratify <- ifelse(grepl("true", table2_anticoag_prevax$analysis), "_with_anticoagulants", "_without_anticoagulants")
table2_anticoag_prevax$outcome <- paste(table2_anticoag_prevax$outcome, table2_anticoag_prevax$stratify)
table2_anticoag_vax$stratify <- ifelse(grepl("true", table2_anticoag_vax$analysis), "_with_anticoagulants", "_without_anticoagulants")
table2_anticoag_vax$outcome <- paste(table2_anticoag_vax$outcome, table2_anticoag_vax$stratify)
table2_anticoag_unvax$stratify <- ifelse(grepl("true", table2_anticoag_unvax$analysis), "_with_anticoagulants", "_without_anticoagulants")
table2_anticoag_unvax$outcome <- paste(table2_anticoag_unvax$outcome, table2_anticoag_prevax$stratify)

table2_thromb_prevax$stratify <- ifelse(grepl("true", table2_thromb_prevax$analysis), "_with_thrombotic_event", "_without_thrombotic_event")
table2_thromb_prevax$outcome <- paste(table2_thromb_prevax$outcome, table2_thromb_prevax$stratify)
table2_thromb_vax$stratify <- ifelse(grepl("true", table2_thromb_vax$analysis), "_with_thrombotic_event", "_without_thrombotic_event")
table2_thromb_vax$outcome <- paste(table2_thromb_vax$outcome, table2_thromb_vax$stratify)
table2_thromb_unvax$stratify <- ifelse(grepl("true", table2_thromb_unvax$analysis), "_with_thrombotic_event", "_without_thrombotic_event")
table2_thromb_unvax$outcome <- paste(table2_thromb_unvax$outcome, table2_thromb_prevax$stratify)

# renaming analysis
table2_anticoag_prevax['analysis'][table2_anticoag_prevax['analysis'] == c('sub_covid_hospitalised_te_true','sub_covid_hospitalised_te_false')] <- 'sub_covid_hospitalised'
table2_anticoag_vax['analysis'][table2_anticoag_vax['analysis'] == c('sub_covid_hospitalised_te_true','sub_covid_hospitalised_te_false')] <- 'sub_covid_hospitalised'
table2_anticoag_unvax['analysis'][table2_anticoag_unvax['analysis'] == c('sub_covid_hospitalised_te_true','sub_covid_hospitalised_te_false')] <- 'sub_covid_hospitalised'

table2_thromb_prevax['analysis'][table2_thromb_prevax['analysis'] == c('sub_covid_hospitalised_ac_true','sub_covid_hospitalised_ac_false')] <- 'sub_covid_hospitalised'
table2_thromb_vax['analysis'][table2_thromb_vax['analysis'] == c('sub_covid_hospitalised_ac_true','sub_covid_hospitalised_ac_false')] <- 'sub_covid_hospitalised'
table2_thromb_unvax['analysis'][table2_thromb_unvax['analysis'] == c('sub_covid_hospitalised_sc_true','sub_covid_hospitalised_ac_false')] <- 'sub_covid_hospitalised'

#Apply clean table 2 function --------------------------------------------------
table2_prevax_format <- clean_table_2(table2_prevax)
table2_vax_format <- clean_table_2(table2_vax)
table2_unvax_format <- clean_table_2(table2_unvax)

table2_anticoag_prevax_format <- clean_table_2(table2_anticoag_prevax)
table2_anticoag_vax_format <- clean_table_2(table2_anticoag_vax)
table2_anticoag_unvax_format <- clean_table_2(table2_anticoag_unvax)

table2_thromb_prevax_format <- clean_table_2(table2_thromb_prevax)
table2_thromb_vax_format <- clean_table_2(table2_thromb_vax)
table2_thromb_unvax_format <- clean_table_2(table2_thromb_unvax)

#Rename columns vax and unvax --------------------------------------------------
colnames(table2_vax_format)[colnames(table2_vax_format) == 'Event/person-years'] <- 'Vax:Event/person-years'  
colnames(table2_unvax_format)[colnames(table2_unvax_format) == 'Event/person-years'] <- 'Unvax:Event/person-years'  
colnames(table2_vax_format)[colnames(table2_vax_format) == 'Incidence rate*'] <- 'Vax:Incidence rate*'  
colnames(table2_unvax_format)[colnames(table2_unvax_format) == 'Incidence rate*'] <- 'Unvax:Incidence rate*'  

#Rename columns vax and unvax --------------------------------------------------
colnames(table2_vax_format)[colnames(table2_vax_format) == 'Event/person-years'] <- 'Vax:Event/person-years'  
colnames(table2_unvax_format)[colnames(table2_unvax_format) == 'Event/person-years'] <- 'Unvax:Event/person-years'  
colnames(table2_vax_format)[colnames(table2_vax_format) == 'Incidence rate*'] <- 'Vax:Incidence rate*'  
colnames(table2_unvax_format)[colnames(table2_unvax_format) == 'Incidence rate*'] <- 'Unvax:Incidence rate*'  

colnames(table2_anticoag_vax_format)[colnames(table2_anticoag_vax_format) == 'Event/person-years'] <- 'Vax:Event/person-years'  
colnames(table2_anticoag_unvax_format)[colnames(table2_anticoag_unvax_format) == 'Event/person-years'] <- 'Unvax:Event/person-years'  
colnames(table2_anticoag_vax_format)[colnames(table2_anticoag_vax_format) == 'Incidence rate*'] <- 'Vax:Incidence rate*'  
colnames(table2_anticoag_unvax_format)[colnames(table2_anticoag_unvax_format) == 'Incidence rate*'] <- 'Unvax:Incidence rate*'  

colnames(table2_thromb_vax_format)[colnames(table2_thromb_vax_format) == 'Event/person-years'] <- 'Vax:Event/person-years'  
colnames(table2_thromb_unvax_format)[colnames(table2_thromb_unvax_format) == 'Event/person-years'] <- 'Unvax:Event/person-years'  
colnames(table2_thromb_vax_format)[colnames(table2_thromb_vax_format) == 'Incidence rate*'] <- 'Vax:Incidence rate*'  
colnames(table2_thromb_unvax_format)[colnames(table2_thromb_unvax_format) == 'Incidence rate*'] <- 'Unvax:Incidence rate*'  

#Combine tables by columns -----------------------------------------------------

table2 <- Reduce(function (...) { merge(..., all = TRUE) },  # Full join
                            list(table2_prevax_format, table2_vax_format, table2_unvax_format))
table2_anticoag <- Reduce(function (...) { merge(..., all = TRUE) },  # Full join
                 list(table2_anticoag_prevax_format, table2_anticoag_vax_format, table2_anticoag_unvax_format))
table2_thromb <- Reduce(function (...) { merge(..., all = TRUE) },  # Full join
                          list(table2_thromb_prevax_format, table2_thromb_vax_format, table2_thromb_unvax_format))

table2 <- rbind(table2, table2_anticoag, table2_thromb)

# Add labels, re-order rows, a clean names -------------------------------------

table2$period <- factor(table2$period, levels = c("No COVID-19",
                                                  "Hospitalised COVID-19",
                                                  "Non-hospitalised COVID-19"))
table2$outcome<- gsub("gi","gastrointestinal", table2$outcome)
table2$outcome<- stringr::str_trim(gsub("disease","", table2$outcome))
table2$outcome<-factor(table2$outcome,levels =c("Nonvariceal gastrointestinal bleeding",
                                                "Nonvariceal gastrointestinal bleeding  With thrombotic event",
                                                "Nonvariceal gastrointestinal bleeding  Without thrombotic event",
                                                "Nonvariceal gastrointestinal bleeding  With anticoagulants",
                                                "Nonvariceal gastrointestinal bleeding  Without anticoagulants",
                                                "Acute pancreatitis",
                                                "Peptic ulcer",
                                                "Appendicitis",
                                                "Lower gastrointestinal bleeding",
                                                "Lower gastrointestinal bleeding  With thrombotic event",
                                                "Lower gastrointestinal bleeding  Without thrombotic event",
                                                "Lower gastrointestinal bleeding  With anticoagulants",
                                                "Lower gastrointestinal bleeding  Without anticoagulants",
                                                "Upper gastrointestinal bleeding",
                                                "Upper gastrointestinal bleeding  With thrombotic event",
                                                "Upper gastrointestinal bleeding  Without thrombotic event",
                                                "Upper gastrointestinal bleeding  With anticoagulants",
                                                "Upper gastrointestinal bleeding  Without anticoagulants",
                                                "Gastro oesophageal reflux",
                                                "Gallstones", 
                                                "Ibs",
                                                "Dyspepsia",
                                                "Nonalcoholic steatohepatitis",
                                                "Variceal gastrointestinal bleeding",
                                                "Variceal gastrointestinal bleeding  With thrombotic event",
                                                "Variceal gastrointestinal bleeding  Without thrombotic event",
                                                "Variceal gastrointestinal bleeding  With anticoagulants",
                                                "Variceal gastrointestinal bleeding  Without anticoagulants"))

table2 <- table2[order(table2$outcome, table2$period),]

table2 <- table2 %>%
  rename_with(~ gsub("...", "", .x, fixed = T))


#Format table for Word ---------------------------------------------------------
table2_format <- table2 %>%
  flextable::flextable() %>% theme_vanilla() %>% #theme could be removed
  padding(padding = 0, part = "all") %>% 
  merge_v(~ outcome) %>%
  add_header_row(values = c("", "", "Pre-vaccination cohort (Jan 1 2020 to Dec 14 2021)", "", "Vaccinated cohort (June 1 to Dec 14 2021)", "", "Unvaccinated cohort (June 1 to Dec 14 2021)", "")) %>%
  set_caption(as_paragraph(as_chunk("Table 2. Number of gastrointestinal events in prevaccination, vaccinated and unvaccinated cohorts, with person-years of follow-up, by COVID-19 severity. *Incidence rates are per 100,000 person-years", 
    props = fp_text_default(bold = TRUE))), align_with_table = F) %>%
  set_header_labels("outcome" = "Event", 'period' = 'COVID-19 severity', 
                    'Vax:Event/person-years5' = 'Event/person-years', 'Vax:Incidence rate*' = 'Incidence rate*', 
                    'Unvax:Event/person-years7' = 'Event/person-years', 'Unvax:Incidence rate*' = 'Incidence rate*') %>%
  bold(j = 1, bold = TRUE, part = "body") %>%
  align(j = c(3:8), align = "right", part = "body") %>%
  fontsize(size = 10)

# Set table 2 properties 
sect_properties <- prop_section(
  page_size = page_size(
    orient = "landscape",
    width = 8.3, height = 11.7
  ),
  type = "continuous",
  page_margins = page_mar()
)

#Save table 2
save_as_docx(table2_format, path = paste0("output/post_release/table2_formatted_.docx"), pr_section = sect_properties)
#write.csv(table2, paste0(output_dir,"table2.csv"),row.names = F)

#Notes 
#While using word:
#1. Change margins to narrow.
#2. Merge horizontally Pre-vaccination, vaccionation and unvaccinated with the right cell, respectivelly.
#3. IF theme_vanilla is not used, you will need to add borders between each covariate, or remove unnecessary lines.
#4. Change font, CVD uses "Calibri".
