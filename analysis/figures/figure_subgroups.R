library(readr)
library(data.table)
library(tidyverse)
library(ggplot2)

# Define results directory
# results_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Extended followup/models/17-05-2023/"
# output_dir <-"/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Extended followup/Figures/"
results_dir <-"/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Day0/models_30_11_2023/"
output_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Day0/figures/"

#################
#1- Get data
#################

# disregard<- str_to_title(c("out_date_bowel_ischaemia", "out_date_intestinal_obstruction", "out_date_nonalcoholic_steatohepatitis", "out_date_variceal_gi_bleeding"))
estimates <-read.csv(paste0(results_dir,"model_output_midpoint6.csv"))%>%
  # Extract outcomes to plot
  # filter(!outcome %in% disregard) %>%
  filter(model=="mdl_max_adj")%>%
  #keep only rows with time points 
  filter(grepl("days\\d+", term))%>%
  # Modify outcome names
  mutate(outcome = str_remove(outcome, "out_date_")) %>%
  mutate(outcome = str_to_title(outcome))

subgroups<- estimates %>% 
  filter(!analysis %in% c("main","sub_covid_nonhospitalised","sub_covid_hospitalised","sub_covid_history","sub_ethnicity_missing"))

generate_analysis_labels <- function(analysis) {
  case_when(
    analysis == "sub_age_18_39"             ~ "Age group: 18-39",
    analysis == "sub_age_40_59"             ~ "Age group: 40-59",
    analysis == "sub_age_60_79"             ~ "Age group: 60-79",
    analysis == "sub_age_80_110"            ~ "Age group: 80-110",
    analysis == "sub_sex_male"              ~ "Sex: Male",
    analysis == "sub_sex_female"            ~ "Sex: Female",
    analysis == "sub_ethnicity_white"       ~ "Ethnicity: White",
    analysis == "sub_ethnicity_black"       ~ "Ethnicity: Black",
    analysis == "sub_ethnicity_asian"       ~ "Ethnicity: Asian",
    analysis == "sub_ethnicity_mixed"       ~ "Ethnicity: Mixed",
    analysis == "sub_ethnicity_other"       ~ "Ethnicity: Other",
    analysis == "sub_priorhistory_true"     ~ "Prior history of GI event",
    analysis == "sub_priorhistory_false"    ~ "No prior history of GI event",
    analysis == "sub_prioroperations_true"  ~ "Prior operations",
    analysis == "sub_prioroperations_false" ~ "No prior operations",
    TRUE                                    ~ NA_character_
  )
}

generate_colour <- function(analysis, df) {
  unique_analysis <- unique(df$analysis)
  unique_colors <- case_when(
    unique_analysis == "sub_age_18_39"             ~ "#0808c9",
    unique_analysis == "sub_age_40_59"             ~ "#0085ff",
    unique_analysis == "sub_age_60_79"             ~ "#00c9df",
    unique_analysis == "sub_age_80_110"            ~ "#73ffa6",
    unique_analysis == "sub_sex_male"              ~ "#cab2d6",
    unique_analysis == "sub_sex_female"            ~ "#6a3d9a",
    unique_analysis == "sub_ethnicity_white"       ~ "#444e86",
    unique_analysis == "sub_ethnicity_black"       ~ "#ff126b",
    unique_analysis == "sub_ethnicity_asian"       ~ "#ff4fae",
    unique_analysis == "sub_ethnicity_other"       ~ "#e97de1",
    unique_analysis == "sub_ethnicity_mixed"       ~ "#c3a1ff",
    unique_analysis == "sub_priorhistory_true"     ~ "#ff7f00",
    unique_analysis == "sub_priorhistory_false"    ~ "#fdbf6f",
    unique_analysis == "sub_prioroperations_true"  ~ "#388E3C",
    unique_analysis == "sub_prioroperations_false" ~ "#8BC34A",
    TRUE                                          ~ NA_character_
  )
  unique_colors[match(analysis, unique_analysis)]
}




generate_grouping <- function(analysis) {
  case_when(
    startsWith(analysis, "sub_priorhistory")     ~ "Prior history of event",
    startsWith(analysis, "sub_prioroperations")  ~ "Prior GI operations",
    startsWith(analysis, "sub_age")              ~ "Age group",
    startsWith(analysis, "sub_sex")              ~ "Sex",
    startsWith(analysis, "sub_ethnicity")        ~ "Ethnicity",
    TRUE                                        ~ ""
  )
}

generate_grouping_labels <- function(grouping, cohort) {
  case_when(
    cohort == "prevax"    ~ paste0(grouping, " - Pre-vaccination"),
    cohort == "vax"       ~ paste0(grouping, " - Vaccinated"),
    cohort == "unvax"     ~ paste0(grouping, " - Unvaccinated"),
    TRUE                 ~ ""
  )
}

subgroups <- subgroups %>%
  group_by(outcome) %>%
  mutate(
    analysis_labels = generate_analysis_labels(analysis),
    colour = generate_colour(analysis, .),  
    grouping = generate_grouping(analysis),
    grouping_labels = generate_grouping_labels(grouping, cohort)
  )


