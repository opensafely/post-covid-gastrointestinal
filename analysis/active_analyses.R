
    library(jsonlite)
    library(dplyr)

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
    total_event_threshold <- 20L
    episode_event_threshold <- 5L
    covariate_threshold <- 5L
    ##Dates
    study_dates <- fromJSON("output/study_dates.json")

    prevax_start <- "2020-01-01"
    prevax_stop<- "2021-12-14"
    vax_unvax_start<-"2021-06-01"
    vax_unvax_stop <-"2021-12-14"
    ##Cut points 
    prevax_cuts <- "1;28;197;365;714"
    vax_unvax_cuts <- "1;28;197"
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
                        "cov_bin_aspirin_bnf;cov_bin_anticoagulants_bnf")

    #Specific covars below are only confounders for the specific outcomes below
    specific_covars <- "cov_bin_hypertriglyceridemia;cov_bin_hypercalcemia;cov_num_systolic_bp"
    specific_outcomes <- c("out_date_bowel_ischaemia","out_date_nonalcoholic_steatohepatitis","out_date_acute_pancreatitis")



    # Specify cohorts --------------------------------------------------------------

    cohorts <- c("vax","unvax","prevax")

    # Specify outcomes -------------------------------------------------------------

    
    outcomes_runall <- c("out_date_ibs",
                          "out_date_appendicitis",
                          "out_date_gallstones_disease",
                          "out_date_nonalcoholic_steatohepatitis",
                          "out_date_acute_pancreatitis",
                          "out_date_gastro_oesophageal_reflux_disease",
                          "out_date_dyspepsia",
                          "out_date_peptic_ulcer",
                          "out_date_upper_gi_bleeding",
                          "out_date_lower_gi_bleeding",
                          "out_date_variceal_gi_bleeding",
                          "out_date_nonvariceal_gi_bleeding")
    

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
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "main",
                            priorhistory_var = "")

        ## analysis: sub_covid_hospitalised ----------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_covid_hospitalised",
                            priorhistory_var = "")
        
        # analyses: sub_covid_hospitalised, sub_covid_hospitalised_te_true/_false
        # sub_covid_hospitalised_ac_true/_false -----------------------------------
        if (endsWith(i,"_gi_bleeding")){

        # analyses: sub_covid_hospitalised thrombotic events true
         df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_covid_hospitalised_te_true",
                            priorhistory_var = "")

          # analyses: sub_covid_hospitalised thrombotic events false
         df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_covid_hospitalised_te_false",
                            priorhistory_var = "")

 # analyses: sub_covid_hospitalised anticoagulants true
         df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub(";cov_bin_anticoagulants_bnf", "", all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_covid_hospitalised_ac_true",
                            priorhistory_var = "")

    # analyses: sub_covid_hospitalised anticoagulants events false    
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub(";cov_bin_anticoagulants_bnf", "", all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_covid_hospitalised_ac_false",
                            priorhistory_var = "")
                            
        }
        
        ## analysis: sub_covid_nonhospitalised -------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_covid_nonhospitalised",
                            priorhistory_var = "")
        
        ## analysis: sub_covid_history ---------------------------------------------
        
        if (c!="prevax") {
          
          df[nrow(df)+1,] <- c(cohort = c,
                              exposure = exposure, 
                              outcome = i,
                              ipw = ipw, 
                              strata = strata,
                              covariate_sex = covariate_sex,
                              covariate_age = covariate_age,
                              covariate_other = all_covars,
                              cox_start = cox_start,
                              cox_stop = cox_stop,
                              study_start =  vax_unvax_start,
                              study_stop =  vax_unvax_stop,
                              cut_points = vax_unvax_cuts,
                              controls_per_case = controls_per_case,
                              total_event_threshold = total_event_threshold,
                              episode_event_threshold = episode_event_threshold,
                              covariate_threshold = covariate_threshold,
                              age_spline = TRUE,
                              analysis = "sub_covid_history",
                              priorhistory_var = "")
          
        }
        
      }
      
      for (i in outcomes_runall) {
        
        ## analysis: sub_sex_female ------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = "NULL",
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_sex_female",
                            priorhistory_var = "")
        
        ## analysis: sub_sex_male --------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = "NULL",
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_sex_male",
                            priorhistory_var = "")
        
        ## analysis: sub_age_18_39 ------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = FALSE,
                            analysis = "sub_age_18_39",
                            priorhistory_var = "")
        
        ## analysis: sub_age_40_59 ------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = FALSE,
                            analysis = "sub_age_40_59",
                            priorhistory_var = "")
        
        ## analysis: sub_age_60_79 ------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = FALSE,
                            analysis = "sub_age_60_79",
                            priorhistory_var = "")
        
        ## analysis: sub_age_80_110 ------------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = all_covars,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = FALSE,
                            analysis = "sub_age_80_110",
                            priorhistory_var = "")
        
        ## analysis: sub_ethnicity_white -------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other =gsub("cov_cat_ethnicity;","",all_covars), #-ethnicity,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_ethnicity_white",
                            priorhistory_var = "")
        
        ## analysis: sub_ethnicity_black -------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_cat_ethnicity;","",all_covars),# -ethnicity,
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_ethnicity_black",
                            priorhistory_var = "")
        
        ## analysis: sub_ethnicity_mixed -------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_cat_ethnicity;","",all_covars),#-ethnicity
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_ethnicity_mixed",
                            priorhistory_var = "")
        
        ## analysis: sub_ethnicity_asian -------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_cat_ethnicity;","",all_covars),#-ethnicity
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_ethnicity_asian",
                            priorhistory_var = "")
        
        ## analysis: sub_ethnicity_other -------------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_cat_ethnicity;","",all_covars),#-ethnicity
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_ethnicity_other",
                            priorhistory_var = "")
        
        ## analysis: sub_priorhistory_true -----------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            #covariate_other = gsub(";;",";",gsub(gsub("out_date","cov_bin_history",i),"","cov_cat_ethnicity;cov_cat_deprivation;cov_cat_smoking_status;cov_bin_carehome_status;cov_num_consulation_rate;cov_bin_healthcare_worker;cov_bin_dementia;cov_bin_liver_disease;cov_bin_chronic_kidney_disease;cov_bin_cancer;cov_bin_hypertension;cov_bin_diabetes;cov_bin_obesity;cov_bin_chronic_obstructive_pulmonary_disease;cov_bin_ami;cov_bin_stroke_isch;cov_bin_recent_depression;cov_bin_history_depression;cov_bin_recent_anxiety;cov_bin_history_anxiety;cov_bin_recent_eating_disorders;cov_bin_history_eating_disorders;cov_bin_recent_serious_mental_illness;cov_bin_history_serious_mental_illness;cov_bin_recent_self_harm;cov_bin_history_self_harm")),
                            covariate_other = gsub("cov_bin_overall_gi_and_symptoms;","",all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_priorhistory_true",
                            priorhistory_var = "cov_bin_overall_gi_and_symptoms")
        
        
        ## analysis: sub_priorhistory_false ----------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_bin_overall_gi_and_symptoms;","",all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_priorhistory_false",
                            priorhistory_var = "cov_bin_overall_gi_and_symptoms")
        
        ## analysis: sub_prioroperations_true -----------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_bin_gi_operations;","",all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_prioroperations_true",
                            priorhistory_var = "cov_bin_gi_operations")
        
        
        ## analysis: sub_prioroperations_false ----------------------------------------
        
        df[nrow(df)+1,] <- c(cohort = c,
                            exposure = exposure, 
                            outcome = i,
                            ipw = ipw, 
                            strata = strata,
                            covariate_sex = covariate_sex,
                            covariate_age = covariate_age,
                            covariate_other = gsub("cov_bin_gi_operations;","",all_covars),
                            cox_start = cox_start,
                            cox_stop = cox_stop,
                            study_start = ifelse(c=="prevax", prevax_start, vax_unvax_start),
                            study_stop = ifelse(c=="prevax", prevax_stop, vax_unvax_stop),
                            cut_points = ifelse(c=="prevax", prevax_cuts, vax_unvax_cuts),
                            controls_per_case = controls_per_case,
                            total_event_threshold = total_event_threshold,
                            episode_event_threshold = episode_event_threshold,
                            covariate_threshold = covariate_threshold,
                            age_spline = TRUE,
                            analysis = "sub_prioroperations_false",
                            priorhistory_var = "cov_bin_gi_operations")
        
      }
      
    }
  

    ## Add day0 analysis rows: 
    # # Filter to analysis that we need day0 for 
    #   day0_rows <- df%>% 
    #         filter(analysis %in% c("main", "sub_covid_hospitalised", "sub_covid_nonhospitalised") | grepl("^sub_age", analysis))

#  Update analysis and cut_points 
# day0_rows <- df %>% 
#   mutate(
#      analysis = paste0(analysis, "_day0"),
#     cut_points = ifelse(
#       cohort == "prevax",
#       gsub("28", "1;28", prevax_cuts),
#       gsub("28", "1;28", vax_unvax_cuts)
#     )
#   )
# df <- bind_rows(df, day0_rows)
# df<-day0_rows
    # Assign unique name -----------------------------------------------------------

    df$name <- paste0("cohort_",df$cohort, "-", 
                      df$analysis, "-", 
                      gsub("out_date_","",df$outcome))
                      # ifelse(df$priorhistory_var=="","", paste0("-",df$priorhistory_var)))

    # Check names are unique and save active analyses list -------------------------

    if (length(unique(df$name))==nrow(df)) {
      saveRDS(df, file = "lib/active_analyses.rds", compress = "gzip")
    } else {
      stop(paste0("ERROR: names must be unique in active analyses table"))
    }



