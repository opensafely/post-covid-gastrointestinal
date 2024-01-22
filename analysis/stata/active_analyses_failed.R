# This script creates an active analysis for failed models in R 


library(dplyr)

model_output_file <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Day0/models_30_11_2023/model_output_midpoint6.csv"
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
 success <- readxl::read_excel("../post-covid-outcome-tracker.xlsx",
                               sheet = "gastrointestinal",
                               col_types = c("text","text", "text", "text", "text", "text",
                                             "text", "text", "text", "text", "text",
                                             "text", "text", 
                                             "text", "text", "text", "text","text","text","text","text",
                                             "skip", "skip"))
 
 success <- tidyr::pivot_longer(success,
                                cols = setdiff(colnames(success),c("outcome","cohort")),
                                names_to = "analysis") 
 not_ran<- success %>% filter(value=="NA")%>%
   filter(!(cohort=="prevax" & analysis=="sub_covid_history"))
not_ran$name <- paste0("cohort_",not_ran$cohort, "-",not_ran$analysis, "-",not_ran$outcome)
active_analyses_not_ran<- active_analyses %>% 
  inner_join(not_ran%>%select(name),by=c("name"))
# Combine not_ran and failed 
active_analyses_not_ran$model<-NA
active_analyses_failed<-rbind(active_analyses_failed,active_analyses_not_ran)
 
saveRDS(active_analyses_failed, file = "lib/active_analyses_failed.rds", compress = "gzip")
