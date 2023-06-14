# Sampling for running cox models in stata
# Code adapted from cox-ipw repo 

ipw_sample <- function(df, controls_per_case, seed = 137, sample_exposed) {
  
  # Set seed -------------------------------------------------------------------
  print("Set seed")
  
  set.seed(seed)
  
  # Split cases and controls ---------------------------------------------------
  print("Split cases and controls")
  
  cases <- df[df$outcome_status==TRUE,]
  controls <- df[df$outcome_status==FALSE,]
  
  print(paste0("Cases: ",nrow(cases)))
  print(summary(cases))
  
  print(paste0("Controls: ",nrow(controls)))
  print(summary(controls))
  
  # Sample controls if more than enough, otherwise retain all controls ---------
  
    
    if (sample_exposed==TRUE) {
      
      if (nrow(cases)*controls_per_case<nrow(controls)) {
        
          print("Sample controls, including exposed control individuals")
          controls <- controls[sample(seq_len(nrow(controls)), nrow(cases)*controls_per_case, replace = FALSE),]
          controls$cox_weight <- (nrow(df)-nrow(cases))/nrow(controls)
          print(paste0(nrow(controls), " controls sampled with Cox weight of ",controls$cox_weight[1]))
        
      } else {
        
        print("Retain all controls")
        controls$cox_weight <- 1
        
      }
     
    }
    
    if (sample_exposed==FALSE) {
      
      print("Separate exposed controls so they are not sampled")
      controls_exposed <- controls[!is.na(controls$exposure),]
      controls_exposed$cox_weight <- 1
      print(paste0(nrow(controls_exposed), " exposed controls"))
      
      print("Exposed controls:")
      print(summary(controls_exposed))
      
      print("Sample unexposed controls")
      controls_unexposed <- controls[is.na(controls$exposure),]
      
      if (nrow(cases)*controls_per_case<nrow(controls_unexposed)) {
      
        controls_unexposed <- controls_unexposed[sample(seq_len(nrow(controls_unexposed)), nrow(cases)*controls_per_case, replace = FALSE),]
        controls_unexposed$cox_weight <- (nrow(df)-nrow(cases)-nrow(controls_exposed))/nrow(controls_unexposed)
        print(paste0(nrow(controls_unexposed), " unexposed controls sampled with Cox weight of ",controls_unexposed$cox_weight[1]))
        
        print("Unexposed controls:")
        print(summary(controls_unexposed))
        
        print("Add exposed control individuals back to control dataset")
        controls <- NULL
        controls <- rbind(controls_unexposed,controls_exposed)
        print(paste0("Controls (N=",nrow(controls), "):"))
        print(summary(controls))
      
      } else {
        
        print("Insufficient controls so retain all controls")
        rm(controls_exposed, controls_unexposed)
        controls$cox_weight <- 1
        
      }
    
    } 
  
  # Specify cox weight for cases -----------------------------------------------
  print("Specify cox weight for cases")
  
  cases$cox_weight <- 1
  
  # Recombine cases and controls -----------------------------------------------
  print("Recombine cases and controls")
  
  return_df <- rbind(cases,controls)
  
  # Return dataset -------------------------------------------------------------
  
  return(return_df) 
  
}


# Load data --------------------------------------------------------------------
print("Load data")

if (grepl(".csv",opt$df_input)) {
  data <- readr::read_csv(paste0("output/", opt$df_input))
}

if (grepl(".rds",opt$df_input)) {
  data <- readr::read_rds(paste0("output/", opt$df_input))
}

print(summary(data))

# Make binary variables logical ------------------------------------------------
print("Make binary variables logical")

var_bin <- colnames(data)[grepl("_bin_",colnames(data))]
data[,var_bin] <- lapply(data[,var_bin],as.logical)

# Make date variables dates ----------------------------------------------------
print("Make date variables dates")

var_date <- colnames(data)[grepl("_date",colnames(data))]
data[,var_date] <- lapply(data[,var_date], function(x) as.Date(x,origin="1970-01-01"))

# Make categorical variables factors -------------------------------------------
print("Make categorical variables factors")

var_cat <- colnames(data)[grepl("_cat_",colnames(data))]
data[,var_cat] <- lapply(data[,var_cat],as.factor)

# Make numerical variables numerical -------------------------------------------
print(" Make numerical variables numerical")

var_num <- colnames(data)[grepl("_num_",colnames(data))]
data[,var_num] <- lapply(data[,var_num],as.numeric)

# Restrict to core variables ---------------------------------------------------
print("Restrict to core variables")

core <- colnames(data)
core <- core[!grepl("cov_", core)]
core <- core[!grepl("sub_", core)]

input <- data[, core]

print(paste0("Core variables: ", paste0(core, collapse = ", ")))

# Give generic names to variables ----------------------------------------------
print("Give generic names to variables")

input <- dplyr::rename(input,
                       "outcome" = tidyselect::all_of(opt$outcome),
                       "exposure" = tidyselect::all_of(opt$exposure))

cox_start <- gsub(opt$outcome, "outcome", cox_start)
cox_start <- gsub(opt$exposure, "exposure", cox_start)

cox_stop <- gsub(opt$outcome, "outcome", cox_stop)
cox_stop <- gsub(opt$exposure, "exposure", cox_stop)

print(summary(input))

# Specify study dates ----------------------------------------------------------
print("Specify study dates")

input$study_start <- as.Date(opt$study_start)
input$study_stop <- as.Date(opt$study_stop)

print(summary(input))

# Specify follow-up dates ------------------------------------------------------
print("Specify follow-up dates")

input$fup_start <- do.call(pmax,
                           c(input[, c("study_start", cox_start)], list(na.rm = TRUE)))

input$fup_stop <- do.call(pmin,
                          c(input[, c("study_stop", cox_stop)], list(na.rm = TRUE)))

input <- input[input$fup_stop >= input$fup_start, ]

print(summary(input))

# Remove exposures and outcomes outside follow-up ------------------------------
print("Remove exposures and outcomes outside follow-up")

print(paste0("Exposure data range: ", min(input$exposure, na.rm = TRUE), " to ", max(input$exposure, na.rm = TRUE)))
print(paste0("Outcome data range: ", min(input$outcome, na.rm = TRUE), " to ", max(input$outcome, na.rm = TRUE)))

input <- input %>% 
  dplyr::mutate(exposure = replace(exposure, which(exposure>fup_stop | exposure<fup_start), NA),
                outcome = replace(outcome, which(outcome>fup_stop | outcome<fup_start), NA))

print(paste0("Exposure data range: ", min(input$exposure, na.rm = TRUE), " to ", max(input$exposure, na.rm = TRUE)))
print(paste0("Outcome data range: ", min(input$outcome, na.rm = TRUE), " to ", max(input$outcome, na.rm = TRUE)))

# Make indicator variable for outcome status -----------------------------------
print("Make indicator variable for outcome status")

input$outcome_status <- input$outcome==input$fup_stop & !is.na(input$outcome) & !is.na(input$fup_stop)

print(table(input$outcome_status))

# Sample control population ----------------------------------------------------

N_total <- nrow(input)
print(paste0("N_total = ",N_total))

N_exposed <- nrow(input[!is.na(input$exposure),])
print(paste0("N_exposed = ",N_exposed))

if (opt$ipw == TRUE) {
  print("Sample control population")
  input <- ipw_sample(df = input,
                      controls_per_case = controls_per_case, 
                      seed = opt$seed,
                      sample_exposed = opt$sample_exposed)
  print(paste0("After sampling, N_total = ",nrow(input)))
}

print(summary(input))