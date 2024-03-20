####Subgroups figure#####


library(readr)
library(data.table)
library(tidyverse)
library(ggplot2)


#################
#1- Get data
#################
df <- readr::read_csv("output/plot_model_output.csv",
                      show_col_types = FALSE) 
  df<- df %>%
    filter(model == "mdl_max_adj",
           grepl("days\\d+", term),
           term != "days0_1",
           !is.na(hr) & hr != "" & hr != "[redact]")%>%
    filter(!analysis %in% c("main","sub_covid_nonhospitalised","sub_covid_hospitalised","sub_covid_history","sub_ethnicity_missing"))%>% 
    filter(!stringr::str_detect(analysis, "sub_covid_hospitalised"))%>% #remove ac and te subgroups 
    filter(!is.na(outcome_time_median))%>%
    select(cohort, outcome, analysis, term, hr, conf_high, conf_low, outcome_time_median)




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
    analysis == "sub_priorhistory_true"     ~ "Prior history of gastrointestinal event",
    analysis == "sub_priorhistory_false"    ~ "No prior history of gastrointestinal event",
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
    # unique_analysis == "sub_covid_hospitalised_ac_true"     ~ "#2f2f2f", 
    # unique_analysis == "sub_covid_hospitalised_ac_false"    ~ "#bcbcbc", 
    # unique_analysis == "sub_covid_hospitalised_te_true"     ~ "#ffd700", 
    # unique_analysis == "sub_covid_hospitalised_te_false"    ~ "#fffacd", 
    TRUE                                          ~ NA_character_
  )
  unique_colors[match(analysis, unique_analysis)]
}

