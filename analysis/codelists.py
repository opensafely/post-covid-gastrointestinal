from cohortextractor import codelist_from_csv, combine_codelists, codelist
import glob
#Covid
covid_codes = codelist_from_csv(
    "codelists/user-RochelleKnight-confirmed-hospitalised-covid-19.csv",
    system="icd10",
    column="code",
)

covid_primary_care_positive_test = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_primary_care_code = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_primary_care_sequalae = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    system="ctv3",
    column="CTV3ID",
)
#Ethnicity
opensafely_ethnicity_codes_6 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)

primis_covid19_vacc_update_ethnicity = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth2001.csv",
    system="snomed",
    column="code",
    category_column="grouping_6_id",
)
#Smoking
smoking_clear = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

smoking_unclear = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)



# BMI
bmi_obesity_snomed_clinical = codelist_from_csv(
    "codelists/user-elsie_horne-bmi_obesity_snomed.csv",
    system="snomed",
    column="code",
)

bmi_obesity_icd10 = codelist_from_csv(
    "codelists/user-elsie_horne-bmi_obesity_icd10.csv",
    system="icd10",
    column="code",
)

bmi_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi.csv",
    system="snomed",
    column="code",
)


# Total Cholesterol
cholesterol_snomed = codelist_from_csv(
    "codelists/opensafely-cholesterol-tests-numerical-value.csv",
    system="snomed",
    column="code",
)

# HDL Cholesterol
hdl_cholesterol_snomed = codelist_from_csv(
    "codelists/bristol-hdl-cholesterol.csv",
    system="snomed",
    column="code",
)
# Carer codes
carer_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-carer.csv",
    system="snomed",
    column="code",
)

# No longer a carer codes
notcarer_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-notcarer.csv",
    system="snomed",
    column="code",
)
# Wider Learning Disability
learndis_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-learndis.csv",
    system="snomed",
    column="code",
)
# Employed by Care Home codes
carehome_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-carehome.csv",
    system="snomed",
    column="code",
)

# Employed by nursing home codes
nursehome_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-nursehome.csv",
    system="snomed",
    column="code",
)

# Employed by domiciliary care provider codes
domcare_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-domcare.csv",
    system="snomed",
    column="code",
)

# Patients in long-stay nursing and residential care
longres_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-longres.csv",
    system="snomed",
    column="code",
)
# High Risk from COVID-19 code
shield_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-shield.csv",
    system="snomed",
    column="code",
)

# Lower Risk from COVID-19 codes
nonshield_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-nonshield.csv",
    system="snomed",
    column="code",
)

#For JCVI groups
# Pregnancy codes 
preg_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-preg.csv",
    system="snomed",
    column="code",
)

# Pregnancy or Delivery codes
pregdel_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-pregdel.csv",
    system="snomed",
    column="code",
)
# All BMI coded terms
bmi_stage_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi_stage.csv",
    system="snomed",
    column="code",
)
# Severe Obesity code recorded
sev_obesity_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-sev_obesity.csv",
    system="snomed",
    column="code",
)
# Asthma Diagnosis code
ast_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ast.csv",
    system="snomed",
    column="code",
)

# Asthma Admission codes
astadm_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-astadm.csv",
    system="snomed",
    column="code",
)

# Asthma systemic steroid prescription codes
astrx_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-astrx.csv",
    system="snomed",
    column="code",
)
# Chronic Respiratory Disease
resp_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-resp_cov.csv",
    system="snomed",
    column="code",
)
# Chronic Neurological Disease including Significant Learning Disorder
cns_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cns_cov.csv",
    system="snomed",
    column="code",
)

# Asplenia or Dysfunction of the Spleen codes
spln_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-spln_cov.csv",
    system="snomed",
    column="code",
)
# Diabetes diagnosis codes
diab_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-diab.csv",
    system="snomed",
    column="code",
)
# Diabetes resolved codes
dmres_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-dmres.csv",
    system="snomed",
    column="code",
)
# Severe Mental Illness codes
sev_mental_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-sev_mental.csv",
    system="snomed",
    column="code",
)

