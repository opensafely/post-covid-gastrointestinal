#### Combine R and stata model output and filter the data to be used in plots####
library(dplyr)

# Specify paths ----------------------------------------------------------------
print('Specify paths')

# NOTE: 
# This file is used to specify paths and is in the .gitignore to keep your information secret.
# A file called specify_paths_example.R is provided for you to fill in.
# Please remove "_example" from the file name and add your specific file paths before running this script.

source("analysis/post_release/specify_paths.R")

# Load model output ------------------------------------------------------------
print('Load model output')

actvie_analyses<- readRDS("lib/active_analyses.rds")

df <- readr::read_csv(path_model_r_output,
                      show_col_types = FALSE)
df$source <- "R"

# Restrict to plot data --------------------------------------------------------
print('Restrict to plot data')

df <- df[grepl("day",df$term),
         c("name", "cohort","analysis","outcome","model",
           "outcome_time_median","term","hr","conf_low","conf_high","source")]

# Load stata model output ------------------------------------------------------
print('Load stata model output')

tmp <- readr::read_csv(path_model_stata_output_1,
                       show_col_types = FALSE)
tmp$outcome<- gsub("_cox_model","",tmp$outcome)
tmp$name<- gsub("_cox_model","",tmp$name)
tmp$name<-paste0("cohort_",tmp$name)
  
  tmp$source <- "Stata"

df$rank <- 0
tmp$rank <- 1

tmp <- tmp[,colnames(df)]
df <- rbind(df,tmp)
df <- df %>%
  dplyr::group_by(outcome,cohort,analysis) %>%
  dplyr::top_n(1, rank) %>%
  dplyr::ungroup()
  
#Exceptionally merge 2 stata outputs together because we ran them on 2 batches 
 
tmp2 <- readr::read_csv(path_model_stata_output_2,
                         show_col_types = FALSE) 
tmp2$outcome<- gsub("_cox_model","",tmp2$outcome)
tmp2$name<- gsub("_cox_model","",tmp2$name)
tmp2$name<-paste0("cohort_",tmp2$name)

tmp2$source <- "Stata"

df$rank <- 0
tmp2$rank <- 1

tmp2 <- tmp2[,colnames(df)]
df <- rbind(df,tmp2)

df <- df %>%
  dplyr::group_by(outcome,cohort,analysis) %>%
  dplyr::top_n(1, rank) %>%
  dplyr::ungroup()

df$rank <- NULL

# Save plot data ---------------------------------------------------------------
print('Save plot data')

df <- df[!grepl("detailed",df$analysis),]
readr::write_csv(df, "plot_model_output.csv")

