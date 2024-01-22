library(magrittr)
library(data.table)
library(dplyr)
library(readr)


#  Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  name <- "all" # prepare datasets for all active analyses 
   name <- "cohort_prevax-sub_covid_hospitalised-nonvariceal_gi_bleeding_anticoag_True_sensitivity" # prepare datasets for all active analyses whose name contains X
} else {
  name <- args[[1]]
}

active_analyses<-read_rds("lib/active_analyses_sensitivity.rds")
# Identify model inputs to be prepared -----------------------------------------
print('Identify model inputs to be prepared')

if (name=="all") {
  prepare <- active_analyses$name
} else if(grepl(";",name)) {
  prepare <- stringr::str_split(as.vector(name), ";")[[1]]
} else {
  prepare <- active_analyses[grepl(name,active_analyses$name),]$name
}
active_analyses <- active_analyses[active_analyses$name %in% prepare,]

# for the suffixes we know that they are for sensitivity analyses create model input files 
# take model input file for hospitalised analyses and calculate fup total 
# Join with sd_input which is the data from study definition sensitivity with the added variables (anticaog/discharge/thrombotic events...)

name_suffixes <- c("_throm_True_sensitivity", "_throm_False_sensitivity", "_anticoag_True_sensitivity", "_anticoag_False_sensitivity")
for (i in 1:nrow(active_analyses)) {
    cohort <- active_analyses$cohort[i]
    name_sensitivity <- active_analyses[i, "name"]
    name <- gsub(paste(name_suffixes, collapse = "|"), "", name_sensitivity)

    # hospitalised model input 
    input <- readRDS(paste0("output/model_input-", name, ".rds"))
    input<- input%>% 
    mutate(patient_id=as.character(patient_id))

    # Study definition sensitivity input 
    sd_input <- read.csv(paste0("output/input_", cohort, "_sensitivity.csv.gz"),colClasses = c(patient_id = "character"))
    sd_input$discharge_date<- as.Date(sd_input$discharge_date)

    # Thrombotic events model input 
    if (grepl("throm", active_analyses$analysis[i])){

    sd_input <- sd_input %>% 
    dplyr::select(patient_id,
                sub_bin_ate_vte_sensitivity,
    )
    input_hosp_throm <- input %>%
        left_join(sd_input, by = "patient_id") 
    
    # Thrombotic events TRUE
    if (active_analyses$analysis[i]=="throm_True_sensitivity"){
    seninput_hosp_throm_True <- input_hosp_throm%>%
        filter(sub_bin_ate_vte_sensitivity == TRUE)

    write_rds(seninput_hosp_throm_True, paste0("output/model_input-", name_sensitivity,".rds"))
    }else{
      # Thrombotic events FALSE
    input_hosp_4mo_throm_False <- input_hosp_throm %>%
        filter(sub_bin_ate_vte_sensitivity == FALSE)
        
    write_rds(input_hosp_4mo_throm_False, paste0("output/model_input-",name_sensitivity,".rds"))
    }
    }
    
    if (grepl("anticoag", active_analyses$analysis[i])){
    # input <- input %>% filter(fup_total >= 120)

 # Add indicator for 4 months (4*28=112) follow-up post-discharge --------------
 
    # join study def data with hospitalised model_input 
    sd_input<- sd_input %>%dplyr::select(
        patient_id,
        sub_bin_anticoagulants_sensitivity_bnf,
        discharge_date
    )
        seninput_hosp_anticoag <- input %>% 
        left_join(sd_input, by = "patient_id")
        
        print('Add indicator for 4 months (4*28=112) follow-up post-discharge')
        seninput_hosp_anticoag$sub_bin_fup4m <- ((seninput_hosp_anticoag$end_date_outcome - seninput_hosp_anticoag$discharge_date) > 112) | is.na(seninput_hosp_anticoag$exp_date)
        seninput_hosp_anticoag<- seninput_hosp_anticoag[seninput_hosp_anticoag$sub_bin_fup4m==TRUE,]
        

        # anticoagulation true model input 
    if (active_analyses$analysis[i]=="anticoag_True_sensitivity"){
    input_hosp_4mo_anticoag_True <- seninput_hosp_anticoag %>%
        filter(sub_bin_anticoagulants_sensitivity_bnf == TRUE)
    
    write_rds(input_hosp_4mo_anticoag_True, paste0("output/model_input-", name_sensitivity, ".rds"))
    # anticoagulation false input 
    }else{
    input_hosp_4mo_anticoag_False <- seninput_hosp_anticoag %>%
        filter(sub_bin_anticoagulants_sensitivity_bnf == FALSE)
    
    write_rds(input_hosp_4mo_anticoag_False, paste0("output/model_input-", name_sensitivity, ".rds"))
}
    }

}

