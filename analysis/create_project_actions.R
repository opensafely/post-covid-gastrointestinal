library(yaml)
library(here)
library(glue)
library(readr)
library(dplyr)
library(tidyverse)

# Specify defaults -------------------------------------------------------------

defaults_list <- list(
  version = "3.0",
  expectations= list(population_size=200000L)
)

# Define active analyses -------------------------------------------------------

active_analyses <- read_rds("lib/active_analyses.rds") 
active_analyses <- active_analyses[order(active_analyses$analysis,active_analyses$cohort,active_analyses$outcome),]
# Define active analysis with failed models to run stata 

# active_analyses_failed <-data.frame()
 active_analyses_failed <-read_rds("lib/active_analyses_failed.rds")
#  remove failed models in stata too from stata_model_output needs list
models_to_remove <- c(
  'cohort_vax-sub_covid_hospitalised_ac_true-lower_gi_bleeding',
  'cohort_vax-sub_covid_hospitalised_ac_true-variceal_gi_bleeding',
  'cohort_unvax-sub_covid_hospitalised_ac_true-upper_gi_bleeding',
  'cohort_unvax-sub_covid_hospitalised_ac_true-lower_gi_bleeding',
  'cohort_unvax-sub_covid_hospitalised_te_true-variceal_gi_bleeding',
  'cohort_unvax-sub_covid_hospitalised_ac_true-variceal_gi_bleeding',
  'cohort_unvax-sub_covid_hospitalised_ac_true-nonvariceal_gi_bleeding',
  'cohort_unvax-sub_ethnicity_mixed-variceal_gi_bleeding',
  'cohort_unvax-sub_ethnicity_asian-variceal_gi_bleeding',
  'cohort_unvax-sub_ethnicity_other-variceal_gi_bleeding',
  'cohort_prevax-sub_covid_hospitalised_ac_true-variceal_gi_bleeding'
)
 active_analyses_stata<-active_analyses_failed[!active_analyses_failed$name %in% models_to_remove, ]


# Active analyses for gi bleeds -----------------------------------------------
active_analyses_gi_bleeds <- read_rds("lib/active_analyses_gi_bleeds.rds")

cohorts <- unique(active_analyses$cohort)


# Determine which outputs are successful and which fail --------------------------------------------
success_df <- read.csv("lib/actions_20240317.csv")
success_df <- success_df[success_df$success==TRUE,]


# Create generic action function -----------------------------------------------

action <- function(
    name,
    run,
    dummy_data_file=NULL,
    arguments=NULL,
    needs=NULL,
    highly_sensitive=NULL,
    moderately_sensitive=NULL
){
  
  outputs <- list(
    moderately_sensitive = moderately_sensitive,
    highly_sensitive = highly_sensitive
  )
  outputs[sapply(outputs, is.null)] <- NULL
  
  action <- list(
    run = paste(c(run, arguments), collapse=" "),
    dummy_data_file = dummy_data_file,
    needs = needs,
    outputs = outputs
  )
  action[sapply(action, is.null)] <- NULL
  
  action_list <- list(name = action)
  names(action_list) <- name
  
  action_list
}

# Create generic comment function ----------------------------------------------

comment <- function(...){
  list_comments <- list(...)
  comments <- map(list_comments, ~paste0("## ", ., " ##"))
  comments
}


# Create function to convert comment "actions" in a yaml string into proper comments

convert_comment_actions <-function(yaml.txt){
  yaml.txt %>%
    str_replace_all("\\\n(\\s*)\\'\\'\\:(\\s*)\\'", "\n\\1")  %>%
    #str_replace_all("\\\n(\\s*)\\'", "\n\\1") %>%
    str_replace_all("([^\\'])\\\n(\\s*)\\#\\#", "\\1\n\n\\2\\#\\#") %>%
    str_replace_all("\\#\\#\\'\\\n", "\n")
}

# Create function to generate study population ---------------------------------

generate_study_population <- function(cohort){
  splice(
    comment(glue("Generate study population - {cohort}")),
    action(
      name = glue("generate_study_population_{cohort}"),
      run = glue("cohortextractor:latest generate_cohort --study-definition study_definition_{cohort} --output-format csv.gz"),
      needs = list("vax_eligibility_inputs","generate_index_dates"),
      highly_sensitive = list(
        cohort = glue("output/input_{cohort}.csv.gz")
      )
    )
  )
}

