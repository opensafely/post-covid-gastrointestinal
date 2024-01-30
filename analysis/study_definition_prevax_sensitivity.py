## Set seed
import numpy as np
np.random.seed(123456)

# Cohort extractor
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

## Import common variables sensitivity function
from common_variables_sensitivity import generate_common_variables_sensitivity
(
    sensitivity_variables
) = generate_common_variables_sensitivity( exposure_date_variable="exp_date", outcome_end_date_variable="end_date_outcome")


input_file = "output/input_prevax_stage1_sens.csv.gz"

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
    
    **sensitivity_variables

)
