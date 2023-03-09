library(data.table)
library(dplyr)

#read datasets 
prevax<-fread("output/input_prevax.csv.gz")
vax<-fread("output/input_vax.csv.gz")
unvax<-fread("output/input_unvax.csv.gz")

#count non na outcome and covars events 
count_input<-function(df){
    out_cov_df<-df%>% 
    select(matches("^(out_date|cov_bin)"))
      sapply(out_cov_df, function(x) sum(!is.na(x) ))

}

# create a list of data frames
df_list <- list(prevax, vax, unvax)
count_list <- lapply(df_list, count_input)

count_df <- t(data.frame(do.call(rbind, count_list)))

colnames(count_df) <- c("prevax", "vax", "unvax")
write.table(count_df,quote=F,row.names=T,col.names=T,"output/study_counts.txt")
