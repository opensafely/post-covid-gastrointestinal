# TODO tidy the format part 

library(readr)
library(data.table)
library(tidyverse)
library(ggplot2)

# #################
#1- Get data
#################
df <- readr::read_csv("output/plot_model_output.csv",
                      show_col_types = FALSE) 
df <- df[df$outcome %in% c("acute_pancreatitis","peptic_ulcer","nonvariceal_gi_bleeding","appendicitis"),
         c("cohort","analysis","outcome","outcome_time_median","term","hr","conf_low","conf_high","model")]

df <- df%>% filter(model == "mdl_max_adj",
                   grepl("days\\d+", term),
                   term != "days0_1")

# Filter data for the desired analyses
df <- df %>% filter(analysis %in% c("main", "sub_covid_hospitalised", "sub_covid_nonhospitalised")) 
# Set numeric cols to numeric
numeric_cols <- c( "hr", "conf_low", "conf_high", "outcome_time_median")
df[numeric_cols] <- lapply(df[numeric_cols], as.numeric)

##################
#2-Format
#################
df <- df %>% 
  mutate(colour_cohort = case_when(
    cohort == "prevax" ~ "#d2ac47",
    cohort == "vax" ~ "#58764c",
    cohort == "unvax" ~ "#0018a8",
    TRUE ~ ""
  ) %>% 
    factor(levels = c("#d2ac47", "#58764c", "#0018a8"))
  )

# Factor variables for ordering
df <- df %>%
  mutate(cohort = factor(cohort, levels = c("prevax", "vax", "unvax")),
                 )

# Rename adjustment groups
levels(df$cohort) <- list("Pre-vaccination (Jan 1 2020 - Dec 14 2021)"="prevax", "Vaccinated (Jun 1 2021 - Dec 14 2021)"="vax","Unvaccinated (Jun 1 2021 - Dec 14 2021)"="unvax")

# Change names for labelling purpose
df$analysis <- factor(df$analysis,levels = c("main", "sub_covid_hospitalised","sub_covid_nonhospitalised"))
levels(df$analysis) <- list("All COVID-19"="main", "Hospitalised COVID-19"="sub_covid_hospitalised","Non-hospitalised COVID-19"="sub_covid_nonhospitalised")
df$grouping_name <- paste0(df$analysis,"-", df$outcome)


outcomes_order <- c("nonvariceal_gi_bleeding", 
                     "acute_pancreatitis",
                    "peptic_ulcer", "appendicitis")
outcomes <- unique(df$outcome)
factor_levels <- c()
prefixes <- c("All COVID-19-", "Hospitalised COVID-19-", "Non-hospitalised COVID-19-")
for (i in 1:length(outcomes_order)) {
  browser
  for (j in 1:length(prefixes)) {
    factor_levels <- c(factor_levels, paste0(prefixes[j], outcomes_order[i]))
  }
}
# Set factor levels 
df$grouping_name <- factor(df$grouping_name, levels = factor_levels)


# Set facets labels 
labels <- c(
  `All COVID-19-nonvariceal_gi_bleeding` = "All COVID-19
  ",
  `Hospitalised COVID-19-nonvariceal_gi_bleeding` = "Hospitalised COVID-19
  Nonvariceal gastrointestinal bleeding",
  `Non-hospitalised COVID-19-nonvariceal_gi_bleeding` = "Non-hospitalised COVID-19
  ",
  `All COVID-19-acute_pancreatitis` = "",
  `Hospitalised COVID-19-acute_pancreatitis` = "Acute pancreatitis",
  `Non-hospitalised COVID-19-acute_pancreatitis` = "",
  
  `All COVID-19-peptic_ulcer` = "",
  `Hospitalised COVID-19-peptic_ulcer` = "Peptic ulcer",
  `Non-hospitalised COVID-19-peptic_ulcer` = "",
  
  `All COVID-19-appendicitis` = "",
  `Hospitalised COVID-19-appendicitis` = "Appendicitis",
  `Non-hospitalised COVID-19-appendicitis` = ""
  
)


# Function to plot 
plot_estimates <- function(df) {
  pd <- position_dodge(width = 0.5)

  p <- ggplot(df, aes(x = outcome_time_median/7, y = hr, color = colour_cohort)) +
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
    scale_color_manual(values = levels(df$colour_cohort), labels = levels(df$cohort)) +
    #  guides( color = guide_legend(ncol= 2)) +
    guides(fill=ggplot2::guide_legend(ncol = 2, byrow = FALSE),color= guide_legend(ncol=2) ) +
    # facet_wrap(outcome ~ analysis, ncol = 3, scales = "free_x", strip.position = "top") +
    theme_minimal() +
    labs(x = "\nWeeks since COVID-19 diagnosis", y = "Hazard ratio and 95% confidence interval") +
    scale_x_continuous(breaks = seq(0, max(df$outcome_time_median) / 7, 8)) +
    scale_y_continuous(lim = c(0.5,32), breaks = c(0.5,1,2,4,8,16,32), trans = "log")+ 
    theme(panel.grid.major.x = ggplot2::element_blank(),
                 panel.grid.minor = element_blank(),
                 panel.spacing.x = ggplot2::unit(0.5, "lines"),
                 panel.spacing.y = ggplot2::unit(0, "lines"),
                 legend.key = element_rect(colour = NA, fill = NA),
                 legend.title = element_blank(),
                 legend.position="bottom",
                 plot.background = element_rect(fill = "white", colour = "white"),
                 text=element_text(size=16),
          axis.text.x = element_text(size=14), 
          axis.text.y = element_text(size=14), 
          legend.text=element_text(size=12),
                 strip.text = element_text(face = "bold",size=12)) +
   
  facet_wrap(grouping_name~.,labeller=as_labeller(labels), ncol=3)    
  
  # Add annotations
  

  ggsave(paste0( "output/post_release/Figure_1", ".png"),
         height = 250, width =280, unit = "mm", dpi = 600, scale = 0.8)

  return(p)
}

plot_estimates(df)








