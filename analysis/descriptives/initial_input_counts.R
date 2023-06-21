library(data.table)
library(dplyr)

#count non na outcome and covars events 
count_input <- function(df) {
  out_df <- df %>% 
    select(matches("^(out_date)"))
  sapply(out_df, function(x) {
    x <- ifelse(is.na(x), "", as.character(x))
    sum(x != "", na.rm = TRUE)
  })
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
dataset_names<-c("prevax")
df_list_sd <- lapply(dataset_names, function(name) read.csv(paste0("output/input_", name, ".csv.gz")))

# After preprocessing data
df_prepro_list <- lapply(dataset_names, function(name) readRDS(paste0("output/input_", name, ".rds")))

# Count non-NA outcome and covars events for preprocessed data
count_list <- lapply(df_prepro_list, count_input)
count_df <- t(data.frame(do.call(rbind, count_list)))
colnames(count_df) <- dataset_names
write.table(count_df, quote = FALSE, row.names = TRUE, col.names = TRUE, "output/not-for-review/study_counts_prepro.txt")
rm(count_df)
gc()
# Count non-NA outcome and covars events for raw data
count_list_sd <- lapply(df_list_sd, count_input)
count_df_sd <- t(data.frame(do.call(rbind, count_list_sd)))
colnames(count_df_sd) <- dataset_names
write.table(count_df_sd, quote = FALSE, row.names = TRUE, col.names = TRUE, "output/not-for-review/study_counts_sd.txt")
rm(count_df_sd)
gc()
# # Summary data
for (i in seq_along(dataset_names)) {
  file_name_prepro <- paste0("output/not-for-review/describe_prepro_", dataset_names[i], ".txt")
  describe_data(df_prepro_list[[i]], file_name_prepro)
  
  file_name_sd <- paste0("output/not-for-review/describe_sd_", dataset_names[i], ".txt")
  describe_data(df_list_sd[[i]], file_name_sd)
}

rm (df_prepro_list)
gc()




