library(magrittr)
library(data.table)
library(tidyverse)

# Read and filter active analyses
print('Read and filter active analyses')
active_analyses <- readr::read_rds("lib/active_analyses.rds")
active_analyses <- active_analyses%>%
filter(analysis=="sub_covid_hospitalised" &  grepl("bleeding", outcome, ignore.case = TRUE) )

active_analyses_sensitivity <- as.data.frame(replicate(ncol(active_analyses), vector()))
names(active_analyses_sensitivity) <- names(active_analyses)

# Add the suffixes to the new analyses names 
for (i in 1:nrow(active_analyses)) {
  name_suffixes <- c("_throm_True_sensitivity", "_throm_False_sensitivity", "_anticoag_True_senistivity", "_anticoag_False_sensitivity")
  
  for (suffix in name_suffixes) {
    active_analyses_sensitivity <- rbind(active_analyses_sensitivity, active_analyses[i, ])
    active_analyses_sensitivity$name[nrow(active_analyses_sensitivity)] <- paste0(active_analyses_sensitivity$name[nrow(active_analyses_sensitivity)], suffix)
    
    # analysis is the suffix after removing _ 
    active_analyses_sensitivity$analysis[nrow(active_analyses_sensitivity)] <- substr(suffix, 2, nchar(suffix))

  }
  
  # Remove 'cov_bin_anticoagulants_bnf' from covariate_other for rows with 'anticoag' in name
  if (grepl("anticoag", active_analyses_sensitivity$name[nrow(active_analyses_sensitivity)])) {
    active_analyses_sensitivity$covariate_other[nrow(active_analyses_sensitivity)] <-
      gsub("cov_bin_anticoagulants_bnf;", "", active_analyses_sensitivity$covariate_other[nrow(active_analyses_sensitivity)])
    active_analyses_sensitivity$covariate_other[nrow(active_analyses_sensitivity)] <-
      gsub(";cov_bin_anticoagulants_bnf", "", active_analyses_sensitivity$covariate_other[nrow(active_analyses_sensitivity)])
  }
}
write_rds(active_analyses_sensitivity,"lib/active_analyses_sensitivity.rds")
