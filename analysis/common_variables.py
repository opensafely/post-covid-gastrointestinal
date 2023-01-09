# Based on common_variables in https://github.com/opensafely/post-covid-vaccinated/blob/main/analysis/common_variables.py

# Import statements

## Cohort extractor
from cohortextractor import (
    patients,
    codelist,
    filter_codes_by_category,
    combine_codelists,
    codelist_from_csv,
)

#study dates
from grouping_variables import (
    study_dates,
    days)
## Codelists from codelist.py (which pulls them from the codelist folder)
from codelists import *

## Datetime functions
from datetime import date

## Study definition helper
import study_definition_helper_functions as helpers

# Define pandemic_start
pandemic_start = study_dates["pandemic_start"]

#Define all gi bleedings, combined codelists
all_gi_bleeding_snomed = combine_codelists(
lower_gi_bleeding_snomed,
upper_gi_bleeding_snomed
)
all_gi_bleeding_hes = combine_codelists(
lower_gi_bleeding_icd10,
upper_gi_bleeding_icd10
)

#Define all gi symptoms, combined codelists
all_gi_symptoms_snomed =  combine_codelists(
ibs_snomed, diarrhoea_snomed, nausea_snomed, vomiting_snomed, abdominal_paindiscomfort_snomed,
bowel_ischaemia_snomed, intestinal_obstruction_snomed, belching_snomed, abdominal_distension_snomed, bloody_stools_snomed
)
all_gi_symptoms_icd10 =  combine_codelists(
ibs_icd10, diarrhoea_icd10, nausea_icd10, vomiting_icd10, abdominal_paindiscomfort_icd10,
bowel_ischaemia_icd10, intestinal_obstruction_icd10, belching_icd10, abdominal_distension_icd10, bloody_stools_icd10
)
# combine all alcohol codes 

# Define common variables function

def generate_common_variables(index_date_variable,end_date_variable):
    dynamic_variables = dict(
# DEFINE EXPOSURES ------------------------------------------------------

    ## Date of positive SARS-COV-2 PCR antigen test
    tmp_exp_date_covid19_confirmed_sgss=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        between=[f"{index_date_variable}",f"{end_date_variable}"],
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    ## First COVID-19 code (diagnosis, positive test or sequalae) in primary care
    tmp_exp_date_covid19_confirmed_snomed=patients.with_these_clinical_events(
        combine_codelists(
            covid_primary_care_code,
            covid_primary_care_positive_test,
            covid_primary_care_sequalae,
        ),
        returning="date",
        between=[f"{index_date_variable}",f"{end_date_variable}"],
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    ## Start date of episode with confirmed diagnosis in any position
    tmp_exp_date_covid19_confirmed_hes=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning="date_admitted",
        between=[f"{index_date_variable}",f"{end_date_variable}"],
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    ## Date of death with SARS-COV-2 infection listed as primary or underlying cause
    tmp_exp_date_covid19_confirmed_death=patients.with_these_codes_on_death_certificate(
        covid_codes,
        returning="date_of_death",
        between=[f"{index_date_variable}",f"{end_date_variable}"],
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1
        },
    ),
    ## Generate variable to identify first date of confirmed COVID
    exp_date_covid19_confirmed=patients.minimum_of(
        "tmp_exp_date_covid19_confirmed_sgss","tmp_exp_date_covid19_confirmed_snomed","tmp_exp_date_covid19_confirmed_hes","tmp_exp_date_covid19_confirmed_death"
    ),
# POPULATION SELECTION VARIABLES ------------------------------------------------------

    has_follow_up_previous_6months=patients.registered_with_one_practice_between(
        start_date=f"{index_date_variable} - 6 months",
        end_date=f"{index_date_variable}",
        return_expectations={"incidence": 0.95},
    ),

    has_died = patients.died_from_any_cause(
        on_or_before = f"{index_date_variable}",
        returning="binary_flag",
        return_expectations={"incidence": 0.01}
    ),

    registered_at_start = patients.registered_as_of(f"{index_date_variable}",
    ),

  
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        
        between=[f"{index_date_variable}",f"{end_date_variable}"],
        date_format = 'YYYY-MM-DD',
        return_expectations={
        "date": {"earliest": study_dates["pandemic_start"], "latest": "today"},
        "rate": "uniform",
        "incidence": 0.01
    },
    ),
    # Define subgroups (for variables that don't have a corresponding covariate only)
    ## COVID-19 severity
    sub_date_covid19_hospital = patients.admitted_to_hospital(
        with_these_primary_diagnoses=covid_codes,
        returning="date_admitted",
        on_or_after="exp_date_covid19_confirmed",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.5,
        },
    ),
    ## History of COVID-19 
    ### Positive SARS-COV-2 PCR antigen test
    tmp_sub_bin_covid19_confirmed_history_sgss=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    ),
    ### COVID-19 code (diagnosis, positive test or sequalae) in primary care
    tmp_sub_bin_covid19_confirmed_history_snomed=patients.with_these_clinical_events(
        combine_codelists(
            covid_primary_care_code,
            covid_primary_care_positive_test,
            covid_primary_care_sequalae,
        ),
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    ),
    ### Hospital episode with confirmed diagnosis in any position
    tmp_sub_bin_covid19_confirmed_history_hes=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codes,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    ),
    ## Generate variable to identify first date of confirmed COVID
    sub_bin_covid19_confirmed_history=patients.maximum_of(
        "tmp_sub_bin_covid19_confirmed_history_sgss","tmp_sub_bin_covid19_confirmed_history_snomed","tmp_sub_bin_covid19_confirmed_history_hes"
    ),

