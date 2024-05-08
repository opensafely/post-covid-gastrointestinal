# This script creates an active analysis for failed models in R 


library(dplyr)

active_analyses <- readRDS("lib/active_analyses.rds")
all_models <- read.csv(path_model_output)

# failed models are those with hr>100 for days1_28  or hr is na or hr>1000 for day0 conf_high is infinity

failed_models <- all_models %>% 
  filter(
    (as.numeric(hr) > 100 & term == "days1_28") | 
      (term == "days0_1" & as.numeric(hr) > 1000) |
      (grepl("^days[0-9]", term) & is.na(hr)) |
      conf_high == "Inf"
  )%>%
  filter(grepl("days\\d+", term))


# ###Exceptionally, Getting failed models from L4 (reading unique_failed_models.txt)
# failed_models <-data.frame(
# name= c(
#   "cohort_prevax-sub_age_18_39-acute_pancreatitis",
#   "cohort_prevax-sub_age_40_59-acute_pancreatitis",
#   "cohort_prevax-sub_age_40_59-gallstones_disease",
#   "cohort_prevax-sub_age_40_59-nonvariceal_gi_bleeding",
#   "cohort_prevax-sub_age_40_59-upper_gi_bleeding",
#   "cohort_prevax-sub_age_60_79-appendicitis",
#   "cohort_prevax-sub_age_60_79-ibs",
#   "cohort_prevax-sub_age_60_79-lower_gi_bleeding",
#   "cohort_prevax-sub_age_60_79-nonalcoholic_steatohepatitis",
#   "cohort_prevax-sub_age_80_110-acute_pancreatitis",
#   "cohort_prevax-sub_age_80_110-ibs",
#   "cohort_prevax-sub_covid_hospitalised-acute_pancreatitis",
#   "cohort_prevax-sub_covid_hospitalised-appendicitis",
#   "cohort_prevax-sub_covid_hospitalised-lower_gi_bleeding",
#   "cohort_prevax-sub_covid_hospitalised-peptic_ulcer",
#   "cohort_prevax-sub_ethnicity_asian-acute_pancreatitis",
#   "cohort_prevax-sub_ethnicity_asian-gallstones_disease",
#   "cohort_prevax-sub_ethnicity_black-upper_gi_bleeding",
#   "cohort_prevax-sub_ethnicity_other-gallstones_disease",
#   "cohort_prevax-sub_ethnicity_other-ibs",
#   "cohort_prevax-sub_priorhistory_true-gallstones_disease",
#   "cohort_prevax-sub_prioroperations_true-gastro_oesophageal_reflux_disease",
#   "cohort_prevax-sub_prioroperations_true-ibs",
#   "cohort_prevax-sub_sex_female-acute_pancreatitis",
#   "cohort_prevax-sub_sex_female-gastro_oesophageal_reflux_disease",
#   "cohort_prevax-sub_sex_female-ibs",
#   "cohort_prevax-sub_sex_male-nonalcoholic_steatohepatitis",
#   "cohort_prevax-sub_sex_male-upper_gi_bleeding",
#   "cohort_prevax-sub_sex_male-nonvariceal_gi_bleeding",
#   "cohort_vax-sub_age_80_110-nonvariceal_gi_bleeding",
#   "cohort_vax-sub_age_80_110-lower_gi_bleeding",
#   "cohort_vax-sub_age_80_110-upper_gi_bleeding"
# )
# )
#
 failed_models_reduced <- failed_models %>% 
                            select( name,analysis,model)

 active_analyses_failed<- active_analyses %>% 
                            inner_join(failed_models_reduced,by=c("name","analysis"))
 
 active_analyses_failed <- active_analyses_failed[!duplicated(active_analyses_failed$name), ]

# Add models which didn't run at all 
 actions <- read.csv("lib/actions_20240317.csv")
 

 not_ran_actions<- actions %>% filter(!success)
 not_ran_actions <- not_ran_actions %>%
  mutate(name= gsub("cox_ipw-","",model))
active_analyses_not_ran<- active_analyses %>% 
  inner_join(not_ran_actions%>%select(name),by=c("name"))
# Combine not_ran_actions and failed 
active_analyses_not_ran$model<-NA
active_analyses_failed<-rbind(active_analyses_failed,active_analyses_not_ran)
 
saveRDS(active_analyses_failed, file = "lib/active_analyses_failed.rds", compress = "gzip")