# Remission codes relating to Severe Mental Illness
smhres_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-smhres.csv",
    system="snomed",
    column="code",
)

# Chronic heart disease codes
chd_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-chd_cov.csv",
    system="snomed",
    column="code",
)

# Chronic kidney disease diagnostic codes
ckd_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ckd_cov.csv",
    system="snomed",
    column="code",
)

# Chronic kidney disease codes - all stages
ckd15_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ckd15.csv",
    system="snomed",
    column="code",
)

# Chronic kidney disease codes-stages 3 - 5
ckd35_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ckd35.csv",
    system="snomed",
    column="code",
)

# Chronic Liver disease codes
cld_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cld.csv",
    system="snomed",
    column="code",
)
# Immunosuppression diagnosis codes
immdx_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-immdx_cov.csv",
    system="snomed",
    column="code",
)

# Immunosuppression medication codes
immrx_primis = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-immrx.csv",
    system="snomed",
    column="code",
)

##Quality assurance codes 

prostate_cancer_snomed_clinical = codelist_from_csv(
    "codelists/user-RochelleKnight-prostate_cancer_snomed.csv",
    system="snomed",
    column="code",
)
prostate_cancer_icd10 = codelist_from_csv(
    "codelists/user-RochelleKnight-prostate_cancer_icd10.csv",
    system="icd10",
    column="code",
)
pregnancy_snomed_clinical = codelist_from_csv(
    "codelists/user-RochelleKnight-pregnancy_and_birth_snomed.csv",
    system="snomed",
    column="code",
)
cocp_dmd = codelist_from_csv(
    "codelists/user-elsie_horne-cocp_dmd.csv",
    system="snomed",
    column="dmd_id",
)
hrt_dmd = codelist_from_csv(
    "codelists/user-elsie_horne-hrt_dmd.csv",
    system="snomed",
    column="dmd_id",
)

#GI outcomes 
'''
This script reads in the codelists from codelists.txt file and generate 
the python code similar to the code above automatically! '''

with open("codelists/codelists.txt") as f: 
    lines = f.readlines()
#parsing the lines which comes after the line '#GI'
start_index = lines.index('#GI\n')
s = ''
for i in range(start_index + 1 , len(lines)):
    if not lines[i].startswith("#"):
        var = lines[i].rstrip().split("/")[1].replace("-","_")
        column = "code"
        if lines[i].startswith("opensafely"):
            path = "codelists/opensafely-" + lines[i].rstrip().split("/")[1] + ".csv"
        elif lines[i].startswith("bristol"):
            path = "codelists/bristol-" + lines[i].rstrip().split("/")[1] + ".csv"
        if ("snomed" in var):
            sys = "snomed"
        elif ("icd" in var): 
            sys = "icd10"
        elif ("bnf" in var): 
            sys = "snomed"
            #get path from local_codelists folder for dmd codes
            path = glob.glob("local_codelists/bristol-"+lines[i].rstrip().split("/")[1]+"*dmd.csv")[0]
            column = "dmd_id"
        elif ("opcs4" in var):
            sys = "opcs4"
        if var.startswith("systolic_blood_pressure"): 
            sys = "snomed"
        if var.startswith("hazardous"): 
            sys = "ctv3"
        s += var + " = codelist_from_csv('" + path + "' , system = '" + sys + "' , column = '"+ column + "' )\n"