generate_convert_rds_csv  <- function(cohort) {
  splice(
    comment("Generate hospitalised data from stage1 data"),
    action(
      name = glue("convert_rds_csv_{cohort}"),
      run = "r:latest analysis/convert_rds_csv.R",
      arguments = list(cohort),
      needs = list(glue("stage1_data_cleaning_{cohort}")),
      highly_sensitive = list(
        hosp_data = glue("output/input_{cohort}_stage1_sens.csv.gz")
      )
    )
  )
}
# Create a function to generate data for anti-coagulants and thrombotic events
generate_ac_te_data <- function(cohort){
  splice(
    comment(glue("Generate anti coagulants and thrombotic data - {cohort}")),
    action(
      name = glue("generate_ac_te_data_{cohort}"),
      run = glue("cohortextractor:latest generate_cohort --study-definition study_definition_{cohort}_sensitivity --output-format csv.gz"),
      needs = list(glue("convert_rds_csv_{cohort}")),
      highly_sensitive = list(
        cohort = glue("output/input_{cohort}_sensitivity.csv.gz")
      )
    )
  )
}

# Create function to preprocess data -------------------------------------------

preprocess_data <- function(cohort){
  splice(
    comment(glue("Preprocess data - {cohort}")),
    action(
      name = glue("preprocess_data_{cohort}"),
      run = glue("r:latest analysis/preprocess/preprocess_data.R"),
      arguments = c(cohort),
      needs = list("generate_index_dates",glue("generate_study_population_{cohort}")),
      moderately_sensitive = list(
        describe = glue("output/not-for-review/describe_input_{cohort}_stage0.txt"),
        describe_venn = glue("output/not-for-review/describe_venn_{cohort}.txt")
      ),
      highly_sensitive = list(
        cohort = glue("output/input_{cohort}.rds"),
        venn = glue("output/venn_{cohort}.rds")
      )
    )
  )
}
count_data <- function(cohort){
  #Count outcomes and binary covars
  splice(
    comment(glue ("Count outcome variables - {cohort}")),
    action(
      name = glue("count_study_def_variables_{cohort}"),
      run = "r:latest analysis/descriptives/initial_input_counts.R",
      arguments = c(cohort),
      needs = list(glue("generate_study_population_{cohort}"),glue("preprocess_data_{cohort}")),
      moderately_sensitive=list(
        counts_prepro = glue("output/not-for-review/study_counts_prepro_{cohort}.txt"),
        counts_sd = glue("output/not-for-review/study_counts_sd_{cohort}.txt"),
        summary_prepro = glue("output/not-for-review/describe_prepro_{cohort}.txt"),
        summary_sd = glue("output/not-for-review/describe_sd_{cohort}.txt")
        
        
      )
    )
  )
}

# Create function for data cleaning --------------------------------------------

stage1_data_cleaning <- function(cohort){
  splice(
    comment(glue("Stage 1 - data cleaning - {cohort}")),
    action(
      name = glue("stage1_data_cleaning_{cohort}"),
      run = glue("r:latest analysis/preprocess/Stage1_data_cleaning.R"),
      arguments = c(cohort),
      needs = list("vax_eligibility_inputs",glue("preprocess_data_{cohort}")),
      moderately_sensitive = list(
        consort = glue("output/consort_{cohort}.csv"),
        consort_rounded = glue("output/consort_{cohort}_rounded.csv")
      ),
      highly_sensitive = list(
        cohort = glue("output/input_{cohort}_stage1.rds")
      )
    )
  )
}

# Create function to make model input and run a model --------------------------

