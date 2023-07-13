#Load data
data <- readRDS("lib/active_analyses.rds")

#Filter the data based on population, outcomes of interest and the analysis of interest
filtered_data <- subset(data, cohort == "vax" & outcome %in% c("out_date_upper_gi_bleeding",
                                                               "out_date_lower_gi_bleeding",
                                                               "out_date_variceal_gi_bleeding",
                                                               "out_date_nonvariceal_gi_bleeding") & analysis == "main")

#$ave the file
saveRDS(filtered_data, file = "lib/active_analyses_gi_bleeds.rds")
