results_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/table2/"
output_dir<-"../../output/"

  table2_raw<-read.csv(paste0(results_dir,"table2_main_27022023.csv"))
  table2_raw <- table2_raw %>% select(name,outcome,cohort,unexposed_events, exposed_events)
  
  table2_pre_expo <- table2_raw %>% select(name, outcome,cohort, unexposed_events)
  table2_pre_expo$period <- "unexposed"
  table2_pre_expo <- table2_pre_expo %>% rename(event_count = unexposed_events)
  
  table2_post_expo <- table2_raw %>% select(name, outcome,cohort, exposed_events)
  table2_post_expo$period <- "post_expo"
  table2_post_expo <- table2_post_expo %>% rename(event_count = exposed_events)
  
  table2 <- rbind(table2_pre_expo,table2_post_expo)
  
  rm(table2_pre_expo,table2_post_expo,table2_raw)
  
  
  table2$period <- ifelse(table2$period=="unexposed","No COVID-19",table2$period)
  
  table2[,"analysis"] <- NULL
  table2 <- table2[!duplicated(table2), ]
  
  # Make columns for exposure time -----------------------------------------------
  
  table2 <- tidyr::pivot_wider(table2, names_from = "period", values_from = "event_count")
  
  #Add totals columm
  table2 <- table2 %>% mutate(across(c("No COVID-19","After hospitalised COVID-19","After non-hospitalised COVID-19"),as.numeric))
  table2$Total <- rowSums(table2[,c(2,3,4)])
  
  
  
  
  library(tidyr)
  library(dplyr)
  
  library(tidyr)
  table2_raw_main<-read.csv(paste0(results_dir,"table2_main_27022023.csv"))
  table2_raw_sub<-read.csv(paste0(results_dir,"table2_rounded_subcovid_sev_hist_07032023.csv"))
  table2_raw<-rbind(table2_raw_sub,table2_raw_main)
  
  table2_formatted <- table2_raw %>% 
    select(outcome, analysis, cohort, exposed_events, unexposed_events) %>% 
    pivot_wider(
      id_cols = c(outcome, analysis),
      names_from = cohort,
      values_from = c(exposed_events, unexposed_events),
      names_sep = "_"
    )%>%
    mutate(outcome=str_replace(outcome,"out_date_",""))%>%

    arrange(outcome, analysis)
  table2_formatted%>%
    distinct(outcome, .keep_all = TRUE)%>%View()
  
library(kableExtra)
 table2_formatted%>%
    filter(!outcome%in%c("vomiting","nausea","diarrhoea","bloody_stools","abdominal_paindiscomfort","abdominal_distension","belching"))%>%
    mutate(outcome = ifelse(row_number() %% 4 != 1, " ", outcome))%>%kbl()%>%
    kable_styling()
  

  
  