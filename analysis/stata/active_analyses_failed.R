# This script creates an active analysis for failed models in R 


library(dplyr)

model_output_file <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/death_fix20240305/model_output_midpoint6.csv"
active_analyses <- readRDS("lib/active_analyses.rds")
all_models <- read.csv(model_output_file)

# failed models are those with hr>100 for days1_28  or hr is na or conf_high is infinity

failed_models <- all_models %>% 
                            filter(as.numeric(hr)>100,term=="days1_28" | is.na(hr) | conf_high=="Inf") %>% 
                            filter(grepl("days\\d+", term))

failed_models_reduced <- failed_models %>% 
                           select( name,analysis,model)

 active_analyses_failed<- active_analyses %>% 
                            inner_join(failed_models_reduced,by=c("name","analysis"))
 active_analyses_failed <- active_analyses_failed[!duplicated(active_analyses_failed$name), ]

# Add models which didn't run at all 
 actions <- read.csv("lib/actions_20240305.csv")
 

 not_ran_actions<- actions %>% filter(!success)
 not_ran_actions <- not_ran_actions %>%
  mutate(name= gsub("cox_ipw-","",model))
active_analyses_not_ran<- active_analyses %>% 
  inner_join(not_ran_actions%>%select(name),by=c("name"))
# Combine not_ran_actions and failed 
active_analyses_not_ran$model<-NA
active_analyses_failed<-rbind(active_analyses_failed,active_analyses_not_ran)
 
saveRDS(active_analyses_failed, file = "lib/active_analyses_failed.rds", compress = "gzip")
