# Load libraries ---------------------------------------------------------------
print('Load libraries')

library(magrittr)

# Specify redaction threshold --------------------------------------------------
print('Specify redaction threshold')

threshold <- 6

# Source common functions ------------------------------------------------------
print('Source common functions')

source("analysis/utility.R")

# Specify arguments ------------------------------------------------------------
print('Specify arguments')

args <- commandArgs(trailingOnly=TRUE)

if(length(args)==0){
  cohort <- "vax"
} else {
  cohort <- args[[1]]
}


# Load data --------------------------------------------------------------------
print("Load data")

df <- readr::read_rds(paste0("output/input_",cohort,"_stage1_gi_bleeds.rds"))

# Create exposure indicator ----------------------------------------------------
print("Create exposure indicator")

df$exposed <- !is.na(df$exp_date_covid19_confirmed)

# Define age groups ------------------------------------------------------------
print("Define age groups")

df$cov_cat_age_group <- ""
df$cov_cat_age_group <- ifelse(df$cov_num_age>=18 & df$cov_num_age<=29, "18-29", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=30 & df$cov_num_age<=39, "30-39", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=40 & df$cov_num_age<=49, "40-49", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=50 & df$cov_num_age<=59, "50-59", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=60 & df$cov_num_age<=69, "60-69", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=70 & df$cov_num_age<=79, "70-79", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=80 & df$cov_num_age<=89, "80-89", df$cov_cat_age_group)
df$cov_cat_age_group <- ifelse(df$cov_num_age>=90, "90+", df$cov_cat_age_group)

# Filter data ------------------------------------------------------------------
print("Filter data")

df <- df[,c("patient_id",
            "exposed",
            "cov_cat_sex",
            "cov_cat_age_group",
            "cov_cat_ethnicity",
            "cov_cat_deprivation",
            "cov_cat_smoking_status",
            "cov_cat_region",
            "cov_bin_carehome_status", "out_date_upper_gi_bleeding", 
            "out_date_lower_gi_bleeding","out_date_variceal_gi_bleeding", 
            "out_date_nonvariceal_gi_bleeding")]

# Convert date columns to binary
date_columns <- c("out_date_upper_gi_bleeding", "out_date_lower_gi_bleeding", "out_date_variceal_gi_bleeding", "out_date_nonvariceal_gi_bleeding")
df[date_columns] <- lapply(df[date_columns], function(col) {
  ifelse(!is.na(col), 1, 0)
})


df$All <- "All"


# Aggregate data ---------------------------------------------------------------
print("Aggregate data")

df <- tidyr::pivot_longer(df,
                          cols = setdiff(colnames(df),c("patient_id","exposed","out_date_upper_gi_bleeding", "out_date_lower_gi_bleeding",
                                                        "out_date_variceal_gi_bleeding", "out_date_nonvariceal_gi_bleeding")),
                          names_to = "characteristic",
                          values_to = "subcharacteristic")

df$total <- 1

agg_cols <- c("total", "exposed", "out_date_upper_gi_bleeding", "out_date_lower_gi_bleeding",
              "out_date_variceal_gi_bleeding", "out_date_nonvariceal_gi_bleeding")

df <- aggregate(as.formula(paste0("cbind(", paste(agg_cols, collapse = ","), ") ~ characteristic + subcharacteristic")),
                data = df, 
                sum)

# Tidy care home characteristic ------------------------------------------------
print("Remove extraneous information")

df <- df[!(df$characteristic=="cov_bin_carehome_status" & 
             df$subcharacteristic=="FALSE"),]

df$subcharacteristic <- ifelse(df$characteristic=="cov_bin_carehome_status",
                               "Care home resident",
                               df$subcharacteristic)

# Sort characteristics ---------------------------------------------------------
print("Sort characteristics")