apply_model_function <- function(name, cohort, analysis, ipw, strata, 
                                 covariate_sex, covariate_age, covariate_other, 
                                 cox_start, cox_stop, study_start, study_stop,
                                 cut_points, controls_per_case,
                                 total_event_threshold, episode_event_threshold,
                                 covariate_threshold, age_spline){
  # Add the new sensitity analyses study definition to the dependencies when the analyses is in anticoagulants/thrombotic events
  needs_list <- list(glue("stage1_data_cleaning_{cohort}"))
  if (grepl("_ac_", analysis) || grepl("_te_", analysis)) {
    needs_list <- c(needs_list, glue("generate_ac_te_data_{cohort}"))
  }
  splice(
    action(
      name = glue("make_model_input-{name}"),
      run = glue("r:latest analysis/model/make_model_input.R {name}"),
      needs = needs_list,
      highly_sensitive = list(
        model_input = glue("output/model_input-{name}.rds")
      )
    ),
    
    action(
      name = glue("cox_ipw-{name}"),
      run = glue("cox-ipw:v0.0.30 --df_input=model_input-{name}.rds --ipw={ipw} --exposure=exp_date --outcome=out_date --strata={strata} --covariate_sex={covariate_sex} --covariate_age={covariate_age} --covariate_other={covariate_other} --cox_start={cox_start} --cox_stop={cox_stop} --study_start={study_start} --study_stop={study_stop} --cut_points={cut_points} --controls_per_case={controls_per_case} --total_event_threshold={total_event_threshold} --episode_event_threshold={episode_event_threshold} --covariate_threshold={covariate_threshold} --age_spline={age_spline} --df_output=model_output-{name}.csv"),
      needs = list(glue("make_model_input-{name}")),
      moderately_sensitive = list(
        model_output = glue("output/model_output-{name}.csv"))
    )
  )
}


# Save analyses ready for running stata and run stata --------------------------

apply_model_function_save_sample <- function(name, cohort, analysis, ipw, strata, 
                                             covariate_sex, covariate_age, covariate_other, 
                                             cox_start, cox_stop, study_start, study_stop,
                                             cut_points, controls_per_case,
                                             total_event_threshold, episode_event_threshold,
                                             covariate_threshold, age_spline){
  splice(
    
    action(
      name = glue("ready-{name}"),
      run = glue("cox-ipw:v0.0.30 --df_input=model_input-{name}.rds --ipw={ipw} --exposure=exp_date --outcome=out_date --strata={strata} --covariate_sex={covariate_sex} --covariate_age={covariate_age} --covariate_other={covariate_other} --cox_start={cox_start} --cox_stop={cox_stop} --study_start={study_start} --study_stop={study_stop} --cut_points={cut_points} --controls_per_case={controls_per_case} --total_event_threshold={total_event_threshold} --episode_event_threshold={episode_event_threshold} --covariate_threshold={covariate_threshold} --age_spline={age_spline} --save_analysis_ready=TRUE --run_analysis=FALSE --df_output=model_output-{name}.csv"),
      needs = list(glue("make_model_input-{name}")),
      highly_sensitive = list(
        analysis_ready = glue("output/ready-{name}.csv.gz"))
      ),
      action(
    name = glue("stata_cox_model_{name}"),
    run = glue("stata-mp:latest analysis/stata/cox_model.do ready-{name} TRUE TRUE"),
    needs = list(glue("ready-{name}")),
    moderately_sensitive = list(
      medianfup = glue("output/ready-{name}_median_fup.csv"),
      stata_output = glue("output/ready-{name}_cox_model.txt")
    )
  
    )
  )
  
}


# Create function to make model input and run a model for gi bleeds --------------------------

apply_model_function_gi_bleeds <- function(name, cohort, analysis, ipw, strata, 
                                           covariate_sex, covariate_age, covariate_other, 
                                           cox_start, cox_stop, study_start, study_stop,
                                           cut_points, controls_per_case,
                                           total_event_threshold, episode_event_threshold,
                                           covariate_threshold, age_spline){
  
  splice(
    action(
      name = glue("make_model_input-{name}_gi_bleeds"),
      run = glue("r:latest analysis/model/make_model_input_gi_bleeds.R {name}"),
      needs = list(glue("stage1_data_cleaning_gi_bleeds")),
      highly_sensitive = list(
        model_input = glue("output/model_input-{name}_gi_bleeds.rds")
      )
    ),
    action(
      name = glue("cox_ipw-{name}_gi_bleeds"),
      run = glue("cox-ipw:v0.0.30 --df_input=model_input-{name}_gi_bleeds.rds --ipw=FALSE --exposure=exp_date --outcome=out_date --strata={strata} --covariate_sex={covariate_sex} --covariate_age={covariate_age} --covariate_other={covariate_other} --cox_start={cox_start} --cox_stop={cox_stop} --study_start={study_start} --study_stop={study_stop} --cut_points={cut_points} --controls_per_case={controls_per_case} --total_event_threshold={total_event_threshold} --episode_event_threshold={episode_event_threshold} --covariate_threshold={covariate_threshold} --age_spline={age_spline} --df_output=model_output-{name}_gi_bleeds.csv"),
      needs = list(glue("make_model_input-{name}_gi_bleeds")),
      moderately_sensitive = list(
        model_output = glue("output/model_output-{name}_gi_bleeds.csv"))
    )
  )
}

