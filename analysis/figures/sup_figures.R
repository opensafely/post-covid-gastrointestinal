library(readr)
library(dplyr)
library(ggplot2)
library(rlang)

# 0. Define the exact outcome order and pretty labels
outcomes_order <- c(
  "upper_gi_bleeding",
  "lower_gi_bleeding",
  "gastro_oesophageal_reflux_disease",
  "dyspepsia",
  "gallstones_disease",
  "ibs"
)
pretty_outcome <- c(
  upper_gi_bleeding                 = "Upper gastrointestinal bleeding",
  lower_gi_bleeding                 = "Lower gastrointestinal bleeding",
  gastro_oesophageal_reflux_disease = "Gastro-oesophageal reflux",
  dyspepsia                         = "Dyspepsia",
  gallstones_disease                = "Gallstones disease",
  ibs                               = "Irritable bowel syndrome"
)

# 1. Load & basic filter once, and FIX factor order on outcome
df_master <- read_csv("output/plot_model_output.csv", show_col_types = FALSE) %>%
  filter(
    model == "mdl_max_adj",
    grepl("days\\d+", term),
    term != "days0_1",
    outcome %in% outcomes_order
  ) %>%
  mutate_at(vars(hr, conf_low, conf_high, outcome_time_median), as.numeric) %>%
  mutate(
    # ensure correct factor order for rows
    outcome = factor(outcome, levels = outcomes_order)
  )

# 2. Cohort colours & labels (shared)
df_master <- df_master %>%
  mutate(
    colour_cohort = case_when(
      cohort == "prevax" ~ "#d2ac47",
      cohort == "vax"   ~ "#58764c",
      cohort == "unvax" ~ "#0018a8",
      TRUE              ~ "#CCCCCC"
    ),
    cohort = factor(cohort,
                    levels = c("prevax","vax","unvax"),
                    labels = c(
                      "Pre-vaccination\n(Jan 1 2020–Dec 14 2021)",
                      "Vaccinated\n(Jun 1 2021–Dec 14 2021)",
                      "Unvaccinated\n(Jun 1 2021–Dec 14 2021)"
                    )
    )
  )

# 3. Plot function that enforces outcome_order
plot_by_subgroup <- function(df, analysis_codes, subgroup_name, subgroup_labels, filename) {
  df_sub <- df %>%
    filter(analysis %in% analysis_codes) %>%
    mutate(
      # create subgroup factor in the specified order
      !!sym(subgroup_name) := factor(analysis,
                                     levels = analysis_codes,
                                     labels = subgroup_labels),
      !!sym(subgroup_name) := factor(!!sym(subgroup_name), levels = subgroup_labels)
    )
  
  # Build annotation: one row per outcome in the *first* (left) column
  annotation_df <- tibble(
    !!sym(subgroup_name) := subgroup_labels[1],
    outcome = outcomes_order
  ) %>%
    mutate(
      x = 0.5,
      y = 9,
      # map code → pretty label
      label = pretty_outcome[outcome],
      # match factor types for plotting/join
      outcome = factor(outcome, levels = outcomes_order),
      !!sym(subgroup_name) := factor(!!sym(subgroup_name), levels = subgroup_labels)
    )
  
  p <- ggplot(df_sub, aes(
    x = outcome_time_median/7,
    y = hr,
    color = cohort,
    group = cohort
  )) +
    geom_hline(yintercept = 1, colour = "#A9A9A9") +
    geom_line(size = 0.8) +
    geom_point(size = 2, position = position_dodge(0.5)) +
    geom_errorbar(aes(
      ymin = pmax(conf_low, 0.5),
      ymax = pmin(conf_high, 36)
    ),
    width = 0,
    position = position_dodge(0.5),
    size = 1
    ) +
    scale_color_manual(values = c("#d2ac47","#58764c","#0018a8"), name = NULL) +
    scale_x_continuous(breaks = seq(0, max(df_sub$outcome_time_median)/7, by = 8)) +
    scale_y_log10(
      breaks = c(0.5, 1, 2, 4, 8,16,32)
     
    ) +
    labs(x = "Weeks since COVID-19 diagnosis", y = "Hazard ratio (95% CI)") +
    facet_grid(outcome ~ .data[[subgroup_name]], switch = "y") +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor     = element_blank(),
      panel.grid.major.x   = element_blank(),
      strip.text.x         = element_text(face = "bold", size = 11),
      strip.text.y         = element_blank(),
      strip.placement      = "outside",
      axis.text.y.left     = element_text(size = 8),
      axis.text.y.right    = element_blank(),
      axis.ticks.y.right   = element_blank(),
      axis.text.x          = element_text(size = 8),
      legend.position      = "bottom",
      legend.text          = element_text(size = 9),
      plot.background      = element_rect(fill = "white", colour = NA)
    ) +
    geom_text(
      data = annotation_df,
      aes(x = x, y = y, label = label),
      inherit.aes = FALSE,
      hjust = 0, vjust = 1,
      fontface = "bold", size = 4
    )
  
  ggsave(filename, plot = p,
         width  = 300, height = 380,
         units  = "mm", dpi = 600, scale = 0.8)
}

# 4. Generate your subgroup plots

## Sex
plot_by_subgroup(
  df_master,
  analysis_codes  = c("sub_sex_female","sub_sex_male"),
  subgroup_name   = "sex",
  subgroup_labels = c("Sex: Female","Sex: Male"),
  filename        = "output/post_release/figure_sex_16.png"
)

## Age
plot_by_subgroup(
  df_master,
  analysis_codes  = c("sub_age_18_39","sub_age_40_59","sub_age_60_79","sub_age_80_110"),
  subgroup_name   = "age_group",
  subgroup_labels = c("Age: 18–39","Age: 40–59","Age: 60–79","Age: 80–110"),
  filename        = "output/post_release/figure_age_16.png"
)

## Ethnicity (White → Asian only)
plot_by_subgroup(
  df_master,
  analysis_codes  = c("sub_ethnicity_white","sub_ethnicity_asian"),
  subgroup_name   = "ethnicity",
  subgroup_labels = c("Ethnicity: White","Ethnicity: Asian"),
  filename        = "output/post_release/figure_ethnicity_16.png"
)

## Prior history (first column = event)
plot_by_subgroup(
  df_master,
  analysis_codes  = c("sub_priorhistory_true","sub_priorhistory_false"),
  subgroup_name   = "prior_history",
  subgroup_labels = c("Prior gastrointestinal event","No prior gastrointestinal event"),
  filename        = "output/post_release/figure_priorhistory_16.png"
)

## Prior operations
plot_by_subgroup(
  df_master,
  analysis_codes  = c("sub_prioroperations_true","sub_prioroperations_false"),
  subgroup_name   = "prior_ops",
  subgroup_labels = c("Prior gastrointestinal operations","No prior gastrointestinal operations"),
  filename        = "output/post_release/figure_prioroperations_16.png"
)

