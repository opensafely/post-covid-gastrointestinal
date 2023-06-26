library(data.table)
library(dplyr)

args <- commandArgs(trailingOnly=TRUE)
print(length(args))
if(length(args)==0){
  # use for interactive testing
  cohort_name <- "prevax"
} else {
  cohort_name <- args[[1]]
}

#count non na outcome and covars events 
count_input <- function(df) {
  out_df <- df %>% 
    select(matches("^(out_date)"))
  counts <- sapply(out_df, function(x) {
    x <- ifelse(is.na(x), "", as.character(x))
    sum(x != "", na.rm = TRUE)
  })
    count_df <- data.frame(outcome = names(counts), count = counts, row.names = NULL)

  
}


#summary data 
describe_data <- function(data,file_name) {
  
  sink(file_name)
  print(Hmisc::describe(data))
  sink()
  message(paste0("Description of ", deparse(substitute(data)), " written to ", file_name, " successfully!"))
}

# Read datasets before preprocessing
# dataset_names <- c("prevax", "vax", "unvax")
dataset_names<-c(cohort_name)
df_list_sd <-  read.csv(paste0("output/input_", cohort_name, ".csv.gz"))
message(paste0("Before preprocessing:\n",str(df_list_sd)) )
# After preprocessing data
df_prepro_list <- readRDS(paste0("output/input_", cohort_name, ".rds"))
message(paste0("After preprocessing:\n",str(df_prepro_list)))


# Count non-NA outcome and covars events for preprocessed data
count_list <- count_input(df_prepro_list)
# count_df <- t(count_list)
counts_prepro_file<- paste0("output/not-for-review/study_counts_prepro_",cohort_name,".txt")
write.table(count_list, quote = FALSE, row.names = FALSE, col.names = TRUE, file = counts_prepro_file)
rm(count_list)
gc()

# Count non-NA outcome and covars events for raw data
count_list_sd <- count_input(df_list_sd)
write.table(count_list_sd, quote = FALSE, row.names = FALSE, col.names = TRUE, file=paste0("output/not-for-review/study_counts_sd_",cohort_name,".txt"))
rm(count_list_sd)
gc()
# # Summary data
for (i in seq_along(dataset_names)) {
  file_name_prepro <- paste0("output/not-for-review/describe_prepro_", dataset_names[i], ".txt")
  describe_data(df_prepro_list[[i]], file_name_prepro)
  rm (df_prepro_list[[i]])
  gc()
  file_name_sd <- paste0("output/not-for-review/describe_sd_", dataset_names[i], ".txt")
  describe_data(df_list_sd[[i]], file_name_sd)
}

rm (df_prepro_list)
gc()