# DEFINE COVARIATES ------------------------------------------------------

    ## Age
    cov_num_age = patients.age_as_of(
        f"{index_date_variable} - 1 day",
        return_expectations = {
        "rate": "universal",
        "int": {"distribution": "population_ages"},
        "incidence" : 0.001
        },
    ),



    ## Ethnicity 
    cov_cat_ethnicity=patients.categorised_as(
        helpers.generate_ethnicity_dictionary(6),
        cov_ethnicity_sus=patients.with_ethnicity_from_sus(
            returning="group_6", use_most_frequent_code=True
        ),
        cov_ethnicity_gp_opensafely=patients.with_these_clinical_events(
            opensafely_ethnicity_codes_6,
            on_or_before=f"{index_date_variable} - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        cov_ethnicity_gp_primis=patients.with_these_clinical_events(
            primis_covid19_vacc_update_ethnicity,
            on_or_before=f"{index_date_variable} - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        cov_ethnicity_gp_opensafely_date=patients.with_these_clinical_events(
            opensafely_ethnicity_codes_6,
            on_or_before=f"{index_date_variable} - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        cov_ethnicity_gp_primis_date=patients.with_these_clinical_events(
            primis_covid19_vacc_update_ethnicity,
            on_or_before=f"{index_date_variable} - 1 day",
            returning="category",
            find_last_match_in_period=True,
        ),
        return_expectations=helpers.generate_universal_expectations(5,True),
    ),

    ## Deprivation
    cov_cat_deprivation=patients.categorised_as(
        helpers.generate_deprivation_ntile_dictionary(10),
        index_of_multiple_deprivation=patients.address_as_of(
            f"{index_date_variable} - 1 day",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations=helpers.generate_universal_expectations(10,False),
    ),

    ## Region
    cov_cat_region=patients.registered_practice_as_of(
        f"{index_date_variable} - 1 day",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and The Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East": 0.1,
                    "London": 0.2,
                    "South East": 0.1,
                    "South West": 0.1,
                },
            },
        },
    ),

    ## Smoking status
    cov_cat_smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                most_recent_smoking_code = 'E' OR (
                most_recent_smoking_code = 'N' AND ever_smoked
                )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            smoking_clear,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable} - 1 day",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(smoking_clear, include=["S", "E"]),
            on_or_before=f"{index_date_variable} - 1 day",
        ),
    ),
## Combined oral contraceptive pill
    ### dmd: dictionary of medicines and devices
    cov_bin_combined_oral_contraceptive_pill=patients.with_these_medications(
        cocp_dmd, 
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.3},
    ),

    ## Hormone replacement therapy
    cov_bin_hormone_replacement_therapy=patients.with_these_medications(
        hrt_dmd, 
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",

        return_expectations={"incidence": 0.3},
    ),

 
    ## Care home status
    cov_bin_carehome_status=patients.care_home_status_as_of(
        f"{index_date_variable} -1 day", 
        categorised_as={
            "TRUE": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='Y'
              AND LocationRequiresNursing='N'
            """,
            "TRUE": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='N'
              AND LocationRequiresNursing='Y'
            """,
            "TRUE": "IsPotentialCareHome",
            "FALSE": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"TRUE": 0.30, "FALSE": 0.70},},
        },
    ),

    ## Obesity
    ### Primary care
    tmp_cov_bin_obesity_snomed=patients.with_these_clinical_events(
        bmi_obesity_snomed_clinical,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    ),
    ### HES APC
    tmp_cov_bin_obesity_hes=patients.admitted_to_hospital(
        returning='binary_flag',
        with_these_diagnoses=bmi_obesity_icd10,
        on_or_before=f"{index_date_variable} -1 day",
        return_expectations={"incidence": 0.1},
    ),
    ### Combined
    cov_bin_obesity=patients.maximum_of(
        "tmp_cov_bin_obesity_snomed", "tmp_cov_bin_obesity_hes",
    ),
  

    ## Total Cholesterol
    tmp_cov_num_cholesterol=patients.max_recorded_value(
        cholesterol_snomed,
        on_most_recent_day_of_measurement=True, 
        between=[f"{index_date_variable} - 5 years", f"{index_date_variable} -1 day"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "float": {"distribution": "normal", "mean": 5.0, "stddev": 2.5},
            "date": {"earliest":study_dates["earliest_expec"], "latest": "today"}, ##return_expectations can't take dynamic variable se default are kept here! 
            "incidence": 0.80,
        },
    ),

    ## HDL Cholesterol
    tmp_cov_num_hdl_cholesterol=patients.max_recorded_value(
        hdl_cholesterol_snomed,
        on_most_recent_day_of_measurement=True, 
        between=[f"{index_date_variable}- 5years", f"{index_date_variable} -1 day"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "float": {"distribution": "normal", "mean": 2.0, "stddev": 1.5},
            "date": {"earliest": study_dates["earliest_expec"] , "latest": "today"},
            "incidence": 0.80,
        },
    ),

    ## BMI
    # taken from: https://github.com/opensafely/BMI-and-Metabolic-Markers/blob/main/analysis/common_variables.py 
    
     ### Categorising BMI
    cov_cat_bmi_groups = patients.categorised_as(
        {
            "Underweight": "cov_num_bmi < 18.5 AND cov_num_bmi > 12", 
            "Healthy_weight": "cov_num_bmi >= 18.5 AND cov_num_bmi < 25", 
            "Overweight": "cov_num_bmi >= 25 AND cov_num_bmi < 30",
            "Obese": "cov_num_bmi >=30 AND cov_num_bmi <70", 
            "Missing": "DEFAULT", 
        }, 
        return_expectations = {
            "rate": "universal", 
            "category": {
                "ratios": {
                    "Underweight": 0.05, 
                    "Healthy_weight": 0.25, 
                    "Overweight": 0.4,
                    "Obese": 0.3, 
                }
            },
        },
        cov_num_bmi = patients.most_recent_bmi(
        on_or_before=f"{index_date_variable} - 1 day",
        minimum_age_at_measurement=18,
        include_measurement_date=True,
        date_format="YYYY-MM",
        return_expectations={
            "date": {"earliest": "2010-02-01", "latest": "2022-02-01"}, ##How do we obtain these dates ? 
            "float": {"distribution": "normal", "mean": 28, "stddev": 8},
            "incidence": 0.7,
        },
    ),

        
    ),

