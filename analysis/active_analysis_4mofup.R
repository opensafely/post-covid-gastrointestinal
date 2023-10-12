library(magrittr)
library(data.table)
library(tidyverse)

# Read and filter active analyses
print('Read and filter active analyses')
active_analyses <- readr::read_rds("lib/active_analyses.rds")
active_analyses <- active_analyses%>%
filter(analysis=="sub_covid_hospitalised" &  grepl("bleeding", outcome, ignore.case = TRUE) )

active_analyses_4mofup <- as.data.frame(replicate(ncol(active_analyses), vector()))
names(active_analyses_4mofup) <- names(active_analyses)

# Add the suffixes to the new analyses names 
for (i in 1:nrow(active_analyses)) {
  name_suffixes <- c("_throm_True_4mofup", "_throm_False_4mofup", "_anticoag_True_4mofup", "_anticoag_False_4mofup")
  
  for (suffix in name_suffixes) {
    active_analyses_4mofup <- rbind(active_analyses_4mofup, active_analyses[i, ])
    active_analyses_4mofup$name[nrow(active_analyses_4mofup)] <- paste0(active_analyses_4mofup$name[nrow(active_analyses_4mofup)], suffix)
    
    # analysis is the suffix after removing _ 
    active_analyses_4mofup$analysis[nrow(active_analyses_4mofup)] <- substr(name_suffixes, 2, nchar(name_suffixes))

  }
  
  # Remove 'cov_bin_anticoagulants_bnf' from covariate_other for rows with 'anticoag' in name
  if (grepl("anticoag", active_analyses_4mofup$name[nrow(active_analyses_4mofup)])) {
    active_analyses_4mofup$covariate_other[nrow(active_analyses_4mofup)] <-
      gsub("cov_bin_anticoagulants_bnf;", "", active_analyses_4mofup$covariate_other[nrow(active_analyses_4mofup)])
    active_analyses_4mofup$covariate_other[nrow(active_analyses_4mofup)] <-
      gsub(";cov_bin_anticoagulants_bnf", "", active_analyses_4mofup$covariate_other[nrow(active_analyses_4mofup)])
  }
}
write_rds(active_analyses_4mofup,"lib/active_analysis_4mofup.rds")
