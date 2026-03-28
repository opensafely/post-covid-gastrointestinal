# CREATE COMBINED (3 COHORT) TABLE 1A FOR POST-COVID MANUSCRIPTS

###############################################
# 0. Load relevant libraries and read in data #
###############################################

library(readr)
library(dplyr)
library(data.table)
library(tidyverse)
library(flextable)
library(officer)
library(scales)

#Directories

# results_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Day0/tables/table1/"
results_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/death_fix20240305/"
results_dir<- "output/tables/"
###############################################
# 1. CLEAN TABLE 1 FUNCTION
###############################################
clean_table_1 <- function(df) {

  df <- df %>%
    rename('N (%)' = "N.....derived",
           'COVID-19 diagnoses' = "COVID.19.diagnoses.midpoint6") %>%
    mutate(`COVID-19 diagnoses` = readr::parse_number(as.character(`COVID-19 diagnoses`))) %>%

    mutate(
      `COVID-19 diagnoses` = ifelse(
        is.na(`COVID-19 diagnoses`) |
          is.na(`COVID-19 diagnoses`[1]) |
          `COVID-19 diagnoses`[1] == 0,
        NA_character_,
        paste0(
          scales::comma(`COVID-19 diagnoses`),
          " (",
          round(100 * `COVID-19 diagnoses` / `COVID-19 diagnoses`[1], 1),
          "%)"
        )
      )
    ) %>%
    select(Characteristic, Subcharacteristic, `N (%)`, `COVID-19 diagnoses`)

}

# Read datasets before preprocessing
dataset_names <- c("prevax", "vax", "unvax")
#Load datasets as list
df_list_t1 <- lapply(dataset_names, function(name) read.csv(paste0(results_dir, "table1_", name, "_midpoint6.csv")))

df_list_t1 <- lapply(df_list_t1, function(df){

  total_col <- "N.....derived"
  covid_col <- "COVID.19.diagnoses.midpoint6"

  # Extract total N
  total <- readr::parse_number(as.character(df[[total_col]]))
  covid <- readr::parse_number(as.character(df[[covid_col]]))

  noncovid <- total - covid

  total_noncovid <- noncovid[1]
  total_covid <- covid[1]

  # Non-COVID column (replace N.....derived)
  df[[total_col]] <- paste0(
    scales::comma(noncovid),
    " (",
    round(100 * noncovid / total_noncovid,1),
    "%)"
  )

  # COVID column → convert to N (%)
  df[[covid_col]] <- covid

  df
})

#Apply clean table 1 function
table1 <- lapply(df_list_t1, clean_table_1) %>% 
  #Combine tables into 1
  bind_cols() %>%
  #remove repeated columns: Characteristics and sub-characteristics from vax and unvax
  select(-c(5:6, 9:10),)

#Format table for Word
table1_format <- table1 %>%
  flextable::flextable() %>% theme_vanilla() %>% #theme could be removed
  padding(padding = 0, part = "all") %>% 
  merge_v(~ Characteristic...1) %>%
  set_header_labels('Characteristic...1' = 'Characteristic', "Subcharacteristic...2" = "", 'N (%)...3' = 'N (%)', 'COVID-19 diagnoses...4' = 'COVID-19 diagnoses', 'N (%)...5' = 'N (%)', 'COVID-19 diagnoses...6' = 'COVID-19 diagnoses', 
                    'N (%)...7' = 'N (%)', 'COVID-19 diagnoses...8' = 'COVID-19 diagnoses', 'N (%)...11' = 'N (%)', 'COVID-19 diagnoses...12' = 'COVID-19 diagnoses') %>%
  add_header_row(values = c("", "", "Pre-vaccination cohort (Jan 1 2020 to Dec 14 2021)", "", "Vaccinated cohort (June 1 to Dec 14 2021)", "", "Unvaccinated cohort (June 1 to Dec 14 2021)", "")) %>%
  set_caption(as_paragraph(as_chunk("Table 1: Patient characteristics in the pre-vaccination, vaccinated and unvaccinated cohorts.", props = fp_text_default(bold = TRUE))),
              align_with_table = F) %>%
  bold(j = 1, bold = TRUE, part = "body") %>%
  align(j = c(3:8), align = "right", part = "body") %>%
  fontsize(size = 9)

# Set table 1 properties 
sect_properties <- prop_section(
  page_size = page_size(orient = "landscape",
                        width = 8.3, height = 11.7), 
  type = "continuous", 
  page_margins = page_mar()
)

#Save table 1
save_as_docx(table1_format, path = paste0(results_dir, "table1_formatted.docx"), pr_section = sect_properties)

#Notes 
#While using word:
#1. Change margins to narrow.
#2. Merge vertically Characteristics and Sub characteristics with the upper cell, respectively.
#3. Merge horizontally Pre-vaccination, vaccionation and unvaccinated with the right cell, respectivelly.
#4. IF theme_vanilla is not used, you will need to add borders between each covariate, or remove unnecessary lines.
#5. Change font, CVD uses "Calibri".
