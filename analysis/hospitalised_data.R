
# Transform stage 1 rds files to csv.gz 
# Keep only patients which are hospitalised 

library(readr)
library(dplyr)



# Specify command arguments ----------------------------------------------------
print('Specify command arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  cohort <- "prevax"
} else {
  cohort <- args[[1]]
}

s1_input<- read_rds(paste0("output/input_",cohort,"_stage1.rds"))
write_csv(s1_input,paste0("output/input_",cohort,"_stage1.csv.gz"))


# Keep only patients hospitalised 
s1_input <- s1_input %>% 
                        filter(sub_cat_covid19_hospital=="hospitalised")

write_csv(s1_input,paste0("output/input_",cohort,"_stage1_hosp.csv.gz"))