subgroups$grouping_labels <- factor(
  subgroups$grouping_labels,
  levels = c(
    "Age group - Pre-vaccination",
    "Age group - Vaccinated",
    "Age group - Unvaccinated",
    "Ethnicity - Pre-vaccination",
    "Ethnicity - Vaccinated",
    "Ethnicity - Unvaccinated",
    "Prior history of event - Pre-vaccination",
    "Prior history of event - Vaccinated",
    "Prior history of event - Unvaccinated",
    "Prior GI operations - Pre-vaccination",
    "Prior GI operations - Vaccinated",
    "Prior GI operations - Unvaccinated",
    "Sex - Pre-vaccination",
    "Sex - Vaccinated",
    "Sex - Unvaccinated"
  )
)

names <- c(
  `Age group - Pre-vaccination` = "Pre-vaccination",
  `Age group - Vaccinated` = "Vaccinated\nAge group",
  `Age group - Unvaccinated` = "Unvaccinated",
  `Ethnicity - Pre-vaccination` = "",
  `Ethnicity - Vaccinated` = "Ethnicity",
  `Ethnicity - Unvaccinated` = "",
  `Prior history of event - Pre-vaccination` = "",
  `Prior history of event - Vaccinated` = "Prior history of event",
  `Prior history of event - Unvaccinated` = "",
  `Prior GI operations - Pre-vaccination` = "",
  `Prior GI operations - Vaccinated` = "Prior GI operations",
  `Prior GI operations - Unvaccinated` = "",
  `Sex - Pre-vaccination` = "",
  `Sex - Vaccinated` = "Sex",
  `Sex - Unvaccinated` = ""
)

names_2col <- c(
  `Age group - Pre-vaccination` = "Pre-vaccination\nAge group",
  `Age group - Vaccinated` = "Vaccinated",
  `Age group - Unvaccinated` = "Unvaccinated",
  `Ethnicity - Pre-vaccination` = "Ethnicity",
  `Ethnicity - Vaccinated` = "",
  `Ethnicity - Unvaccinated` = "",
  `Prior history of event - Pre-vaccination` = "Prior history of event",
  `Prior history of event - Vaccinated` = "",
  `Prior history of event - Unvaccinated` = "",
  `Prior GI operations - Pre-vaccination` = "Prior GI operations",
  `Prior GI operations - Vaccinated` = "",
  `Prior GI operations - Unvaccinated` = "",
  `Sex - Pre-vaccination` = "Sex",
  `Sex - Vaccinated` = "",
  `Sex - Unvaccinated` = ""
)

for (outcome_name in unique(subgroups$outcome)) {
  
  
  df <- subgroups %>% filter(outcome == outcome_name)
  
  analysis_labels_levels <- unique(df$analysis_labels)
  df$analysis_labels <- factor(df$analysis_labels, levels = analysis_labels_levels)
  
  colour_levels <- unique(df$colour)
  df$colour <- factor(df$colour, levels = colour_levels)
  
  pd <- position_dodge(width = 0.5)
  p <- ggplot(df, aes(x = outcome_time_median / 7, y = hr, color = colour)) +
    geom_line() +
    geom_point(size = 2, position = pd) +
    geom_hline(mapping = aes(yintercept = 1), colour = "#A9A9A9") +
    geom_errorbar(
      size = 1.2,
      mapping = aes(
        ymin = ifelse(conf_low < 0.25, 0.25, conf_low),
        ymax = ifelse(conf_high > 64, 64, conf_high),
        width = 0
      ),
      position = pd
    ) +
    scale_x_continuous(breaks = seq(0, max(df$outcome_time_median) / 7, 4)) +
    scale_y_continuous(
      lim = c(0.25, 512),
      breaks = c(0.25, 0.5, 1, 2, 4, 8, 16, 32, 64,128,256,512),
      trans = "log"
    ) +
    scale_fill_manual(
      values = levels(df$colour),
      labels = levels(df$analysis_labels)
    ) +
    scale_color_manual(
      values = levels(df$colour),
      labels = levels(df$analysis_labels)
    ) +
    scale_shape_manual(
      values = c(rep(15, length(unique(df$analysis)))),
      labels = levels(df$analysis_labels)
    ) +
    labs(x = "\nWeeks since COVID-19 diagnosis", y = "Hazard ratio and 95% confidence interval") +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          panel.spacing.x = unit(0.5, "lines"),
          panel.spacing.y = unit(0, "lines"),
          legend.key = element_rect(colour = NA, fill = NA),
          legend.title = element_blank(),
          legend.position="bottom",
          legend.box ="horizontal",
          legend.spacing.x = unit(0.5, 'cm'),
          strip.text = element_text(face = "bold",size=12),
          plot.background = element_rect(fill = "white", colour = "white"),
          text=element_text(size=13)) +
    guides(color = guide_legend(ncol = 6, byrow = TRUE))
  if (length(unique(df$cohort)) == 2) {
    p <- p + facet_wrap(grouping_labels ~ ., labeller = as_labeller(names_2col), ncol = length(unique(df$cohort)))
  } else {
    p <- p + facet_wrap(grouping_labels ~ ., labeller = as_labeller(names), ncol = length(unique(df$cohort)))
  }
  
  
  
  
  # Get unique colors
  unique_colors <- unique(df$colour)
  
  # Pass unique colors to generate_colour function
  
  df$colour <- generate_colour(df$analysis, df)
  
  ggsave(
    paste0(output_dir, "figure_3",outcome_name, ".png"),
    height = 297, width = 350, unit = "mm", dpi = 600, scale = 1
  )
}

