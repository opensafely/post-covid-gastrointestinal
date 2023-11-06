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
    column="code",
)
hrt_dmd = codelist_from_csv(
    "codelists/user-elsie_horne-hrt_dmd.csv",
    system="snomed",
    column="code",
)
# ATE VTE codes
pe_snomed_clinical = codelist_from_csv(
    "codelists/user-elsie_horne-pe_snomed.csv",
    system="snomed",
    column="code",
)
other_dvt_icd10 = codelist_from_csv(
    "codelists/user-elsie_horne-other_dvt_icd10.csv",
    system="icd10",
    column="code",
)


portal_vein_thrombosis_icd10 = codelist_from_csv(
    "codelists/user-elsie_horne-portal_vein_thrombosis_icd10.csv",
    system="icd10",
    column="code",
)
dvt_dvt_icd10 = codelist_from_csv(
    "codelists/user-RochelleKnight-dvt_dvt_icd10.csv",
    system="icd10",
    column="code",
)

pe_icd10 = codelist_from_csv(
    "codelists/user-RochelleKnight-pe_icd10.csv",
    system="icd10",
    column="code",
)
dvt_icvt_icd10 = codelist_from_csv(
    "codelists/user-elsie_horne-dvt_icvt_icd10.csv",
    system="icd10",
    column="code",
)
# DVT
dvt_dvt_snomed_clinical = codelist_from_csv(
    "codelists/user-tomsrenin-dvt_main.csv",
    system="snomed",
    column="code",
)

# ICVT
dvt_icvt_snomed_clinical = codelist_from_csv(
    "codelists/user-tomsrenin-dvt_icvt.csv",
    system="snomed",
    column="code",
)

# Portal vein thrombosis
portal_vein_thrombosis_snomed_clinical = codelist_from_csv(
    "codelists/user-tomsrenin-pvt.csv",
    system="snomed",
    column="code",
)

ami_snomed_clinical = codelist_from_csv(
    "codelists/user-elsie_horne-ami_snomed.csv",
    system="snomed",
    column="code",
)

ami_icd10 = codelist_from_csv(
    "codelists/user-RochelleKnight-ami_icd10.csv",
    system="icd10",
    column="code",
)
# Other DVT
other_dvt_snomed_clinical = codelist_from_csv(
    "codelists/user-tomsrenin-dvt-other.csv",
    system="snomed",
    column="code",
)
# Other arterial embolism
other_arterial_embolism_snomed_clinical = codelist_from_csv(
    "codelists/user-tomsrenin-other_art_embol.csv",
    system="snomed",
    column="code",
)
stroke_isch_icd10 = codelist_from_csv(
    "codelists/user-RochelleKnight-stroke_isch_icd10.csv",
    system="icd10",
    column="code",
)

stroke_isch_snomed_clinical = codelist_from_csv(
    "codelists/user-elsie_horne-stroke_isch_snomed.csv",
    system="snomed",
    column="code",
)
other_arterial_embolism_icd10 = codelist_from_csv(
    "codelists/user-elsie_horne-other_arterial_embolism_icd10.csv",
    system="icd10",
    column="code",
)


# All VTE in SNOMED
all_vte_codes_snomed_clinical = combine_codelists(
    portal_vein_thrombosis_snomed_clinical, 
    dvt_dvt_snomed_clinical, 
    dvt_icvt_snomed_clinical, 
    other_dvt_snomed_clinical, 
    pe_snomed_clinical
)

# All VTE in ICD10
all_vte_codes_icd10 = combine_codelists(
    portal_vein_thrombosis_icd10, 
    dvt_dvt_icd10, 
    dvt_icvt_icd10, 
    other_dvt_icd10,  
    pe_icd10
)

# All ATE in SNOMED
all_ate_codes_snomed_clinical = combine_codelists(
    ami_snomed_clinical, 
    other_arterial_embolism_snomed_clinical, 
    stroke_isch_snomed_clinical
)

# All ATE in ICD10
all_ate_codes_icd10 = combine_codelists(
    ami_icd10, 
    other_arterial_embolism_icd10, 
    stroke_isch_icd10
)
#GI outcomes 
# Blood pressure
systolic_blood_pressure_codes = codelist(
    ["2469."],
    system="ctv3",)
diastolic_blood_pressure_codes = codelist(
    ["246A."],
    system="ctv3")

# # HYpertension
# hypertension_icd10 = codelist_from_csv(
#     "codelists/user-elsie_horne-hypertension_icd10.csv",
#     system="icd10",
#     column="code",
# )
# hypertension_drugs_dmd = codelist_from_csv(
#     "codelists/user-elsie_horne-hypertension_drugs_dmd.csv",
#     system="snomed",
#     column="dmd_id",
# )
# hypertension_snomed_clinical = codelist_from_csv(
#     "codelists/nhsd-primary-care-domain-refsets-hyp_cod.csv",
#     system="snomed",
#     column="code",
# )
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


exec(s)


    


            
        