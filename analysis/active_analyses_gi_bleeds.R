
    library(jsonlite)

    # Create output directory ------------------------------------------------------
    fs::dir_create(here::here("lib"))

    # Create empty data frame ------------------------------------------------------

    df <- data.frame(cohort = character(),
                    exposure = character(), 
                    outcome = character(), 
                    ipw = logical(), 
                    strata = character(),
                    covariate_sex = character(),
                    covariate_age = character(),
                    covariate_other = character(),
                    cox_start = character(),
                    cox_stop = character(),
                    study_start = character(),
                    study_stop = character(),
                    cut_points = character(),
                    controls_per_case = numeric(),
                    total_event_threshold = numeric(),
                    episode_event_threshold = numeric(),
                    covariate_threshold = numeric(),
                    age_spline = logical(),
                    analysis = character(),
                    priorhistory_var = character(),
                    stringsAsFactors = FALSE)

    # Set constant values ----------------------------------------------------------

    ipw <- TRUE
    age_spline <- TRUE
    exposure <- "exp_date_covid19_confirmed"
    strata <- "cov_cat_region"
    covariate_sex <- "cov_cat_sex"
    covariate_age <- "cov_num_age"
    cox_start <- "index_date"
    cox_stop <- "end_date_outcome"
    controls_per_case <- 20L
    total_event_threshold <- 50L
    episode_event_threshold <- 5L
    covariate_threshold <- 5L
    ##Dates
    study_dates <- fromJSON("output/study_dates.json")
    vax_start<-"2021-06-01"
    vax_stop <-"2021-12-14"
    ##Cut points 
    vax_cuts <- "28;197"
    # all_covars <- paste0("cov_cat_ethnicity;cov_cat_deprivation;cov_cat_smoking_status;cov_bin_carehome_status;",
    #                      "cov_num_consulation_rate;cov_bin_healthcare_worker;cov_bin_gi_operations;cov_bin_overall_gi_and_symptoms;cov_bin_obesity;",
    #                      "cov_bin_nonvariceal_gi_bleeding;cov_bin_variceal_gi_bleedingl;cov_bin_lower_gi_bleeding;cov_bin_upper_gi_bleeding;",
    #                      "cov_bin_peptic_ulcer;cov_bin_dyspepsia;cov_bin_gastro_oesophageal_reflux_disease;cov_bin_acute_pancreatitis;",
    #                      "cov_bin_nonalcoholic_steatohepatitis;cov_bin_gallstones_disease;cov_bin_appendicitis;cov_bin_all_gi_symptoms;",
    #                      "cov_bin_antidepressants_bnf;cov_bin_alcohol_above_limits;cov_bin_cholelisthiasis;cov_bin_h_pylori_infection;cov_bin_nsaid_bnf;",
    #                      "cov_bin_aspirin_bnf;")
    all_covars <- paste0("cov_cat_ethnicity;cov_cat_deprivation;cov_cat_smoking_status;cov_bin_carehome_status;",
                        "cov_num_consulation_rate;cov_bin_healthcare_worker;cov_bin_gi_operations;cov_bin_overall_gi_and_symptoms;cov_bin_obesity;",
                        "cov_bin_antidepressants_bnf;cov_bin_alcohol_above_limits;cov_bin_cholelisthiasis;cov_bin_h_pylori_infection;cov_bin_nsaid_bnf;",
                        "cov_bin_aspirin_bnf")

    #Specific covars below are only confounders for the specific outcomes below
    specific_covars <- "cov_bin_hypertriglyceridemia;cov_bin_hypercalcemia;cov_num_systolic_bp"
    specific_outcomes <- c("out_date_bowel_ischaemia","out_date_nonalcoholic_steatohepatitis","out_date_acute_pancreatitis")



    # Specify cohorts --------------------------------------------------------------

    cohorts <- c("vax")

    # Specify outcomes -------------------------------------------------------------
      outcomes_runall <- c("out_date_upper_gi_bleeding",
                          "out_date_lower_gi_bleeding",
                          "out_date_variceal_gi_bleeding",
                          "out_date_nonvariceal_gi_bleeding")
    # outcomes_runmain <- c("out_date_upper_gi_bleeding",
                          # "out_date_lower_gi_bleeding",
                          # "out_date_variceal_gi_bleeding",
                          # "out_date_nonvariceal_gi_bleeding"
    # )


    # Add active analyses ----------------------------------------------------------

    for (c in cohorts) {
      
      # for (i in c(outcomes_runmain, outcomes_runall)) {
        for (i in c( outcomes_runall)) {
        
        
        ## analysis: main ----------------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = ifelse(i %in% specific_outcomes, paste0(all_covars,';',specific_covars),all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = vax_start,
                            study_stop =  vax_stop,
                            cut_points =  vax_cuts,
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "main",
                            priorhistory_var = ""
                            )
          
        }
        
      }
      
      
    # Assign unique name -----------------------------------------------------------

    df$name <- paste0("cohort_",df$cohort, "-", 
                      df$analysis, "-", 
                      gsub("out_date_","",df$outcome), 
                      ifelse(df$priorhistory_var=="","", paste0("-",df$priorhistory_var)))

    # Check names are unique and save active analyses list -------------------------

    if (length(unique(df$name)) == nrow(df)) {
      saveRDS(df, file = "lib/active_analyses_gi_bleeds.rds", compress = "gzip")
    } else {
      stop(paste0("ERROR: names must be unique in active analyses table"))
    }



