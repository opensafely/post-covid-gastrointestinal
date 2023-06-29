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
dataset_name<-cohort_name
df_list_sd <-  read.csv(paste0("output/input_", cohort_name, ".csv.gz"))
message(paste0("Before preprocessing:\n",str(df_list_sd %>% select(matches("^(out_date)")))) )
# After preprocessing data
df_list_prepro <- readRDS(paste0("output/input_", cohort_name, ".rds"))
message(paste0("After preprocessing:\n",str(df_list_prepro%>% select(matches("^(out_date)")))) )


# Count non-NA outcome  events for preprocessed data
count_list <- count_input(df_list_prepro)
# count_df <- t(count_list)
counts_prepro_file<- paste0("output/not-for-review/study_counts_prepro_",cohort_name,".txt")
write.table(count_list, quote = FALSE, row.names = FALSE, col.names = TRUE, file = counts_prepro_file)
message("Preprocess variceal bleeds ")
message(head(df_list_prepro$out_date_variceal_gi_bleeding,60))
message(str(df_list_prepro$out_date_variceal_gi_bleeding))
message("IBS")
message(str(df_list_prepro$out_date_ibs))

rm(df_list_prepro)
gc()

# # Count non-NA outcome and covars events for raw data
count_list_sd <- count_input(df_list_sd)
write.table(count_list_sd, quote = FALSE, row.names = FALSE, col.names = TRUE, file=paste0("output/not-for-review/study_counts_sd_",cohort_name,".txt"))
message("SD variceal bleeds ")

message(head(df_list_sd$out_date_variceal_gi_bleeding,60))
message(str(df_list_sd$out_date_variceal_gi_bleeding))
message("IBS")
message(str(df_list_sd$out_date_ibs))


rm(df_list_sd)
gc()
# # # Summary data
#   file_name_prepro <- paste0("output/not-for-review/describe_prepro_", dataset_name, ".txt")
#   describe_data(df_list_prepro, file_name_prepro)
#   file_name_sd <- paste0("output/not-for-review/describe_sd_", dataset_name, ".txt")
#   describe_data(df_list_sd, file_name_sd)

# rm (df_list_prepro)
# gc()