'''
Output s for testing 
print (s)
abdominal_distension_snomed = codelist_from_csv('codelists/bristol-abdominal-distension-snomed.csv' , system = 'snomed' , column = 'code' )
abdominal_distension_icd10 = codelist_from_csv('codelists/bristol-abdominal-distension-icd10.csv' , system = 'icd10' , column = 'code' )
abdominal_paindiscomfort_icd10 = codelist_from_csv('codelists/bristol-abdominal-paindiscomfort-icd10.csv' , system = 'icd10' , column = 'code' )
abdominal_paindiscomfort_snomed = codelist_from_csv('codelists/bristol-abdominal-paindiscomfort-snomed.csv' , system = 'snomed' , column = 'code' )
belching_icd10 = codelist_from_csv('codelists/bristol-belching-icd10.csv' , system = 'icd10' , column = 'code' )
belching_snomed = codelist_from_csv('codelists/bristol-belching-snomed.csv' , system = 'snomed' , column = 'code' )
bloody_stools_icd10 = codelist_from_csv('codelists/bristol-bloody-stools-icd10.csv' , system = 'icd10' , column = 'code' )
bloody_stools_snomed = codelist_from_csv('codelists/bristol-bloody-stools-snomed.csv' , system = 'snomed' , column = 'code' )
bowel_ischaemia_icd10 = codelist_from_csv('codelists/bristol-bowel-ischaemia-icd10.csv' , system = 'icd10' , column = 'code' )
bowel_ischaemia_snomed = codelist_from_csv('codelists/bristol-bowel-ischaemia-snomed.csv' , system = 'snomed' , column = 'code' )
diarrhoea_icd10 = codelist_from_csv('codelists/bristol-diarrhoea-icd10.csv' , system = 'icd10' , column = 'code' )
diarrhoea_snomed = codelist_from_csv('codelists/bristol-diarrhoea-snomed.csv' , system = 'snomed' , column = 'code' )
ibs_icd10 = codelist_from_csv('codelists/bristol-ibs-icd10.csv' , system = 'icd10' , column = 'code' )
ibs_snomed = codelist_from_csv('codelists/bristol-ibs-snomed.csv' , system = 'snomed' , column = 'code' )
intestinal_obstruction_icd10 = codelist_from_csv('codelists/bristol-intestinal-obstruction-icd10.csv' , system = 'icd10' , column = 'code' )
intestinal_obstruction_snomed = codelist_from_csv('codelists/bristol-intestinal-obstruction-snomed.csv' , system = 'snomed' , column = 'code' )
nausea_icd10 = codelist_from_csv('codelists/bristol-nausea-icd10.csv' , system = 'icd10' , column = 'code' )
nausea_snomed = codelist_from_csv('codelists/bristol-nausea-snomed.csv' , system = 'snomed' , column = 'code' )
vomiting_snomed = codelist_from_csv('codelists/bristol-vomiting-snomed.csv' , system = 'snomed' , column = 'code' )
vomiting_icd10 = codelist_from_csv('codelists/bristol-vomiting-icd10.csv' , system = 'icd10' , column = 'code' )
cirrhosis_icd10 = codelist_from_csv('codelists/bristol-cirrhosis-icd10.csv' , system = 'icd10' , column = 'code' )
cirrhosis_snomed = codelist_from_csv('codelists/bristol-cirrhosis-snomed.csv' , system = 'snomed' , column = 'code' )
coeliac_disease_snomed = codelist_from_csv('codelists/bristol-coeliac-disease-snomed.csv' , system = 'snomed' , column = 'code' )
coeliac_disease_icd10 = codelist_from_csv('codelists/bristol-coeliac-disease-icd10.csv' , system = 'icd10' , column = 'code' )
crohn_icd10 = codelist_from_csv('codelists/bristol-crohn-icd10.csv' , system = 'icd10' , column = 'code' )
crohn_snomed = codelist_from_csv('codelists/bristol-crohn-snomed.csv' , system = 'snomed' , column = 'code' )
appendicitis_snomed = codelist_from_csv('codelists/bristol-appendicitis-snomed.csv' , system = 'snomed' , column = 'code' )
appendicitis_icd10 = codelist_from_csv('codelists/bristol-appendicitis-icd10.csv' , system = 'icd10' , column = 'code' )
gallstones_disease_snomed = codelist_from_csv('codelists/bristol-gallstones-disease-snomed.csv' , system = 'snomed' , column = 'code' )
gallstones_disease_icd10 = codelist_from_csv('codelists/bristol-gallstones-disease-icd10.csv' , system = 'icd10' , column = 'code' )
nonalcoholic_steatohepatitis_snomed = codelist_from_csv('codelists/bristol-nonalcoholic-steatohepatitis-snomed.csv' , system = 'snomed' , column = 'code' )
nonalcoholic_steatohepatitis_icd10 = codelist_from_csv('codelists/bristol-nonalcoholic-steatohepatitis-icd10.csv' , system = 'icd10' , column = 'code' )
acute_pancreatitis_snomed = codelist_from_csv('codelists/bristol-acute-pancreatitis-snomed.csv' , system = 'snomed' , column = 'code' )
acute_pancreatitis_icd10 = codelist_from_csv('codelists/bristol-acute-pancreatitis-icd10.csv' , system = 'icd10' , column = 'code' )
gastro_oesophageal_reflux_disease_snomed = codelist_from_csv('codelists/bristol-gastro-oesophageal-reflux-disease-snomed.csv' , system = 'snomed' , column = 'code' )
gastro_oesophageal_reflux_disease_icd10 = codelist_from_csv('codelists/bristol-gastro-oesophageal-reflux-disease-icd10.csv' , system = 'icd10' , column = 'code' )
dyspepsia_snomed = codelist_from_csv('codelists/bristol-dyspepsia-snomed.csv' , system = 'snomed' , column = 'code' )
dyspepsia_icd10 = codelist_from_csv('codelists/bristol-dyspepsia-icd10.csv' , system = 'icd10' , column = 'code' )
peptic_ulcer_snomed = codelist_from_csv('codelists/bristol-peptic-ulcer-snomed.csv' , system = 'snomed' , column = 'code' )
peptic_ulcer_icd10 = codelist_from_csv('codelists/bristol-peptic-ulcer-icd10.csv' , system = 'icd10' , column = 'code' )
upper_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-upper-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
upper_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-upper-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
lower_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-lower-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
lower_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-lower-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
variceal_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-variceal-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
variceal_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-variceal-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
nonvariceal_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-nonvariceal-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
nonvariceal_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-nonvariceal-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
alcohol_snomed = codelist_from_csv('codelists/bristol-alcohol-snomed.csv' , system = 'snomed' , column = 'code' )
hazardous_alcohol_drinking = codelist_from_csv('codelists/opensafely-hazardous-alcohol-drinking.csv' , system = 'ctv3' , column = 'code' )
systolic_blood_pressure_qof = codelist_from_csv('codelists/opensafely-systolic-blood-pressure-qof.csv' , system = 'snomed' , column = 'code' )
diastolic_blood_pressure_snomed = codelist_from_csv('codelists/bristol-diastolic-blood-pressure-snomed.csv' , system = 'snomed' , column = 'code' )
hdl_cholesterol = codelist_from_csv('codelists/bristol-hdl-cholesterol.csv' , system = 'snomed' , column = 'code' )
crp_snomed = codelist_from_csv('codelists/bristol-crp-snomed.csv' , system = 'snomed' , column = 'code' )
hypercalcemia_snomed = codelist_from_csv('codelists/bristol-hypercalcemia-snomed.csv' , system = 'snomed' , column = 'code' )
hypertriglyceridemia_snomed = codelist_from_csv('codelists/bristol-hypertriglyceridemia-snomed.csv' , system = 'snomed' , column = 'code' )
cholelisthiasis_snomed = codelist_from_csv('codelists/bristol-cholelisthiasis-snomed.csv' , system = 'snomed' , column = 'code' )
cholelisthiasis_icd10 = codelist_from_csv('codelists/bristol-cholelisthiasis-icd10.csv' , system = 'icd10' , column = 'code' )
history_of_oesophagus = codelist_from_csv('codelists/bristol-history-of-oesophagus.csv' , system = 'icd10' , column = 'code' )
history_of_stomach_and_duodenum_diseases_snomed = codelist_from_csv('codelists/bristol-history-of-stomach-and-duodenum-diseases-snomed.csv' , system = 'snomed' , column = 'code' )
history_of_small_bowel_and_colon_diseases_snomed = codelist_from_csv('codelists/bristol-history-of-small-bowel-and-colon-diseases-snomed.csv' , system = 'snomed' , column = 'code' )
history_of_liver_disease = codelist_from_csv('codelists/bristol-history-of-liver-disease.csv' , system = 'snomed' , column = 'code' )
history_of_pancreas_diseases_snomed = codelist_from_csv('codelists/bristol-history-of-pancreas-diseases-snomed.csv' , system = 'snomed' , column = 'code' )
h_pylori_infection_snomed = codelist_from_csv('codelists/bristol-h-pylori-infection-snomed.csv' , system = 'snomed' , column = 'code' )
h_pylori_infection_icd10 = codelist_from_csv('codelists/bristol-h-pylori-infection-icd10.csv' , system = 'icd10' , column = 'code' )
gi_operations_opcs4 = codelist_from_csv('codelists/bristol-gi-operations-opcs4.csv' , system = 'opcs4' , column = 'code' )
abdominal_distension_snomed = codelist_from_csv('codelists/bristol-abdominal-distension-snomed.csv' , system = 'snomed' , column = 'code' )
abdominal_distension_icd10 = codelist_from_csv('codelists/bristol-abdominal-distension-icd10.csv' , system = 'icd10' , column = 'code' )
abdominal_paindiscomfort_icd10 = codelist_from_csv('codelists/bristol-abdominal-paindiscomfort-icd10.csv' , system = 'icd10' , column = 'code' )
abdominal_paindiscomfort_snomed = codelist_from_csv('codelists/bristol-abdominal-paindiscomfort-snomed.csv' , system = 'snomed' , column = 'code' )
belching_icd10 = codelist_from_csv('codelists/bristol-belching-icd10.csv' , system = 'icd10' , column = 'code' )
belching_snomed = codelist_from_csv('codelists/bristol-belching-snomed.csv' , system = 'snomed' , column = 'code' )
bloody_stools_icd10 = codelist_from_csv('codelists/bristol-bloody-stools-icd10.csv' , system = 'icd10' , column = 'code' )
bloody_stools_snomed = codelist_from_csv('codelists/bristol-bloody-stools-snomed.csv' , system = 'snomed' , column = 'code' )
bowel_ischaemia_icd10 = codelist_from_csv('codelists/bristol-bowel-ischaemia-icd10.csv' , system = 'icd10' , column = 'code' )
bowel_ischaemia_snomed = codelist_from_csv('codelists/bristol-bowel-ischaemia-snomed.csv' , system = 'snomed' , column = 'code' )
diarrhoea_icd10 = codelist_from_csv('codelists/bristol-diarrhoea-icd10.csv' , system = 'icd10' , column = 'code' )
diarrhoea_snomed = codelist_from_csv('codelists/bristol-diarrhoea-snomed.csv' , system = 'snomed' , column = 'code' )
ibs_icd10 = codelist_from_csv('codelists/bristol-ibs-icd10.csv' , system = 'icd10' , column = 'code' )
ibs_snomed = codelist_from_csv('codelists/bristol-ibs-snomed.csv' , system = 'snomed' , column = 'code' )
intestinal_obstruction_icd10 = codelist_from_csv('codelists/bristol-intestinal-obstruction-icd10.csv' , system = 'icd10' , column = 'code' )
intestinal_obstruction_snomed = codelist_from_csv('codelists/bristol-intestinal-obstruction-snomed.csv' , system = 'snomed' , column = 'code' )
nausea_icd10 = codelist_from_csv('codelists/bristol-nausea-icd10.csv' , system = 'icd10' , column = 'code' )
nausea_snomed = codelist_from_csv('codelists/bristol-nausea-snomed.csv' , system = 'snomed' , column = 'code' )
vomiting_snomed = codelist_from_csv('codelists/bristol-vomiting-snomed.csv' , system = 'snomed' , column = 'code' )
vomiting_icd10 = codelist_from_csv('codelists/bristol-vomiting-icd10.csv' , system = 'icd10' , column = 'code' )
cirrhosis_icd10 = codelist_from_csv('codelists/bristol-cirrhosis-icd10.csv' , system = 'icd10' , column = 'code' )
cirrhosis_snomed = codelist_from_csv('codelists/bristol-cirrhosis-snomed.csv' , system = 'snomed' , column = 'code' )
coeliac_disease_snomed = codelist_from_csv('codelists/bristol-coeliac-disease-snomed.csv' , system = 'snomed' , column = 'code' )
coeliac_disease_icd10 = codelist_from_csv('codelists/bristol-coeliac-disease-icd10.csv' , system = 'icd10' , column = 'code' )
crohn_icd10 = codelist_from_csv('codelists/bristol-crohn-icd10.csv' , system = 'icd10' , column = 'code' )
crohn_snomed = codelist_from_csv('codelists/bristol-crohn-snomed.csv' , system = 'snomed' , column = 'code' )
appendicitis_snomed = codelist_from_csv('codelists/bristol-appendicitis-snomed.csv' , system = 'snomed' , column = 'code' )
appendicitis_icd10 = codelist_from_csv('codelists/bristol-appendicitis-icd10.csv' , system = 'icd10' , column = 'code' )
gallstones_disease_snomed = codelist_from_csv('codelists/bristol-gallstones-disease-snomed.csv' , system = 'snomed' , column = 'code' )
gallstones_disease_icd10 = codelist_from_csv('codelists/bristol-gallstones-disease-icd10.csv' , system = 'icd10' , column = 'code' )
nonalcoholic_steatohepatitis_snomed = codelist_from_csv('codelists/bristol-nonalcoholic-steatohepatitis-snomed.csv' , system = 'snomed' , column = 'code' )
nonalcoholic_steatohepatitis_icd10 = codelist_from_csv('codelists/bristol-nonalcoholic-steatohepatitis-icd10.csv' , system = 'icd10' , column = 'code' )
acute_pancreatitis_snomed = codelist_from_csv('codelists/bristol-acute-pancreatitis-snomed.csv' , system = 'snomed' , column = 'code' )
acute_pancreatitis_icd10 = codelist_from_csv('codelists/bristol-acute-pancreatitis-icd10.csv' , system = 'icd10' , column = 'code' )
gastro_oesophageal_reflux_disease_snomed = codelist_from_csv('codelists/bristol-gastro-oesophageal-reflux-disease-snomed.csv' , system = 'snomed' , column = 'code' )
gastro_oesophageal_reflux_disease_icd10 = codelist_from_csv('codelists/bristol-gastro-oesophageal-reflux-disease-icd10.csv' , system = 'icd10' , column = 'code' )
dyspepsia_snomed = codelist_from_csv('codelists/bristol-dyspepsia-snomed.csv' , system = 'snomed' , column = 'code' )
dyspepsia_icd10 = codelist_from_csv('codelists/bristol-dyspepsia-icd10.csv' , system = 'icd10' , column = 'code' )
peptic_ulcer_snomed = codelist_from_csv('codelists/bristol-peptic-ulcer-snomed.csv' , system = 'snomed' , column = 'code' )
peptic_ulcer_icd10 = codelist_from_csv('codelists/bristol-peptic-ulcer-icd10.csv' , system = 'icd10' , column = 'code' )
upper_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-upper-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
upper_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-upper-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
lower_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-lower-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
lower_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-lower-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
variceal_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-variceal-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
variceal_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-variceal-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
nonvariceal_gi_bleeding_icd10 = codelist_from_csv('codelists/bristol-nonvariceal-gi-bleeding-icd10.csv' , system = 'icd10' , column = 'code' )
nonvariceal_gi_bleeding_snomed = codelist_from_csv('codelists/bristol-nonvariceal-gi-bleeding-snomed.csv' , system = 'snomed' , column = 'code' )
alcohol_snomed = codelist_from_csv('codelists/bristol-alcohol-snomed.csv' , system = 'snomed' , column = 'code' )
hazardous_alcohol_drinking = codelist_from_csv('codelists/opensafely-hazardous-alcohol-drinking.csv' , system = 'ctv3' , column = 'code' )
systolic_blood_pressure_qof = codelist_from_csv('codelists/opensafely-systolic-blood-pressure-qof.csv' , system = 'snomed' , column = 'code' )
diastolic_blood_pressure_snomed = codelist_from_csv('codelists/bristol-diastolic-blood-pressure-snomed.csv' , system = 'snomed' , column = 'code' )
hdl_cholesterol = codelist_from_csv('codelists/bristol-hdl-cholesterol.csv' , system = 'snomed' , column = 'code' )
crp_snomed = codelist_from_csv('codelists/bristol-crp-snomed.csv' , system = 'snomed' , column = 'code' )
hypercalcemia_snomed = codelist_from_csv('codelists/bristol-hypercalcemia-snomed.csv' , system = 'snomed' , column = 'code' )
hypertriglyceridemia_snomed = codelist_from_csv('codelists/bristol-hypertriglyceridemia-snomed.csv' , system = 'snomed' , column = 'code' )
cholelisthiasis_snomed = codelist_from_csv('codelists/bristol-cholelisthiasis-snomed.csv' , system = 'snomed' , column = 'code' )
cholelisthiasis_icd10 = codelist_from_csv('codelists/bristol-cholelisthiasis-icd10.csv' , system = 'icd10' , column = 'code' )
history_of_oesophagus = codelist_from_csv('codelists/bristol-history-of-oesophagus.csv' , system = 'icd10' , column = 'code' )
history_of_stomach_and_duodenum_diseases_snomed = codelist_from_csv('codelists/bristol-history-of-stomach-and-duodenum-diseases-snomed.csv' , system = 'snomed' , column = 'code' )
history_of_small_bowel_and_colon_diseases_snomed = codelist_from_csv('codelists/bristol-history-of-small-bowel-and-colon-diseases-snomed.csv' , system = 'snomed' , column = 'code' )
history_of_liver_disease = codelist_from_csv('codelists/bristol-history-of-liver-disease.csv' , system = 'snomed' , column = 'code' )
history_of_pancreas_diseases_snomed = codelist_from_csv('codelists/bristol-history-of-pancreas-diseases-snomed.csv' , system = 'snomed' , column = 'code' )
h_pylori_infection_snomed = codelist_from_csv('codelists/bristol-h-pylori-infection-snomed.csv' , system = 'snomed' , column = 'code' )
h_pylori_infection_icd10 = codelist_from_csv('codelists/bristol-h-pylori-infection-icd10.csv' , system = 'icd10' , column = 'code' )
gi_operations_opcs4 = codelist_from_csv('codelists/bristol-gi-operations-opcs4.csv' , system = 'opcs4' , column = 'code' )
nsaids_bnf = codelist_from_csv('local_codelists/bristol-nsaids-bnf-05cea500-dmd.csv' , system = 'snomed' , column = 'dmd_id' )
aspirin_bnf = codelist_from_csv('local_codelists/bristol-aspirin-bnf-6cbf31ca-dmd.csv' , system = 'snomed' , column = 'dmd_id' )
anticoagulants_bnf = codelist_from_csv('local_codelists/bristol-anticoagulants-bnf-1099a4d8-dmd.csv' , system = 'snomed' , column = 'dmd_id' )
antidepressants_bnf = codelist_from_csv('local_codelists/bristol-antidepressants-bnf-7a3cf198-dmd.csv' , system = 'snomed' , column = 'dmd_id' )
'''
exec(s)


    


            
        