generate_grouping <- function(analysis) {
  case_when(
    startsWith(analysis, "sub_priorhistory")     ~ "Prior history of event",
    startsWith(analysis, "sub_prioroperations")  ~ "Prior gastrointestinal operations",
    startsWith(analysis, "sub_age")              ~ "Age group",
    startsWith(analysis, "sub_sex")              ~ "Sex",
    startsWith(analysis, "sub_ethnicity")        ~ "Ethnicity",
    # startsWith(analysis, "sub_covid_hospitalised_ac")        ~ "Anticoagulants",
    # startsWith(analysis, "sub_covid_hospitalised_te")        ~ "Thrombotic events",

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

df <- df %>%
  group_by(outcome) %>%
  mutate(
    analysis_labels = generate_analysis_labels(analysis),
    colour = generate_colour(analysis, .),  
    grouping = generate_grouping(analysis),
    grouping_labels = generate_grouping_labels(grouping, cohort)
  )

df$grouping_labels <- factor(
  df$grouping_labels,
  levels = c(
    "Age group - Pre-vaccination",
    "Age group - Vaccinated",
    "Age group - Unvaccinated",
    "Ethnicity - Pre-vaccination",
    "Ethnicity - Vaccinated",
    "Ethnicity - Unvaccinated",
    "Sex - Pre-vaccination",
    "Sex - Vaccinated",
    "Sex - Unvaccinated",
    "Prior history of event - Pre-vaccination",
    "Prior history of event - Vaccinated",
    "Prior history of event - Unvaccinated",
    "Prior gastrointestinal operations - Pre-vaccination",
    "Prior gastrointestinal operations - Vaccinated",
    "Prior gastrointestinal operations - Unvaccinated"
    
    #  "Anticoagulants - Pre-vaccination",
    # "Anticoagulants - Vaccinated",
    # "Anticoagulants - Unvaccinated",
    # "Thrombotic events - Pre-vaccination",
    # "Thrombotic events - Vaccinated",
    # "Thrombotic events - Unvaccinated"
  )
)

names <- c(
  `Age group - Pre-vaccination` = "Pre-vaccination",
  `Age group - Vaccinated` = "Vaccinated\nAge group",
  `Age group - Unvaccinated` = "Unvaccinated",
  `Ethnicity - Pre-vaccination` = "",
  `Ethnicity - Vaccinated` = "Ethnicity",
  `Ethnicity - Unvaccinated` = "",
  `Sex - Pre-vaccination` = "",
  `Sex - Vaccinated` = "Sex",
  `Sex - Unvaccinated` = "",
  `Prior history of event - Pre-vaccination` = "",
  `Prior history of event - Vaccinated` = "Prior history of event",
  `Prior history of event - Unvaccinated` = "",
  `Prior gastrointestinal operations - Pre-vaccination` = "",
  `Prior gastrointestinal operations - Vaccinated` = "Prior gastrointestinal operations",
  `Prior gastrointestinal operations - Unvaccinated` = ""
  
  # `Anticoagulants - Pre-vaccination` = "",
  # `Anticoagulants - Vaccinated` = "Anticoagulants",
  # `Anticoagulants - Unvaccinated` = "",
  # `Thrombotic events - Pre-vaccination` = "",
  # `Thrombotic events - Vaccinated` = "Thrombotic events",
  # `Thrombotic events - Unvaccinated` = ""
)


names_missing_col <- c(
  `Age group - Pre-vaccination` = "Pre-vaccination\nAge group",
  `Age group - Vaccinated` = "Vaccinated",
  `Age group - Unvaccinated` = "Unvaccinated",
  `Ethnicity - Pre-vaccination` = "Ethnicity",
  `Ethnicity - Vaccinated` = "",
  `Ethnicity - Unvaccinated` = "",
  `Sex - Pre-vaccination` = "Sex",
  `Sex - Vaccinated` = "",
  `Sex - Unvaccinated` = "",
  `Prior history of event - Pre-vaccination` = "Prior history of event",
  `Prior history of event - Vaccinated` = "",
  `Prior history of event - Unvaccinated` = "",
  `Prior gastrointestinal operations - Pre-vaccination` = "Prior gastrointestinal operations",
  `Prior gastrointestinal operations - Vaccinated` = "",
  `Prior gastrointestinal operations - Unvaccinated` = ""
  
  
)
for (outcome_name in unique(df$outcome)) {
  
  df_out <- df %>% filter(outcome == outcome_name)
  #acute pancreatitis only have data for unvax cohort for ethnicity white subroup
  #keeping the unvax data for just one group is causing the labels to incorrectly shift and will mess the figure 
  ##TODO find a better solution 
  if(outcome_name == "acute_pancreatitis"){
  df_out <-df_out%>% filter(cohort!="unvax")
  }
  
  analysis_labels_levels <- unique(df_out$analysis_labels)
  analysis_labels_levels<- c("Age group: 18-39","Age group: 40-59","Age group: 60-79","Age group: 80-110" ,
                             "Ethnicity: White" , "Ethnicity: Black",  "Ethnicity: Asian","Ethnicity: Mixed"  ,"Ethnicity: Other",
                             "Prior history of gastrointestinal event" , "No prior history of gastrointestinal event",
                             "Prior operations","No prior operations",
                             "Sex: Female", "Sex: Male"  )
  df_out$analysis_labels <- factor(df_out$analysis_labels, levels = analysis_labels_levels)
  
  colour_levels <- unique(df_out$colour)
  df_out$colour <- factor(df_out$colour, levels = colour_levels)
  #max y vaule and breaks
  max_y_value <- max(ceiling(df_out$conf_high), na.rm = TRUE)
  max_y_break <- 2^(ceiling(log2(max_y_value)))
  # Generate breaks that are powers of 2, up to the next power of 2 above the maximum y value
  y_breaks <- c(0.25, 0.5, 1)
  next_break <- 2
  while (next_break <= max_y_break) {
    y_breaks <- c(y_breaks, next_break)
    next_break <- next_break * 2
  }
  
  pd <- position_dodge(width = 0.5)
  p <- ggplot(df_out, aes(x = outcome_time_median / 7, y = hr, color = colour)) +
    geom_line() +
    geom_point(size = 2, position = pd) +
    geom_hline(mapping = aes(yintercept = 1), colour = "#A9A9A9") +
    geom_errorbar(
      size = 1.2,
      mapping = aes(
        ymin = ifelse(conf_low < 0.25, 0.25, conf_low),
        ymax = ifelse(conf_high > max_y_value, max_y_value, conf_high),
        width = 0
      ),
      position = pd
    ) +
    scale_x_continuous(breaks = seq(0, max(df_out$outcome_time_median) / 7, 4)) +
    scale_y_continuous(
      lim = c(0.25, max_y_value),
      breaks = y_breaks,
      trans = "log"
    ) +
    scale_fill_manual(
      values = levels(df_out$colour),
      labels = levels(df_out$analysis_labels)
    ) +
    scale_color_manual(
      values = levels(df_out$colour),
      labels = levels(df_out$analysis_labels)
    ) +
    scale_shape_manual(
      values = c(rep(15, length(unique(df_out$analysis)))),
      labels = levels(df_out$analysis_labels)
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
    guides(color = guide_legend(ncol = 6,byrow = TRUE))
  if (length(unique(df_out$cohort)) != 3) {
    p <- p + facet_wrap(grouping_labels ~ ., labeller = as_labeller(names_missing_col), ncol = length(unique(df_out$cohort)))
  } else {
    p <- p + facet_wrap(grouping_labels ~ ., labeller = as_labeller(names), ncol = length(unique(df_out$cohort)))
  }
  
  
  # Get unique colors
  unique_colors <- unique(df_out$colour)
  
  # Pass unique colors to generate_colour function
  
  df_out$colour <- generate_colour(df_out$analysis, df_out)
  
  ggsave(
    paste0( "output/post_release/figure_3_",outcome_name, ".png"),
    height = 297, width = 350, unit = "mm", dpi = 600, scale = 1
  )
}




