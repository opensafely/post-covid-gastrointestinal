###############################################
# CREATE COMBINED (3 COHORT) TABLE 1A
###############################################

library(readr)
library(dplyr)
library(data.table)
library(tidyverse)
library(flextable)
library(officer)
library(scales)

###############################################
# Directory
###############################################

results_dir <- "output/tables/"

###############################################
# CLEAN TABLE FUNCTION
###############################################

clean_table_1 <- function(df){

  df <- df %>%
    select(
      Characteristic...1,
      Subcharacteristic...2,
      `COVID-19 N (%)`,
      `Non-COVID-19 N (%)`
    ) %>%
    rename(
      `COVID-19 diagnoses` = `COVID-19 N (%)`,
      `Non-COVID-19 diagnoses` = `Non-COVID-19 N (%)`
    )

}

###############################################
# READ DATASETS
###############################################

dataset_names <- c("prevax","vax","unvax")

df_list_t1 <- lapply(dataset_names,function(name){
  read.csv(paste0(results_dir,"table1_",name,"_midpoint6.csv"))
})

###############################################
# CREATE NON-COVID AND PERCENTAGES
###############################################

df_list_t1 <- lapply(df_list_t1,function(df){

  total_col   <- grep("N.*derived",colnames(df),value=TRUE)
  exposed_col <- grep("^COVID",colnames(df),value=TRUE)[1]

  total   <- as.integer(sub(" .*","",df[[total_col]]))
  exposed <- as.integer(df[[exposed_col]])

  unexposed <- total - exposed

  total_exposed   <- exposed[1]
  total_unexposed <- unexposed[1]

  df$`COVID-19 N (%)` <- ifelse(
    is.na(exposed),
    NA,
    paste0(
      scales::comma(exposed),
      " (",
      round(100*exposed/total_exposed,1),
      "%)"
    )
  )

  df$`Non-COVID-19 N (%)` <- ifelse(
    is.na(unexposed),
    NA,
    paste0(
      scales::comma(unexposed),
      " (",
      round(100*unexposed/total_unexposed,1),
      "%)"
    )
  )

  df
})

###############################################
# CLEAN TABLES
###############################################

table1 <- lapply(df_list_t1,clean_table_1) %>%
  bind_cols()

###############################################
# REMOVE DUPLICATE CHARACTERISTIC COLUMNS
###############################################

table1 <- table1 %>%
  select(
    Characteristic...1,
    Subcharacteristic...2,
    everything(),
    -c(5,6,9,10)
  )

###############################################
# FORMAT TABLE
###############################################

table1_format <- table1 %>%
  flextable() %>%
  theme_vanilla() %>%
  padding(padding=0,part="all") %>%
  merge_v(~Characteristic...1) %>%
  set_header_labels(
    'Characteristic...1'='Characteristic',
    'Subcharacteristic...2'='',
    'COVID-19 diagnoses...3'='COVID-19',
    'Non-COVID-19 diagnoses...4'='Non-COVID-19',
    'COVID-19 diagnoses...5'='COVID-19',
    'Non-COVID-19 diagnoses...6'='Non-COVID-19',
    'COVID-19 diagnoses...7'='COVID-19',
    'Non-COVID-19 diagnoses...8'='Non-COVID-19'
  ) %>%
  add_header_row(values=c(
    "",
    "",
    "Pre-vaccination cohort (Jan 1 2020 to Dec 14 2021)",
    "",
    "Vaccinated cohort (June 1 to Dec 14 2021)",
    "",
    "Unvaccinated cohort (June 1 to Dec 14 2021)",
    ""
  )) %>%
  set_caption(
    as_paragraph(
      as_chunk(
        "Table 1: Patient characteristics in the pre-vaccination, vaccinated and unvaccinated cohorts.",
        props=fp_text_default(bold=TRUE)
      )
    ),
    align_with_table=FALSE
  ) %>%
  bold(j=1,bold=TRUE,part="body") %>%
  align(j=3:8,align="right",part="body") %>%
  fontsize(size=9)

###############################################
# PAGE SETTINGS
###############################################

sect_properties <- prop_section(
  page_size=page_size(
    orient="landscape",
    width=8.3,
    height=11.7
  ),
  type="continuous",
  page_margins=page_mar()
)

###############################################
# SAVE
###############################################

save_as_docx(
  table1_format,
  path=paste0(results_dir,"table1_formatted.docx"),
  pr_section=sect_properties
)
###############################################
# Notes
###############################################

# In Word:
# 1. Set margins to narrow
# 2. Merge vertically Characteristics/Subcharacteristics
# 3. Merge horizontally cohort headers
# 4. Ensure borders between covariate blocks
# 5. Use Calibri font if required by journal