# Define quality assurances
    ## Prostate cancer
        ### Primary care
        prostate_cancer_snomed=patients.with_these_clinical_events(
            prostate_cancer_snomed_clinical,
            returning='binary_flag',
            return_expectations={
                "incidence": 0.03,
            },
        ),
        ### HES APC
        prostate_cancer_hes=patients.admitted_to_hospital(
            with_these_diagnoses=prostate_cancer_icd10,
            returning='binary_flag',
            return_expectations={
                "incidence": 0.03,
            },
        ),
        ### ONS
        prostate_cancer_death=patients.with_these_codes_on_death_certificate(
            prostate_cancer_icd10,
            returning='binary_flag',
            return_expectations={
                "incidence": 0.02
            },
        ),
        ### Combined
        qa_bin_prostate_cancer=patients.maximum_of(
            "prostate_cancer_snomed", "prostate_cancer_hes", "prostate_cancer_death"
        ),

    ## Pregnancy
        qa_bin_pregnancy=patients.with_these_clinical_events(
            pregnancy_snomed_clinical,
            returning='binary_flag',
            return_expectations={
                "incidence": 0.03,
            },
        ),
    
    ## Year of birth
        qa_num_birth_year=patients.date_of_birth(
            date_format="YYYY",
            return_expectations={
                "date": {"earliest": study_dates["earliest_expec"], "latest": "today"},
                "rate": "uniform",
            },
        ),
        # Define fixed covariates other than sex
