# This script creates an active analysis for failed models in R 


library(dplyr)

model_output_file <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Extended followup/models/model_output.csv"
active_analyses <- readRDS("lib/active_analyses.rds")
all_models <- read.csv(model_output_file)

# failed models are those with hr>100 or hr is na

failed_models <- all_models %>% 
                            filter(hr>100 | is.na(hr)) %>% 
                            filter(grepl("days\\d+", term))

failed_models_reduced <- failed_models %>% 
                           select( name,analysis)

 active_analyses_failed<- active_analyses %>% 
                            inner_join(failed_models_reduced,by=c("name","analysis"))
 active_analyses_failed <- active_analyses_failed[!duplicated(active_analyses_failed$name), ]


  saveRDS(active_analyses_failed, file = "lib/active_analyses_failed.rds", compress = "gzip")
