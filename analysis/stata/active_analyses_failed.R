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
                           select( name,analysis)

 active_analyses_failed<- active_analyses %>% 
                            inner_join(failed_models_reduced,by=c("name","analysis"))
 active_analyses_failed <- active_analyses_failed[!duplicated(active_analyses_failed$name), ]


  saveRDS(active_analyses_failed, file = "lib/active_analyses_failed.rds", compress = "gzip")
