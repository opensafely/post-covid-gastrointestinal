
library(dplyr)

model_output<- read.csv("output/model_output_midpoint6.csv")
failed_models <- model_output %>% 
                            filter(as.numeric(hr)>100,term=="days1_28"| term=="days0_1", as.numeric(hr>1000) |grepl("^days[0-9]", term), is.na(hr) | conf_high=="Inf") %>% 
                            filter(grepl("days\\d+", term))
unique_models<- unique(failed_models$name)
write.csv(failed_models,"output/not-for-review/failed_models_onserver.csv",row.names=FALSE)
sink("output/not-for-review/unique_failed_models.txt")
print(unique_models)
sink()