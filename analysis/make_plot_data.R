library(dplyr)
# Load model output ------------------------------------------------------------
print('Load model output')

output_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/death_fix20240305/"
path_model_output<-paste0(output_dir,"model_output_midpoint6.csv")


df <- readr::read_csv(path_model_output,
                      show_col_types = FALSE)

df$source <- "R"

# Restrict to plot data --------------------------------------------------------
print('Restrict to plot data')

df <- df[grepl("day",df$term),
         c("name", "cohort","analysis","outcome","model",
           "outcome_time_median","term","hr","conf_low","conf_high","source")]

# Load stata model output ------------------------------------------------------
print('Load stata model output')

tmp <- readr::read_csv(paste0(output_dir,"stata_model_output_midpoint6.csv"),
                       show_col_types = FALSE)
tmp$outcome<- gsub("_cox_model","",tmp$outcome)
tmp$name<- gsub("_cox_model","",tmp$name)
tmp$name<-paste0("cohot_",tmp$name)
  
  tmp$source <- "Stata"

df$rank <- 0
tmp$rank <- 1

tmp <- tmp[,colnames(df)]
df <- rbind(df,tmp)

df <- df %>%
  dplyr::group_by(outcome,cohort,analysis) %>%
  dplyr::top_n(1, rank) %>%
  dplyr::ungroup()

df$rank <- NULL

# Save plot data ---------------------------------------------------------------
print('Save plot data')

df <- df[!grepl("detailed",df$analysis),]
readr::write_csv(df, "output/plot_model_output.csv")

