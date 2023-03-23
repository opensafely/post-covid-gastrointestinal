library(readr)
library(dplyr)
library(magrittr)

# Specify redaction threshold --------------------------------------------------

threshold <- 6

# Source common functions ------------------------------------------------------
print('Source common functions')

source("analysis/utility.R")

# Load active analyses ---------------------------------------------------------
print('Load active analyses')

active_analyses <- readr::read_rds("lib/active_analyses.rds")%>%
filter(analysis=="main" & !outcome %in% c("out_date_bowel_ischaemia","out_date_intestinal_obstruction","out_date_nonalcoholic_steatohepatitis","out_date_variceal_gi_bleeding","out_date_belching"))
# Make empty table 2 -----------------------------------------------------------
print('Make empty table 2')

table2 <- data.frame(name = character(),
                     cohort = character(),
                     exposure = character(),
                     outcome = character(),
                     analysis = character(),
                     unexposed_person_days = numeric(),
                     unexposed_events = numeric(),
                     exposed_person_days = numeric(),
                     exposed_events = numeric(),
                     total_person_days = numeric(),
                     total_events = numeric(),
                     day0_events = numeric(),
                     total_exposed = numeric(),
                     sample_size = numeric())

# Record number of events and person days for each active analysis -------------
print('Record number of events and person days for each active analysis')

for (i in 1:nrow(active_analyses)) {
  
  ## Load data -----------------------------------------------------------------
  print(paste0("Load data for ",active_analyses$name[i]))

  
  df <- read_rds(paste0("output/model_input-",active_analyses$name[i],".rds"))
  df <- df[,c("patient_id","index_date","exp_date","out_date","end_date")]

  ## Calculate person days -----------------------------------------------------
  print('Calculate person days')
  
  df <- df %>% 
    dplyr::mutate(total_person_days = as.numeric((end_date - index_date))+1,
                  fup_end_unexposed = min(end_date, exp_date, na.rm = TRUE),
                  unexposed_person_days = as.numeric((fup_end_unexposed - index_date))+1,
                  exposed_person_days = as.numeric((exp_date - index_date))+1)
  
  ## Append to table 2 ---------------------------------------------------------
  print('Append to table 2')
  
  table2[nrow(table2)+1,] <- c(name = active_analyses$name[i],
                               cohort = active_analyses$cohort[i],
                               exposure = active_analyses$exposure[i],
                               outcome = active_analyses$outcome[i],
                               analysis = active_analyses$analysis[i],
                               unexposed_person_days = sum(df$unexposed_person_days),
                               unexposed_events = nrow(df[!is.na(df$out_date) & is.na(df$exp_date),]),
                               exposed_person_days = sum(df$exposed_person_days, na.rm = TRUE),
                               exposed_events = nrow(df[!is.na(df$out_date) & !is.na(df$exp_date),]),
                               total_person_days = sum(df$total_person_days),
                               total_events = nrow(df[!is.na(df$out_date),]),
                               day0_events = nrow(df[!is.na(df$out_date) & !is.na(df$exp_date) & df$exp_date==df$out_date,]),
                               total_exposed = nrow(df[!is.na(df$exp_date),]),
                               sample_size = nrow(df))

}


# Perform redaction ------------------------------------------------------------

table2[,setdiff(colnames(table2),c("name","cohort","exposure","outcome","analysis"))] <- lapply(table2[,setdiff(colnames(table2),c("name","cohort","exposure","outcome","analysis"))],
                                            FUN=function(y){roundmid_any(as.numeric(y), to=threshold)})

# Save Table 2 -----------------------------------------------------------------
print('Save Table 2')

write.csv(table2, "output/table2.csv")

table2_rounded <- table2[,c("name","cohort","exposure","outcome","analysis",
                            colnames(table2)[grepl("_rounded",colnames(table2))])]

write.csv(table2_rounded, "output/table2_rounded.csv")