# # Create function to run stata models-------------------------
# stata_actions <- function(name){
#   action(
#     name = glue("stata_cox_model_{name}"),
#     run = glue("stata-mp:latest analysis/stata/cox_model.do ready-{name} TRUE TRUE"),
#     needs = list(glue("ready-{name}")),
#     moderately_sensitive = list(
#       medianfup = glue("output/ready-{name}_median_fup.csv"),
#       stata_output = glue("output/ready-{name}_cox_model.txt")
#     )
#   )
  
# }
# Create function to make Table 1 ----------------------------------------------

table1 <- function(cohort){
  splice(
    comment(glue("Table 1 - {cohort}")),
    action(
      name = glue("table1_{cohort}"),
      run = "r:latest analysis/descriptives/table1.R",
      arguments = c(cohort),
      needs = list(glue("stage1_data_cleaning_{cohort}")),
      moderately_sensitive = list(
        table1 = glue("output/table1_{cohort}.csv"),
        table1_rounded = glue("output/table1_{cohort}_midpoint6.csv")
      )
    )
  )
}
# Create function to make Table 2 ----------------------------------------------


table2 <- function(cohort){
  
  table2_names <- gsub("out_date_","",unique(active_analyses[active_analyses$cohort=={cohort},]$name))
  table2_names <- table2_names[grepl("-main-|-sub_covid_nonhospitalised-|-sub_covid_hospitalised-",table2_names)]
  
  splice(
    comment(glue("Table 2 - {cohort}")),
    action(
      name = glue("table2_{cohort}"),
      run = "r:latest analysis/descriptives/table2.R",
      arguments = c(cohort),
      needs = c(as.list(paste0("make_model_input-",table2_names))),
      moderately_sensitive = list(
        table2 = glue("output/table2_{cohort}.csv"),
        table2_rounded = glue("output/table2_{cohort}_midpoint6.csv")
      )
    )
  )
}
# Create function to make Table 2 gi bleeds----------------------------------------------

table2_gi_bleeds <- function(cohort){
  
  table2_names <- gsub("out_date_","",unique(active_analyses_gi_bleeds[active_analyses_gi_bleeds$cohort=={cohort},]$name))
  
  splice(
    comment(glue("Table 2 gi bleeds {cohort}")),
    action(
      name = glue("table2_{cohort}_gi_bleeds"),
      run = "r:latest analysis/descriptives/table2_gi_bleeds.R",
      arguments = c(cohort),
      needs = c(as.list(paste0("make_model_input-",table2_names,"_gi_bleeds"))),
      moderately_sensitive = list(
        table2 = glue("output/table2_{cohort}_gi_bleeds.csv"),
        table2_rounded = glue("output/table2_{cohort}_gi_bleeds_rounded.csv")
      )
    )
  )
}
# Create function to make Venn data --------------------------------------------

venn <- function(cohort){
  
  venn_outcomes <- gsub("out_date_","",unique(active_analyses[active_analyses$cohort=={cohort},]$outcome))
  
  splice(
    comment(glue("Venn - {cohort}")),
    action(
      name = glue("venn_{cohort}"),
      run = "r:latest analysis/descriptives/venn.R",
      arguments = c(cohort),
      needs = c(as.list(glue("preprocess_data_{cohort}")),
                as.list(paste0(glue("make_model_input-cohort_{cohort}-main-"),venn_outcomes))),
      moderately_sensitive = list(
        venn = glue("output/venn_{cohort}.csv"),
        venn_rounded =  glue("output/venn_{cohort}_rounded.csv")
      )
    )
  )
}

# Define and combine all actions into a list of actions ------------------------