df$characteristic <- factor(df$characteristic,
                            levels = c("All",
                                       "cov_cat_sex",
                                       "cov_cat_age_group",
                                       "cov_cat_ethnicity",
                                       "cov_cat_deprivation",
                                       "cov_cat_smoking_status",
                                       "cov_cat_region",
                                       "cov_bin_carehome_status"),
                            labels = c("All",
                                       "Sex",
                                       "Age, years",
                                       "Ethnicity",
                                       "Index of multuple deprivation quintile",
                                       "Smoking status",
                                       "Region",
                                       "Care home resident"))

# Sort subcharacteristics ------------------------------------------------------
print("Sort subcharacteristics")

df$subcharacteristic <- factor(df$subcharacteristic,
                               levels = c("All",
                                          "Female",
                                          "Male",
                                          "18-29",
                                          "30-39",
                                          "40-49",
                                          "50-59",
                                          "60-69",
                                          "70-79",
                                          "80-89",
                                          "90+",
                                          "White",
                                          "Mixed",
                                          "South Asian",
                                          "Black",
                                          "Other",
                                          "Missing",
                                          "1-2 (most deprived)",
                                          "3-4",
                                          "5-6",
                                          "7-8",
                                          "9-10 (least deprived)",
                                          "Never smoker",
                                          "Ever smoker",
                                          "Current smoker",
                                          "East",
                                          "East Midlands",
                                          "London",
                                          "North East",
                                          "North West",
                                          "South East",
                                          "South West",
                                          "West Midlands",
                                          "Yorkshire and The Humber",
                                          "Care home resident",
                                          "Missing"),
                               labels = c("All",
                                          "Female",
                                          "Male",
                                          "18-29",
                                          "30-39",
                                          "40-49",
                                          "50-59",
                                          "60-69",
                                          "70-79",
                                          "80-89",
                                          "90+",
                                          "White",
                                          "Mixed",
                                          "South Asian",
                                          "Black",
                                          "Other",
                                          "Missing",
                                          "1: most deprived",
                                          "2",
                                          "3",
                                          "4",
                                          "5: least deprived",
                                          "Never smoker",
                                          "Former smoker",
                                          "Current smoker",
                                          "East",
                                          "East Midlands",
                                          "London",
                                          "North East",
                                          "North West",
                                          "South East",
                                          "South West",
                                          "West Midlands",
                                          "Yorkshire/Humber",
                                          "Care home resident",
                                          "Missing"))


# Sort data --------------------------------------------------------------------
print("Sort data")

df <- df[order(df$characteristic, df$subcharacteristic),]

# Save Table 1 -----------------------------------------------------------------
print('Save Table 1')

write.csv(df, paste0("output/table1_gi_bleeds_",cohort,".csv"), row.names = FALSE)

# Perform redaction for the new outcomes
outcomes <- c("out_date_upper_gi_bleeding", "out_date_lower_gi_bleeding", "out_date_variceal_gi_bleeding", "out_date_nonvariceal_gi_bleeding")

df[, outcomes] <- lapply(df[, outcomes], FUN = function(y) { roundmid_any(as.numeric(y), to = threshold) })


# Calculate column percentages for the new outcomes
for (outcome in outcomes) {
  df[, paste0(outcome, "_percent")] <- paste0(df[, outcome], " (", round(100 * (df[, outcome] / df[df$characteristic == "All", "total"]), 1), "%)")
}
# Calculate column percentages -------------------------------------------------
all_total <- df[df$characteristic == "All", "total"][1]

df$Npercent <- paste0(df$total, ifelse(df$characteristic == "All", "",
                                       paste0(" (", round(100 * (df$total / all_total), 1), "%)")))

# Extend the saved rounded table to include new outcomes
df <- df[,c("characteristic","subcharacteristic","Npercent","exposed", outcomes)]

# Rename columns appropriately
new_colnames <- c("Characteristic", "Subcharacteristic", "N (%)", "COVID-19 diagnoses", "Upper GI Bleeding", "Lower GI Bleeding",
                  "Variceal GI Bleeding", "Nonvariceal GI Bleeding")
colnames(df) <- new_colnames

# Save rounded Table 1
write.csv(df, paste0("output/table1_gi_bleeds_", cohort, "_rounded.csv"), row.names = FALSE)






