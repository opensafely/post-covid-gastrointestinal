
# Import statements

## Cohort extractor
from cohortextractor import (
    patients,
    codelist,
    filter_codes_by_category,
    combine_codelists,
    codelist_from_csv,
)

## Codelists from codelist.py (which pulls them from the codelist folder)
from codelists import *

## Datetime functions
from datetime import date

## Study definition helper
import study_definition_helper_functions as helpers

# DEFINE anticoag and thrombotic events sensitivity common variables ----------------------------------------------
def generate_common_variables_sensitivity(exposure_date_variable,outcome_end_date_variable):
    sensitivity_variables = dict(

    discharge_date = patients.admitted_to_hospital(
        with_these_primary_diagnoses = covid_codes,
        returning = "date_discharged",
        on_or_after = "exp_date",
        date_format = "YYYY-MM-DD",
        find_first_match_in_period = True,
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},

        
    ),
    sub_count_anticoagulants_bnf = patients.with_these_medications(
        anticoagulants_bnf,
        returning="number_of_matches_in_period",
        between = ["discharge_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),

    ## Venous thrombolism events
    ### Primary care
    tmp_sub_bin_vte_snomed=patients.with_these_clinical_events(
        all_vte_codes_snomed_clinical,
        returning='binary_flag',
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### HES APC
    tmp_sub_bin_vte_hes=patients.admitted_to_hospital(
        returning='binary_flag',
        with_these_diagnoses=all_vte_codes_icd10,
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### Combined
    sub_bin_vte=patients.maximum_of(
        "tmp_sub_bin_vte_snomed", "tmp_sub_bin_vte_hes",
    ),

    ## Arterial thrombosis events (i.e., any arterial event - this combines: AMI, ischaemic stroke, other arterial embolism)
    ### Primary care
    tmp_sub_bin_ate_snomed=patients.with_these_clinical_events(
        all_ate_codes_snomed_clinical,
        returning="binary_flag",
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### HES APC
    tmp_sub_bin_ate_hes=patients.admitted_to_hospital(
        returning="binary_flag",
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### ONS
    tmp_sub_bin_ate_death=patients.with_these_codes_on_death_certificate(
        all_ate_codes_icd10,
        returning="binary_flag",
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### Combined
    sub_bin_ate=patients.maximum_of(
        "tmp_sub_bin_ate_snomed", "tmp_sub_bin_ate_hes", "tmp_sub_bin_ate_death"
    ),
 
#    VTE & ATE
sub_bin_ate_vte_sensitivity = patients.maximum_of(
    "sub_bin_ate", "sub_bin_vte"
),

    )
    return sensitivity_variables