# NB: sex is required to determine vaccine eligibility covariates so is defined in study_definition_electively_unvaccinated.py

    ## 2019 consultation rate
        cov_num_consulation_rate=patients.with_gp_consultations(
            between=[days(study_dates["pandemic_start"],-365), days(study_dates["pandemic_start"],-1)],
            returning="number_of_matches_in_period",
            return_expectations={
                "int": {"distribution": "poisson", "mean": 5},
            },
        ),

    ## Healthcare worker    
    cov_bin_healthcare_worker=patients.with_healthcare_worker_flag_on_covid_vaccine_record(
        returning='binary_flag', 
        return_expectations={"incidence": 0.01},
    ),
    #---------------
    #GI Variables
    #---------------
    ##chronic ouctomes to be excluded from the population: Crohn,Cirrhosis & Coeliac
    #Crohn's disease
    tmp_bin_crohn_snomed = patients.with_these_clinical_events(
        crohn_snomed,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    
    ),
    tmp_bin_crohn_hes = patients.admitted_to_hospital(
        with_these_diagnoses= crohn_icd10,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        
        return_expectations={"incidence": 0.1},
    ),
    
    out_bin_crohn = patients.maximum_of(
        "tmp_bin_crohn_snomed","tmp_bin_crohn_hes"
        ),
    #Coeliac disease
    tmp_bin_coeliac_disease_snomed = patients.with_these_clinical_events(
        coeliac_disease_snomed,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    
    ),
    tmp_bin_coeliac_disease_hes = patients.admitted_to_hospital(
        with_these_diagnoses= coeliac_disease_icd10,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        
        return_expectations={"incidence": 0.1},
    ),
    
    out_bin_coeliac_disease = patients.maximum_of(
        "tmp_bin_coeliac_disease_snomed","tmp_bin_coeliac_disease_hes"
        ),
    #Cirrhosis
    tmp_bin_cirrhosis_snomed = patients.with_these_clinical_events(
        cirrhosis_snomed,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        return_expectations={"incidence": 0.1},
    
    ),
    tmp_bin_cirrhosis_hes = patients.admitted_to_hospital(
        with_these_diagnoses= cirrhosis_icd10,
        returning='binary_flag',
        on_or_before=f"{index_date_variable} - 1 day",
        
        return_expectations={"incidence": 0.1},
    ),
    
    out_bin_cirrhosis = patients.maximum_of(
        "tmp_bin_cirrhosis_snomed","tmp_bin_cirrhosis_hes"
        ),
    #--------------
     #GI outocomes
    #--------------
    # Symptoms
    ## IBS
    tmp_out_date_ibs_snomed = patients.with_these_clinical_events(
        ibs_snomed,
        returning='date',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    
    ),
    tmp_out_date_ibs_hes = patients.admitted_to_hospital(
        with_these_diagnoses= ibs_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    
    ),
    tmp_out_date_ibs_death=patients.with_these_codes_on_death_certificate(
        ibs_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_ibs = patients.minimum_of(
        "tmp_out_date_ibs_snomed","tmp_out_date_ibs_hes","tmp_out_date_ibs_death"
        ), 

    ##Diarrhoea
    tmp_out_date_diarrhoea_snomed = patients.with_these_clinical_events(
     diarrhoea_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
    return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_diarrhoea_hes = patients.admitted_to_hospital(
        with_these_diagnoses = diarrhoea_icd10,
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_diarrhoea_death=patients.with_these_codes_on_death_certificate(
        diarrhoea_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_diarrhoea = patients.minimum_of(
        "tmp_out_date_diarrhoea_hes","tmp_out_date_diarrhoea_snomed","tmp_out_date_diarrhoea_death"
        ), 

    ##Nausea
    tmp_out_date_nausea_snomed = patients.with_these_clinical_events(
     nausea_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_nausea_hes = patients.admitted_to_hospital(
        with_these_diagnoses= nausea_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_nausea_death=patients.with_these_codes_on_death_certificate(
        nausea_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    
    out_date_nausea = patients.minimum_of(
        "tmp_out_date_nausea_hes","tmp_out_date_nausea_snomed","tmp_out_date_nausea_death"
        ), 
 
 ##Vomiting
 tmp_out_date_vomiting_snomed = patients.with_these_clinical_events(
     vomiting_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
      date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_vomiting_hes = patients.admitted_to_hospital(
        with_these_diagnoses= vomiting_icd10, 
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    tmp_out_date_vomiting_death=patients.with_these_codes_on_death_certificate(
        vomiting_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_vomiting = patients.minimum_of(
        "tmp_out_date_vomiting_hes","tmp_out_date_vomiting_snomed","tmp_out_date_vomiting_death"
        ), 

    ##Abdominal pain and discomfort
    tmp_out_date_abdominal_paindiscomfort_snomed = patients.with_these_clinical_events(
     abdominal_paindiscomfort_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_abdominal_paindiscomfort_hes = patients.admitted_to_hospital(
        with_these_diagnoses= abdominal_paindiscomfort_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_abdominal_paindiscomfort_death=patients.with_these_codes_on_death_certificate(
        abdominal_paindiscomfort_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_abdominal_paindiscomfort = patients.minimum_of(
        "tmp_out_date_abdominal_paindiscomfort_hes","tmp_out_date_abdominal_paindiscomfort_snomed","tmp_out_date_abdominal_paindiscomfort_death"
        ), 
    
    ##Instesinal obstruction
    tmp_out_date_intestinal_obstruction_snomed = patients.with_these_clinical_events(
     intestinal_obstruction_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_intestinal_obstruction_hes = patients.admitted_to_hospital(
        with_these_diagnoses= intestinal_obstruction_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_intestinal_obstruction_death=patients.with_these_codes_on_death_certificate(
        intestinal_obstruction_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_intestinal_obstruction = patients.minimum_of(
        "tmp_out_date_intestinal_obstruction_hes","tmp_out_date_intestinal_obstruction_snomed","tmp_out_date_intestinal_obstruction_death"
        ), 
    ##Bowel ischaemia
    tmp_out_date_bowel_ischaemia_snomed = patients.with_these_clinical_events(
     bowel_ischaemia_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_bowel_ischaemia_hes = patients.admitted_to_hospital(
        with_these_diagnoses= bowel_ischaemia_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_bowel_ischaemia_death=patients.with_these_codes_on_death_certificate(
       bowel_ischaemia_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_bowel_ischaemia = patients.minimum_of(
        "tmp_out_date_bowel_ischaemia_hes","tmp_out_date_bowel_ischaemia_snomed","tmp_out_date_bowel_ischaemia_death"
        ), 

    ##Belching
     tmp_out_date_belching_snomed = patients.with_these_clinical_events(
     belching_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_belching_hes = patients.admitted_to_hospital(
        with_these_diagnoses= belching_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_belching_death=patients.with_these_codes_on_death_certificate(
        belching_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_belching = patients.minimum_of(
        "tmp_out_date_belching_hes","tmp_out_date_belching_snomed","tmp_out_date_belching_death"
        ), 

    #Abdominal distension
    tmp_out_date_abdominal_distension_snomed = patients.with_these_clinical_events(
        abdominal_distension_snomed,
        returning = 'date',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_abdominal_distension_hes = patients.admitted_to_hospital(
        with_these_diagnoses = abdominal_distension_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_abdominal_distension_death=patients.with_these_codes_on_death_certificate(
        abdominal_distension_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_abdominal_distension = patients.minimum_of(
        "tmp_out_date_abdominal_distension_hes","tmp_out_date_abdominal_distension_snomed","tmp_out_date_abdominal_distension_death"
    ),

    ##Bloody stools
    tmp_out_date_bloody_stools_snomed = patients.with_these_clinical_events(
     bloody_stools_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_bloody_stools_hes = patients.admitted_to_hospital(
        with_these_diagnoses= bloody_stools_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
       return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_bloody_stools_death=patients.with_these_codes_on_death_certificate(
        bloody_stools_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_bloody_stools = patients.minimum_of(
        "tmp_out_date_bloody_stools_hes","tmp_out_date_bloody_stools_snomed","tmp_out_date_bloody_stools_death"
        ), 
    
    
#Small bowel and colon
    
    #  tmp_out_date_coeliac_disease_snomed = patients.with_these_clinical_events(
    #  coeliac_disease_snomed, 
    #  returning = 'date', 
    #  on_or_after=f"{index_date_variable}",
    #  date_format="YYYY-MM-DD",
    #  return_expectations={"incidence": 0.1},
    # ),
    # tmp_out_date_coeliac_disease_hes = patients.admitted_to_hospital(
    #     with_these_diagnoses= coeliac_disease_icd10,
    #     returning='date_admitted',
    #     on_or_after=f"{index_date_variable}",
    #     date_format="YYYY-MM-DD",
    #     return_expectations={"incidence": 0.1},
    # ),
    # tmp_out_date_coeliac_disease_death=patients.with_these_codes_on_death_certificate(
    #     coeliac_disease_icd10,
    #     returning="date_of_death",
    #     on_or_after=f"{index_date_variable}",
    #     match_only_underlying_cause=True,
    #     date_format="YYYY-MM-DD",
    #     return_expectations={
    #         "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
    #         "rate": "uniform",
    #         "incidence": 0.1,
    #     },
    # ), 
    # out_date_coeliac_disease = patients.minimum_of(
    #     "tmp_out_date_coeliac_disease_hes","tmp_out_date_coeliac_disease_snomed","tmp_out_date_coeliac_disease_death"
    #     ), 

    ##Appendicitis
    tmp_out_date_appendicitis_snomed = patients.with_these_clinical_events(
     appendicitis_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_appendicitis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = appendicitis_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.1},
    ),
    tmp_out_date_appendicitis_death=patients.with_these_codes_on_death_certificate(
        appendicitis_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_appendicitis = patients.minimum_of(
        "tmp_out_date_appendicitis_hes","tmp_out_date_appendicitis_snomed","tmp_out_date_appendicitis_death"
        ),  

#Liver
    ##Gallstones disease
    tmp_out_date_gallstones_disease_snomed = patients.with_these_clinical_events(
     gallstones_disease_snomed,
     returning = 'date', 
     on_or_after=f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_gallstones_disease_hes = patients.admitted_to_hospital(
        with_these_diagnoses= gallstones_disease_icd10, 
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_gallstones_disease_death=patients.with_these_codes_on_death_certificate(
       gallstones_disease_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_gallstones_disease = patients.minimum_of(
        "tmp_out_date_gallstones_disease_hes","tmp_out_date_gallstones_disease_snomed","tmp_out_date_gallstones_disease_death"
        ), 
    ##Non alcoholic steatohepatitis   
    tmp_out_date_nonalcoholic_steatohepatitis_snomed = patients.with_these_clinical_events(
     nonalcoholic_steatohepatitis_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_nonalcoholic_steatohepatitis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = nonalcoholic_steatohepatitis_icd10,
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
       return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_nonalcoholic_steatohepatitis_death=patients.with_these_codes_on_death_certificate(
        nonalcoholic_steatohepatitis_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_nonalcoholic_steatohepatitis = patients.minimum_of(
        "tmp_out_date_nonalcoholic_steatohepatitis_hes","tmp_out_date_nonalcoholic_steatohepatitis_snomed","tmp_out_date_nonalcoholic_steatohepatitis_death"
        ), 
    
#Pancreas
    ##Acute pancreatitis
    tmp_out_date_acute_pancreatitis_snomed = patients.with_these_clinical_events(
     acute_pancreatitis_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
    return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_acute_pancreatitis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = acute_pancreatitis_icd10,
        returning='date_admitted',
        on_or_after=f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_acute_pancreatitis_death=patients.with_these_codes_on_death_certificate(
        acute_pancreatitis_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_acute_pancreatitis = patients.minimum_of(
        "tmp_out_date_acute_pancreatitis_hes","tmp_out_date_acute_pancreatitis_snomed","tmp_out_date_acute_pancreatitis_death"
        ), 
    
#Oesophagous & stomach
    ##Gastro oesophageal reflux
    tmp_out_date_gastro_oesophageal_reflux_disease_snomed = patients.with_these_clinical_events(
     gastro_oesophageal_reflux_disease_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_gastro_oesophageal_reflux_disease_hes = patients.admitted_to_hospital(
        with_these_diagnoses = gastro_oesophageal_reflux_disease_icd10,
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_gastro_oesophageal_death=patients.with_these_codes_on_death_certificate(
        gastro_oesophageal_reflux_disease_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_gastro_oesophageal_reflux_disease = patients.minimum_of(
        "tmp_out_date_gastro_oesophageal_reflux_disease_hes","tmp_out_date_gastro_oesophageal_reflux_disease_snomed","tmp_out_date_gastro_oesophageal_death"
        ), 
 
    ##Dyspepsia
    tmp_out_date_dyspepsia_snomed = patients.with_these_clinical_events(
     dyspepsia_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_dyspepsia_hes = patients.admitted_to_hospital(
        with_these_diagnoses = dyspepsia_icd10, 
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_dyspepsia_death=patients.with_these_codes_on_death_certificate(
        dyspepsia_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_dyspepsia = patients.minimum_of(
        "tmp_out_date_dyspepsia_hes","tmp_out_date_dyspepsia_snomed","tmp_out_date_dyspepsia_death"
        ), 

    ##Peptic ulcer
    tmp_out_date_peptic_ulcer_snomed = patients.with_these_clinical_events(
     peptic_ulcer_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_peptic_ulcer_hes = patients.admitted_to_hospital(
        with_these_diagnoses = peptic_ulcer_icd10, 
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
       return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_peptic_ulcer_death=patients.with_these_codes_on_death_certificate(
        peptic_ulcer_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_peptic_ulcer = patients.minimum_of(
        "tmp_out_date_peptic_ulcer_hes","tmp_out_date_peptic_ulcer_snomed","tmp_out_date_peptic_ulcer_death"
        ), 

#GI bleedings
    ##Upper GI bleedings
     tmp_out_date_upper_gi_bleeding_snomed = patients.with_these_clinical_events(
     upper_gi_bleeding_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_upper_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses = upper_gi_bleeding_icd10, 
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_upper_gi_bleeding_death=patients.with_these_codes_on_death_certificate(
        upper_gi_bleeding_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_upper_gi_bleeding = patients.minimum_of(
        "tmp_out_date_upper_gi_bleeding_hes","tmp_out_date_upper_gi_bleeding_snomed","tmp_out_date_upper_gi_bleeding_death"
        ), 
    ##Lower GI bleedings
    tmp_out_date_lower_gi_bleeding_snomed = patients.with_these_clinical_events(
     lower_gi_bleeding_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_lower_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses = lower_gi_bleeding_icd10, 
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_lower_gi_bleeding_death=patients.with_these_codes_on_death_certificate(
        lower_gi_bleeding_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_lower_gi_bleeding = patients.minimum_of(
        "tmp_out_date_lower_gi_bleeding_snomed","tmp_out_date_lower_gi_bleeding_death","tmp_out_date_lower_gi_bleeding_hes"
        ), 
    ##Variceal GI bleeding
    tmp_out_date_variceal_gi_bleeding_snomed = patients.with_these_clinical_events(
     variceal_gi_bleeding_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_variceal_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses = variceal_gi_bleeding_icd10, 
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_variceal_gi_bleeding_death=patients.with_these_codes_on_death_certificate(
        variceal_gi_bleeding_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_variceal_gi_bleeding = patients.minimum_of(
        "tmp_out_date_variceal_gi_bleeding_hes","tmp_out_date_variceal_gi_bleeding_snomed","tmp_out_date_variceal_gi_bleeding_death"
        ), 
    ##Non variceal bleeding
    tmp_out_date_nonvariceal_gi_bleeding_snomed = patients.with_these_clinical_events(
     nonvariceal_gi_bleeding_snomed,
    #  ignore_days_where_these_codes_occur = variceal_gi_bleeding_snomed,
     returning = 'date', 
     on_or_after = f"{index_date_variable}",
     date_format="YYYY-MM-DD",
     return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_nonvariceal_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses = nonvariceal_gi_bleeding_icd10, 
        returning = 'date_admitted',
        on_or_after = f"{index_date_variable}",
        date_format="YYYY-MM-DD",
       return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ),
    tmp_out_date_nonvariceal_gi_bleeding_death=patients.with_these_codes_on_death_certificate(
        nonvariceal_gi_bleeding_icd10,
        returning="date_of_death",
        on_or_after=f"{index_date_variable}",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
            "incidence": 0.1,
        },
    ), 
    out_date_nonvariceal_gi_bleeding = patients.minimum_of(
        "tmp_out_date_nonvariceal_gi_bleeding_hes","tmp_out_date_nonvariceal_gi_bleeding_snomed","tmp_out_date_nonvariceal_gi_bleeding_death"
        ), 

#-----------
#GI Covars
#-----------
##Biomarkers just for ischaemic colitis, pencreatitis and NAFLD (Todo distinguish from other covars)
    ##Hypercalcemia
    cov_bin_hypercalcemia= patients.with_these_clinical_events(
        hypercalcemia_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
    ##Hypertriglyceridemia
    cov_bin_hypertriglyceridemia = patients.with_these_clinical_events(
        hypertriglyceridemia_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
    ##Systolic blood pressure
    # tmp_cov_num_systolic_blood_pressure_qof=patients.max_recorded_value( #todo fix the name
    #     systolic_blood_pressure_qof,
    #     on_most_recent_day_of_measurement=True, 
    #     between=[f"{index_date_variable}- 5years", f"{index_date_variable} -1 day"],
    #     date_format="YYYY-MM-DD",
    #     return_expectations={
    #         "float": {"distribution": "normal", "mean": 2.0, "stddev": 1.5},
    #         "date": {"earliest": study_dates["pandemic_start"] , "latest": "today"},
    #         "incidence": 0.80,
    #     },
    # ),
    # ##Diastolic blood pressure
    # tmp_cov_num_diastolic_blood_pressure_qof=patients.max_recorded_value( 
    #     diastolic_blood_pressure_snomed,
    #     on_most_recent_day_of_measurement=True, 
    #     between=[f"{index_date_variable}- 5years", f"{index_date_variable} -1 day"],
    #     date_format="YYYY-MM-DD",
    #     return_expectations={
    #         "float": {"distribution": "normal", "mean": 2.0, "stddev": 1.5},
    #         "date": {"earliest": study_dates["pandemic_start"] , "latest": "today"},
    #         "incidence": 0.80,
    #     },
    # ),
#Blood pressure copied from https://github.com/opensafely/covid_mortality_over_time/blob/4a51b47923cc186360cd3a8a6baf6b4544e6fc98/analysis/study_definition.py
# # Blood pressure
#     # filtering on >0 as missing values are returned as 0
#     bp_categorical=patients.categorised_as(
#         {
#             "0": "DEFAULT",
#             "1": """
#                     (bp_sys > 0 AND bp_sys < 120) AND
#                         (bp_dia > 0 AND bp_dia < 80)
#             """,
#             "2": """
#                     ((bp_sys >= 120 AND bp_sys < 130) AND
#                         (bp_dia > 0 AND bp_dia < 80)) OR
#                     ((bp_sys >= 130) OR
#                         (bp_dia >= 80))
#             """,
#         },
#         return_expectations={
#                                 "category": {
#                                     "ratios": {
#                                         "0": 0.8,
#                                         "1": 0.1,
#                                         "2": 0.1
#                                         }
#                                     },
#                                 },
#         bp_sys=patients.mean_recorded_value(
#             systolic_blood_pressure_codes,
#             on_most_recent_day_of_measurement=True,
#             between=[f"{index_date_variable}- 5years", f"{index_date_variable} -1 day"],
#             include_measurement_date=True,
#             include_month=True,
#             return_expectations={
#                 "incidence": 0.6,
#                 "float": {"distribution": "normal", "mean": 80, "stddev": 10},
#             },
#         ),
#         bp_dia=patients.mean_recorded_value(
#             diastolic_blood_pressure_codes,
#             on_most_recent_day_of_measurement=True,
#             between=[f"{index_date_variable}- 5years", f"{index_date_variable} -1 day"],
#             include_measurement_date=True,
#             include_month=True,
#             return_expectations={
#                 "incidence": 0.6,
#                 "float": {"distribution": "normal", "mean": 120, "stddev": 10},
#             },
#         ),
#     ),

    # ## Hypertension
    # ### Primary care
    # tmp_cov_bin_hypertension_snomed=patients.with_these_clinical_events(
    #     hypertension_snomed_clinical,
    #     returning='binary_flag',
    #     on_or_before=f"{index_date_variable} - 1 day",
    #     return_expectations={"incidence": 0.1},
    # ),
    # ### HES APC
    # tmp_cov_bin_hypertension_hes=patients.admitted_to_hospital(
    #    returning='binary_flag',
    #    with_these_diagnoses=hypertension_icd10,
    #    on_or_before=f"{index_date_variable} - 1 day",
    #    return_expectations={"incidence": 0.1},
    # ),
    # ### DMD
    # tmp_cov_bin_hypertension_drugs_dmd=patients.with_these_medications(
    #     hypertension_drugs_dmd,
    #     returning='binary_flag',
    #     on_or_before=f"{index_date_variable} - 1 day",
    #     return_expectations={"incidence": 0.1},
    # ),
    # ### Combined
    # cov_bin_hypertension=patients.maximum_of(
    #     "tmp_cov_bin_hypertension_snomed", "tmp_cov_bin_hypertension_hes", "tmp_cov_bin_hypertension_drugs_dmd",
    # ),

#systolic blood pressure
    systolic_bp = patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        include_measurement_date=True,
        between=[f"{index_date_variable} - 5years", f"{index_date_variable} - 1 day"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.8,
            "float": {"distribution": "normal", "mean": 110, "stddev": 20},
            "date": {"earliest": study_dates["pandemic_start"], "latest" : "today"},
            "rate": "uniform",
        },
    ),
#Medications
    ##NSAIDS
    cov_bin_nsaid_bnf = patients.with_these_medications(
        nsaids_bnf,
        returning='binary_flag',
        between = [f"{index_date_variable} - 2 years",f"{end_date_variable} - 1 day"],
        return_expectations={"incidence": 0.1},
    ),
    ##Aspirin
    cov_bin_aspirin_bnf = patients.with_these_medications(
        aspirin_bnf,
        returning = 'binary_flag',
        between = [f"{index_date_variable} - 2 years",f"{index_date_variable} - 1 day"],
        return_expectations = {"incidence": 0.1},
    ),
    ##Anticoagulants
    cov_bin_anticoagulants_bnf = patients.with_these_medications(
        anticoagulants_bnf,
        returning = 'binary_flag',
        between = [f"{index_date_variable} - 2 years",f"{index_date_variable} - 1 day"],
        return_expectations = {"incidence": 0.1},
    ),
    ##Antidepressants
    cov_bin_antidepressants_bnf = patients.with_these_medications(
        antidepressants_bnf,
        returning = 'binary_flag',
        between = [f"{index_date_variable} - 2 years",f"{index_date_variable} - 1 day"],
        return_expectations = {"incidence": 0.1},
    ),

# Alcohol 
cov_bin_alcohol_above_limits_ctv3 = patients.with_these_clinical_events(
        hazardous_alcohol_drinking,
        returning = 'binary_flag',
        between = [f"{index_date_variable} - 5 years",f"{index_date_variable} - 1 day"],
        find_last_match_in_period = True,
        return_expectations = {"incidence": 0.1}
),
cov_bin_alcohol_above_limits_snomed = patients.with_these_clinical_events(
        alcohol_snomed,
        returning = 'binary_flag',
        between = [f"{index_date_variable} - 5 years",f"{index_date_variable} - 1 day"],
        find_last_match_in_period = True,
         return_expectations = {"incidence": 0.1}
),
    cov_bin_alcohol_above_limits = patients.maximum_of(
        "cov_bin_alcohol_above_limits_ctv3","cov_bin_alcohol_above_limits_snomed"
        ),

  #Diseases
    ##Cholelisthiasis
    tmp_cov_bin_cholelisthiasis_snomed = patients.with_these_clinical_events(
        cholelisthiasis_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_cholelisthiasis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = cholelisthiasis_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
    # tmp_cov_bin_cholelisthiasis_death=patients.with_these_codes_on_death_certificate(
    #     cholelisthiasis_icd10,
    #     on_or_before=f"{index_date_variable}",
    #     match_only_underlying_cause=True,
    #     returning='binary_flag',
    #     return_expectations={"incidence": 0.1},
    #     ),
    cov_bin_cholelisthiasis = patients.maximum_of(
        "tmp_cov_bin_cholelisthiasis_hes","tmp_cov_bin_cholelisthiasis_snomed" #,"tmp_cov_bin_cholelisthiasis_death"
        ), 
    ##h_pylori_infection
    tmp_cov_bin_h_pylori_infection_snomed = patients.with_these_clinical_events(
        h_pylori_infection_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
    tmp_cov_bin_h_pylori_infection_hes = patients.admitted_to_hospital(
        with_these_diagnoses = h_pylori_infection_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
  
    cov_bin_h_pylori_infection = patients.maximum_of(
        "tmp_cov_bin_h_pylori_infection_hes","tmp_cov_bin_h_pylori_infection_snomed" #, "tmp_cov_bin_h_pylori_infection_death"
        ), 

#All GI symptoms
     tmp_cov_bin_all_gi_symptoms_snomed = patients.with_these_clinical_events(
        all_gi_symptoms_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_all_gi_symptoms_hes = patients.admitted_to_hospital(
        with_these_diagnoses = all_gi_symptoms_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
 
    cov_bin_all_gi_symptoms = patients.maximum_of(
        "tmp_cov_bin_all_gi_symptoms_hes","tmp_cov_bin_all_gi_symptoms_snomed" 
        ), 

    ##History of GI diseases
      ##Bowel and colon 
    #  tmp_cov_bin_coeliac_disease_snomed = patients.with_these_clinical_events(
    #     coeliac_disease_snomed,
    #     returning = 'binary_flag',
    #     on_or_before = f"{index_date_variable} - 1 day" ,
    #     return_expectations = {"incidence": 0.1},
    #     ),

    # tmp_cov_bin_coeliac_disease_hes = patients.admitted_to_hospital(
    #     with_these_diagnoses =coeliac_disease_icd10,
    #     returning = 'binary_flag',
    #     on_or_before = f"{index_date_variable} - 1 day" ,
    #     return_expectations = {"incidence": 0.1},
    #     ),
    # tmp_cov_bin_coeliac_disease_death=patients.with_these_codes_on_death_certificate(
    #     coeliac_disease_icd10,
    #     on_or_after=f"{index_date_variable}",
    #     match_only_underlying_cause=True,
    #     returning='binary_flag',
    #     return_expectations={"incidence": 0.1},
    #     ),
    # cov_bin_coeliac_disease = patients.maximum_of(
    #     "tmp_cov_bin_coeliac_disease_hes","tmp_cov_bin_coeliac_disease_snomed","tmp_cov_bin_coeliac_disease_death"
    #     ), 
    ##History of appendicitis
    tmp_cov_bin_appendicitis_snomed = patients.with_these_clinical_events(
        appendicitis_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_appendicitis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = appendicitis_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
   
    cov_bin_appendicitis = patients.maximum_of(
        "tmp_cov_bin_appendicitis_hes","tmp_cov_bin_appendicitis_snomed" #,"tmp_cov_bin_appendicitis_death"
        ), 

    ##History of Liver diseases
    tmp_cov_bin_gallstones_disease_snomed = patients.with_these_clinical_events(
        gallstones_disease_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_gallstones_disease_hes = patients.admitted_to_hospital(
        with_these_diagnoses = gallstones_disease_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
 
    cov_bin_gallstones_disease = patients.maximum_of(
        "tmp_cov_bin_gallstones_disease_hes","tmp_cov_bin_gallstones_disease_snomed" #,"tmp_cov_bin_gallstones_disease_death"
        ), 

    tmp_cov_bin_nonalcoholic_steatohepatitis_snomed = patients.with_these_clinical_events(
       nonalcoholic_steatohepatitis_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_nonalcoholic_steatohepatitis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = nonalcoholic_steatohepatitis_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
 
    cov_bin_nonalcoholic_steatohepatitis = patients.maximum_of(
        "tmp_cov_bin_nonalcoholic_steatohepatitis_hes","tmp_cov_bin_nonalcoholic_steatohepatitis_snomed",#"tmp_cov_bin_nonalcoholic_steatohepatitis_death"
        ), 
    
    ##History of Pancreas diseases
    tmp_cov_bin_acute_pancreatitis_snomed = patients.with_these_clinical_events(
        acute_pancreatitis_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_acute_pancreatitis_hes = patients.admitted_to_hospital(
        with_these_diagnoses = acute_pancreatitis_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    cov_bin_acute_pancreatitis = patients.maximum_of(
        "tmp_cov_bin_acute_pancreatitis_hes","tmp_cov_bin_acute_pancreatitis_snomed" #,"tmp_cov_bin_acute_pancreatitis_death"
        ), 

    ##History of oesophagous and stomach diseases
    tmp_cov_bin_gastro_oesophageal_reflux_disease_snomed = patients.with_these_clinical_events(
       gastro_oesophageal_reflux_disease_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_gastro_oesophageal_reflux_disease_hes = patients.admitted_to_hospital(
        with_these_diagnoses = gastro_oesophageal_reflux_disease_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
  
    cov_bin_gastro_oesophageal_reflux_disease = patients.maximum_of(
        "tmp_cov_bin_gastro_oesophageal_reflux_disease_hes","tmp_cov_bin_gastro_oesophageal_reflux_disease_snomed" #,"tmp_cov_bin_gastro_oesophageal_reflux_disease_death"
        ), 

  tmp_cov_bin_dyspepsia_snomed = patients.with_these_clinical_events(
        dyspepsia_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_dyspepsia_hes = patients.admitted_to_hospital(
        with_these_diagnoses = dyspepsia_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
  
    cov_bin_dyspepsia = patients.maximum_of(
        "tmp_cov_bin_dyspepsia_hes","tmp_cov_bin_dyspepsia_snomed"#,"tmp_cov_bin_dyspepsia_death"
        ), 

    tmp_cov_bin_peptic_ulcer_snomed = patients.with_these_clinical_events(
        peptic_ulcer_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_peptic_ulcer_hes = patients.admitted_to_hospital(
        with_these_diagnoses =peptic_ulcer_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
  
    cov_bin_peptic_ulcer = patients.maximum_of(
        "tmp_cov_bin_peptic_ulcer_hes","tmp_cov_bin_peptic_ulcer_snomed" #,"tmp_cov_bin_peptic_ulcer_death"
        ),

#GI bleeds covars
    ##Upper GI bleeding

    tmp_cov_bin_upper_gi_bleeding_snomed = patients.with_these_clinical_events(
        upper_gi_bleeding_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_upper_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses =upper_gi_bleeding_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
    
    cov_bin_upper_gi_bleeding = patients.maximum_of(
        "tmp_cov_bin_upper_gi_bleeding_hes","tmp_cov_bin_upper_gi_bleeding_snomed" #,"tmp_cov_bin_upper_gi_bleeding_death"
        ), 
    ##Lower GI bleeding
    tmp_cov_bin_lower_gi_bleeding_snomed = patients.with_these_clinical_events(
        lower_gi_bleeding_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_lower_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses =lower_gi_bleeding_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
 
    cov_bin_lower_gi_bleeding = patients.maximum_of(
        "tmp_cov_bin_lower_gi_bleeding_hes","tmp_cov_bin_lower_gi_bleeding_snomed"#,"tmp_cov_bin_lower_gi_bleeding_death"
        ), 
    
    ##Variceal GI bleeding
    tmp_cov_bin_variceal_gi_bleeding_snomed = patients.with_these_clinical_events(
        variceal_gi_bleeding_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_variceal_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses = 
        variceal_gi_bleeding_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
   
    cov_bin_variceal_gi_bleeding = patients.maximum_of(
        "tmp_cov_bin_variceal_gi_bleeding_hes","tmp_cov_bin_variceal_gi_bleeding_snomed" #,"tmp_cov_bin_variceal_gi_bleeding_death"
        ), 


###Non variceal GI bleedings
    tmp_cov_bin_nonvariceal_gi_bleeding_snomed = patients.with_these_clinical_events(
        nonvariceal_gi_bleeding_snomed,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),

    tmp_cov_bin_nonvariceal_gi_bleeding_hes = patients.admitted_to_hospital(
        with_these_diagnoses = 
        nonvariceal_gi_bleeding_icd10,
        returning = 'binary_flag',
        on_or_before = f"{index_date_variable} - 1 day" ,
        return_expectations = {"incidence": 0.1},
        ),
    cov_bin_nonvariceal_gi_bleeding = patients.maximum_of(
        "tmp_cov_bin_variceal_gi_bleeding_hes","tmp_cov_bin_variceal_gi_bleeding_snomed"
        ), 

    cov_bin_overall_gi_and_symptoms = patients.maximum_of(
        "cov_bin_dyspepsia",
        "cov_bin_gastro_oesophageal_reflux_disease",
        "cov_bin_acute_pancreatitis",
        "cov_bin_nonalcoholic_steatohepatitis",
        "cov_bin_gallstones_disease",
        "cov_bin_peptic_ulcer",
        "cov_bin_upper_gi_bleeding",
        "cov_bin_lower_gi_bleeding",
        "cov_bin_variceal_gi_bleeding",
        "cov_bin_all_gi_symptoms"

    ),

#GI operations 
    cov_bin_gi_operations = patients.admitted_to_hospital(
    returning="binary_flag",
    on_or_before = f"{index_date_variable} - 1 day" ,
    with_these_procedures = gi_operations_opcs4,
    return_expectations={
      "incidence": 0.1
    },
  ),  
   
    
    )   

    return dynamic_variables
