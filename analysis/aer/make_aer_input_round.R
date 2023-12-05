# This can be done in the main make_aer_input.R file 
# The roundding alone failed, it is done here to avoid rerunning the whole process

# Load libraries ---------------------------------------------------------------
print('Load libraries')

library(readr)
library(dplyr)
library(magrittr)

# Specify redaction threshold --------------------------------------------------
print('Specify redaction threshold')

threshold <- 6

# Source common functions ------------------------------------------------------
print('Source common functions')

source("analysis/utility.R")

# Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  analysis <- "main"
} else {
  analysis <- args[[1]]
}
# Read AER input ---------------------------------------------------------------
print('Read AER input')

input <-read.csv( paste0("output/aer_input-",analysis,".csv"))

# Perform redaction ------------------------------------------------------------
print('Perform redaction')
rounded_cols <- setdiff(colnames(input),c("aer_sex","aer_age","analysis","cohort","outcome"))

# Renaming the columns by adding '_midpoint6'-----------------------------------
input[rounded_cols] <- lapply(
  input[rounded_cols],
  FUN = function(y) { roundmid_any(as.numeric(y), to = threshold) }
)

new_names<-paste0(rounded_cols, "_midpoint6")
names(input)[match(rounded_cols, names(input))] <- new_names


# Save rounded AER input -------------------------------------------------------
print('Save rounded AER input')

write.csv(input, paste0("output/aer_input-",analysis,"-midpoint6.csv"), row.names = FALSE)