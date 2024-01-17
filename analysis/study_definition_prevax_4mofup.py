## Set seed
import numpy as np
np.random.seed(123456)
#patient ID, vaccination dates, vaccination eligibility

# Cohort extractor
from tracemalloc import start
from cohortextractor import (
  StudyDefinition,
  patients,
  date_expressions,
  codelist_from_csv,
  codelist,
  filter_codes_by_category,
  combine_codelists,
)
## Codelists from codelist.py (which pulls them from the codelist folder)
from codelists import *

## Datetime functions
from datetime import date


import json

input_file = "output/input_prevax_stage1.csv.gz"

study = StudyDefinition(
    population=patients.which_exist_in_file(input_file),
    exp_date = patients.with_value_from_file(
     f_path = input_file,
        returning = 'exp_date_covid19_confirmed',
        returning_type = 'date',  
        date_format = 'YYYY-MM-DD',
        ),

    end_date_outcome = patients.with_value_from_file(
        f_path = input_file, 
        returning = 'end_date_outcome',
        returning_type = 'date',
        date_format = 'YYYY-MM-DD',
    ),
    index_date_variable = patients.with_value_from_file(
        f_path = input_file,
        returning = 'index_date',
        returning_type = 'date',
        date_format = 'YYYY-MM-DD',
    ),

    discharge_date = patients.admitted_to_hospital(
        with_these_primary_diagnoses = covid_codes,
        returning = "date_discharged",
        on_or_after = "exp_date",
        date_format = "YYYY-MM-DD",
        find_first_match_in_period = True,
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},

        
    ),
    cov_bin_anticoagulants_4mofup_bnf = patients.with_these_medications(
        anticoagulants_bnf,
        returning = 'binary_flag',
        between = ["discharge_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),

    ## Venous thrombolism events
    ### Primary care
    tmp_cov_bin_vte_snomed=patients.with_these_clinical_events(
        all_vte_codes_snomed_clinical,
        returning='binary_flag',
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### HES APC
    tmp_cov_bin_vte_hes=patients.admitted_to_hospital(
        returning='binary_flag',
        with_these_diagnoses=all_vte_codes_icd10,
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### Combined
    cov_bin_vte=patients.maximum_of(
        "tmp_cov_bin_vte_snomed", "tmp_cov_bin_vte_hes",
    ),

    ## Arterial thrombosis events (i.e., any arterial event - this combines: AMI, ischaemic stroke, other arterial embolism)
    ### Primary care
    tmp_cov_bin_ate_snomed=patients.with_these_clinical_events(
        all_ate_codes_snomed_clinical,
        returning="binary_flag",
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### HES APC
    tmp_cov_bin_ate_hes=patients.admitted_to_hospital(
        returning="binary_flag",
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### ONS
    tmp_cov_bin_ate_death=patients.with_these_codes_on_death_certificate(
        all_ate_codes_icd10,
        returning="binary_flag",
        between = ["exp_date" ,"end_date_outcome" ],
        return_expectations = {"incidence": 0.1,"date": {"earliest": "1980-02-01", "latest": "2021-05-31"},},
    ),
    ### Combined
    cov_bin_ate=patients.maximum_of(
        "tmp_cov_bin_ate_snomed", "tmp_cov_bin_ate_hes", "tmp_cov_bin_ate_death"
    ),
 
#    VTE & ATE
cov_bin_ate_vte_4mofup = patients.maximum_of(
    "cov_bin_ate", "cov_bin_vte"
),

    
    
)