actions_list <- splice(
  
  ## Post YAML disclaimer ------------------------------------------------------
  
  comment("# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #",
          "DO NOT EDIT project.yaml DIRECTLY",
          "This file is created by create_project_actions.R",
          "Edit and run create_project_actions.R to update the project.yaml",
          "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
  ),
  
  ## Generate vaccination eligibility information ------------------------------
  comment("Generate vaccination eligibility information"),
  
  action(
    name = glue("vax_eligibility_inputs"),
    run = "r:latest analysis/metadates.R",
    highly_sensitive = list(
      study_dates_json = glue("output/study_dates.json"),
      vax_jcvi_groups= glue("output/vax_jcvi_groups.csv.gz"),
      vax_eligible_dates= ("output/vax_eligible_dates.csv.gz")
    )
  ),
  
  ## Generate prelim study_definition ------------------------------------------
  comment("Generate prelim study_definition"),
  
  action(
    name = "generate_study_population_prelim",
    run = "cohortextractor:latest generate_cohort --study-definition study_definition_prelim --output-format csv.gz",
    needs = list("vax_eligibility_inputs"),
    highly_sensitive = list(
      cohort = glue("output/input_prelim.csv.gz")
    )
  ),
  
  ## Generate dates for all study cohorts --------------------------------------
  comment("Generate dates for all study cohorts"), 
  
  action(
    name = "generate_index_dates",
    run = "r:latest analysis/prelim.R",
    needs = list("vax_eligibility_inputs","generate_study_population_prelim"),
    highly_sensitive = list(
      index_dates = glue("output/index_dates.csv.gz")
    )
  ),
  
  ## Generate study population -------------------------------------------------
  
  splice(
    unlist(lapply(cohorts, 
                  function(x) generate_study_population(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  
  ## Preprocess data -----------------------------------------------------------
  
  splice(
    unlist(lapply(cohorts, 
                  function(x) preprocess_data(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  splice(
    unlist(lapply(cohorts, 
                  function(x) count_data(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  ## Stage 1 - data cleaning -----------------------------------------------------------
  
  splice(
    unlist(lapply(cohorts, 
                  function(x) stage1_data_cleaning(cohort = x)), 
           recursive = FALSE
    )
  ),
  ## test deregistration date --------------------------------------
  comment("test type of deregistration date"), 
  
  action(
    name = "test_dereg_date",
    run = "r:latest analysis/preprocess/test_dereg_date.R",
    needs = list("stage1_data_cleaning_unvax"),
    moderately_sensitive = list(
      dates_log = glue("output/dereg_date_test.txt")
    )
  ),
  ##convert data from rds to csv for sensitivity analyses --------------------------------------------------------
  
  splice(
    unlist(lapply(cohorts, 
                  function(x) generate_convert_rds_csv(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  ##generate data for anticoagulants and thrombotic events data
  splice(
    unlist(lapply(cohorts, 
                  function(x) generate_ac_te_data(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  
  ## Table 1 -------------------------------------------------------------------
  
  splice(
    unlist(lapply(unique(active_analyses$cohort), 
                  function(x) table1(cohort = x)), 
           recursive = FALSE
    )
  ),
  ## Run models ----------------------------------------------------------------
  comment("Run models"),
  
  splice(
    unlist(lapply(1:nrow(active_analyses), 
                  function(x) apply_model_function(name = active_analyses$name[x],
                                                   cohort = active_analyses$cohort[x],
                                                   analysis = active_analyses$analysis[x],
                                                   ipw = active_analyses$ipw[x],
                                                   strata = active_analyses$strata[x],
                                                   covariate_sex = active_analyses$covariate_sex[x],
                                                   covariate_age = active_analyses$covariate_age[x],
                                                   covariate_other = active_analyses$covariate_other[x],
                                                   cox_start = active_analyses$cox_start[x],
                                                   cox_stop = active_analyses$cox_stop[x],
                                                   study_start = active_analyses$study_start[x],
                                                   study_stop = active_analyses$study_stop[x],
                                                   cut_points = active_analyses$cut_points[x],
                                                   controls_per_case = active_analyses$controls_per_case[x],
                                                   total_event_threshold = active_analyses$total_event_threshold[x],
                                                   episode_event_threshold = active_analyses$episode_event_threshold[x],
                                                   covariate_threshold = active_analyses$covariate_threshold[x],
                                                   age_spline = active_analyses$age_spline[x])), recursive = FALSE
    )
  ),
  
  # ## Stata re-run failed models to save sampled data 
  
  comment("Run failed models with stata"),
  
  splice(
    unlist(lapply(1:nrow(active_analyses_failed), 
                  function(x) apply_model_function_save_sample(name = active_analyses_failed$name[x],
                                                               cohort = active_analyses_failed$cohort[x],
                                                               analysis = active_analyses_failed$analysis[x],
                                                               ipw = active_analyses_failed$ipw[x],
                                                               strata = active_analyses_failed$strata[x],
                                                               covariate_sex = active_analyses_failed$covariate_sex[x],
                                                               covariate_age = active_analyses_failed$covariate_age[x],
                                                               covariate_other = active_analyses_failed$covariate_other[x],
                                                               cox_start = active_analyses_failed$cox_start[x],
                                                               cox_stop = active_analyses_failed$cox_stop[x],
                                                               study_start = active_analyses_failed$study_start[x],
                                                               study_stop = active_analyses_failed$study_stop[x],
                                                               cut_points = active_analyses_failed$cut_points[x],
                                                               controls_per_case = active_analyses_failed$controls_per_case[x],
                                                               total_event_threshold = active_analyses_failed$total_event_threshold[x],
                                                               episode_event_threshold = active_analyses_failed$episode_event_threshold[x],
                                                               covariate_threshold = active_analyses_failed$covariate_threshold[x],
                                                               age_spline = active_analyses_failed$age_spline[x])), recursive = FALSE
    )
  ),
  

  
  ## Table 2 -------------------------------------------------------------------
  
  splice(
    unlist(lapply(unique(active_analyses$cohort), 
                  function(x) table2(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  ## Make AER input--------------------------------------------------------------
  comment("Make absolute excess risk (AER) input"),
  
  action(
    name = "make_aer_input",
    run = "r:latest analysis/aer/make_aer_input.R",
    needs = as.list(paste0("make_model_input-",active_analyses[grepl("-main-",active_analyses$name),]$name)),
    moderately_sensitive = list(
      aer_input = glue("output/aer_input-main.csv"),
      aer_input_rounded = glue("output/aer_input-main-midpoint6.csv")
    )
  ),
  
  
  
  # Venn data -----------------------------------------------------------------
  
  splice(
    unlist(lapply(unique(active_analyses$cohort), 
                  function(x) venn(cohort = x)), 
           recursive = FALSE
    )
  ),
  
  comment("Stage 6 - make model output"),
  
  action(
    name = "make_model_output",
    run = "r:latest analysis/model/make_model_output.R",
    needs = as.list(paste0(success_df$model)),
    moderately_sensitive = list(
      model_output = glue("output/model_output.csv"),
      model_output_rounded = glue("output/model_output_midpoint6.csv")
    )
  ), 
  # comment ("Stata models"), 
  # # STATA ANALYSES
  
  # splice(
  #   unlist(lapply(1:nrow(active_analyses_failed), 
  #                 function(i) stata_actions(name = active_analyses_failed[i, "name"])),
  #          #  subgroup = analyses_to_run_stata[i, "analysis"],
  #          #  cohort = analyses_to_run_stata[i, "cohort"],
  #          #  time_periods = analyses_to_run_stata[i, "cut_points"],
           
  #          recursive = FALSE)
    
    
  # ),
  action(
    name = "make_stata_model_output",
    run = "r:latest analysis/stata/make_stata_model_output.R",
    needs = as.list(paste0("stata_cox_model_",active_analyses_stata$name)),
    moderately_sensitive = list(
      model_output = glue("output/stata_model_output.csv"),
      model_output_rounded = glue("output/stata_model_output_midpoint6.csv")
    )
  ), 
  comment("Calculate median (IQR) for age"),
  
  action(
    name = "median_iqr_age",
    run = "r:latest analysis/median_iqr_age.R",
    needs = list("stage1_data_cleaning_prevax",
                 "stage1_data_cleaning_vax",
                 "stage1_data_cleaning_unvax"),
    moderately_sensitive = list(
      model_output = glue("output/median_iqr_age.csv")
    )
  ),
  comment("--Get models which didn't converge on L4--"),
  action(
    name = "get_failed_models",
    run = "r:latest analysis/stata/failed_models_onserver.R",
    needs =  list("make_model_output"),
    moderately_sensitive= list(
      failed_models = "output/failed_models_onserver.csv",
      unique_models = "output/unique_failed_models.txt"
    )

  ),
  
  comment("------------------GI Bleeds Actions--------------------"),
  comment("Stage 1 GI bleeds"), 
  action(
    name = glue("stage1_data_cleaning_gi_bleeds"),
    run = glue("r:latest analysis/preprocess/Stage1_data_cleaning_gi_bleeds.R"),
    arguments = "vax",
    needs = list("vax_eligibility_inputs",glue("preprocess_data_vax")),
    moderately_sensitive = list(
      consort = glue("output/consort_vax_gi_bleeds.csv"),
      consort_rounded = glue("output/consort_vax_gi_bleeds_rounded.csv")
    ),
    highly_sensitive = list(
      cohort = glue("output/input_vax_stage1_gi_bleeds.rds")
    )
  ), 
  comment("Table 1 GI bleeds"), 
  action(
    name = glue("table1_gi_bleeds"),
    run = "r:latest analysis/descriptives/table1_gi_bleeds.R",
    arguments = "vax",
    needs = list(glue("stage1_data_cleaning_gi_bleeds")),
    moderately_sensitive = list(
      table1 = glue("output/table1_gi_bleeds_vax.csv"),
      table1_rounded = glue("output/table1_gi_bleeds_vax_rounded.csv")
    )
    
  ),
  ## Table 2 GI bleeds-------------------------------------------------------------------
  
  unlist(lapply(unique(active_analyses_gi_bleeds$cohort), 
                function(x) table2_gi_bleeds(cohort = x)), 
         recursive = FALSE
  ),
  
  ## Run models for gi bleeds ----------------------------------------------------------------
  comment("Run models for gi bleeds"),
  
  splice(
    unlist(lapply(1:nrow(active_analyses_gi_bleeds), 
                  function(x) apply_model_function_gi_bleeds(name = active_analyses_gi_bleeds$name[x],
                                                             cohort = active_analyses_gi_bleeds$cohort[x],
                                                             analysis = active_analyses_gi_bleeds$analysis[x],
                                                             ipw = FALSE,
                                                             strata = active_analyses_gi_bleeds$strata[x],
                                                             covariate_sex = active_analyses_gi_bleeds$covariate_sex[x],
                                                             covariate_age = active_analyses_gi_bleeds$covariate_age[x],
                                                             covariate_other = active_analyses_gi_bleeds$covariate_other[x],
                                                             cox_start = active_analyses_gi_bleeds$cox_start[x],
                                                             cox_stop = active_analyses_gi_bleeds$cox_stop[x],
                                                             study_start = active_analyses_gi_bleeds$study_start[x],
                                                             study_stop = active_analyses_gi_bleeds$study_stop[x],
                                                             cut_points = active_analyses_gi_bleeds$cut_points[x],
                                                             controls_per_case = active_analyses_gi_bleeds$controls_per_case[x],
                                                             total_event_threshold = active_analyses_gi_bleeds$total_event_threshold[x],
                                                             episode_event_threshold = active_analyses_gi_bleeds$episode_event_threshold[x],
                                                             covariate_threshold = active_analyses_gi_bleeds$covariate_threshold[x],
                                                             age_spline = active_analyses_gi_bleeds$age_spline[x])), recursive = FALSE
    )
  ),
  comment(" make model output gi bleeds"),
  
  action(
    name = "make_model_output_gi_bleeds",
    run = "r:latest analysis/model/make_model_output_gi_bleeds.R",
    needs = list("cox_ipw-cohort_vax-main-upper_gi_bleeding_gi_bleeds",glue("cox_ipw-cohort_vax-main-lower_gi_bleeding_gi_bleeds"),glue("cox_ipw-cohort_vax-main-nonvariceal_gi_bleeding_gi_bleeds")),
    
    moderately_sensitive = list(
      model_output = glue("output/model_output_gi_bleeds.csv")
    )
  )
)



## combine everything ----
project_list <- splice(
  defaults_list,
  list(actions = actions_list)
)

#####################################################################################
## convert list to yaml, reformat comments and white space, and output a .yaml file #
#####################################################################################
as.yaml(project_list, indent=2) %>%
  # convert comment actions to comments
  convert_comment_actions() %>%
  # add one blank line before level 1 and level 2 keys
  str_replace_all("\\\n(\\w)", "\n\n\\1") %>%
  str_replace_all("\\\n\\s\\s(\\w)", "\n\n  \\1") %>%
  writeLines("project.yaml")
print("YAML file printed!")

# Return number of actions -----------------------------------------------------

print(paste0("YAML created with ",length(actions_list)," actions."))
