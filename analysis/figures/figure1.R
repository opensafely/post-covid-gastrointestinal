library(readr)
library(data.table)
library(tidyverse)
library(ggplot2)

# Define results directory
results_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/models"

#################
#1- Get data
#################

disregard<- str_to_title(c("out_date_bowel_ischaemia", "out_date_intestinal_obstruction", "out_date_nonalcoholic_steatohepatitis", "out_date_variceal_gi_bleeding", "out_date_belching"))
#symptoms 
symptoms<- str_to_title(c("ibs", "nausea", "vomiting", "bloody_stools", "abdominal_paindiscomfort", "abdominal_distension", "diarrhoea"))
estimates <-read.csv(paste0(results_dir, "/model_output_main_17-02-23.csv"))  %>%
  # Extract outcomes to plot
  filter(!outcome %in% disregard) %>%
  filter(model=="mdl_max_adj")%>%
  #keep only rows with time points 
  filter(grepl("days\\d+", term))%>%
  # Modify outcome names
  mutate(outcome = str_remove(outcome, "out_date_")) %>%
  mutate(outcome = str_to_title(outcome))


##################
#2-Format
#################
estimates <- estimates %>% 
  mutate(colour_cohort = case_when(
    cohort == "prevax" ~ "#d2ac47",
    cohort == "vax" ~ "#58764c",
    cohort == "unvax" ~ "#0018a8",
    TRUE ~ ""
  ) %>% 
    factor(levels = c("#d2ac47", "#58764c", "#0018a8"))
  )

# Specify group colors and line types
analysis_linetypes <- c("covid_pheno_hospitalised" = "solid", "covid_pheno_non_hospitalised" = "dashed")

# Factor variables for ordering
estimates <- estimates %>%
  mutate(cohort = factor(cohort, levels = c("prevax", "vax", "unvax")),
         
         analysis = factor(analysis, levels = c("main", "covid_pheno_hospitalised", "covid_pheno_non_hospitalised")),
         linetype = factor(analysis_linetypes[analysis], levels = c("solid", "dashed")))

# Rename adjustment groups
levels(estimates$cohort) <- list("Pre-vaccination (Jan 1 2020 - Dec 14 2021)"="prevax", "Vaccinated (Jun 1 2021 - Dec 14 2021)"="vax","Unvaccinated (Jun 1 2021 - Dec 14 2021)"="unvax")

####################
#3-Data to plot
####################
estimates_symptoms<-estimates %>%
  filter(outcome%in% symptoms)

estimates_others<-estimates%>%
  anti_join(estimates_symptoms)

####################
#3-Plotting functio
####################
plot_estimates <- function(df,name) {
  pd <- position_dodge(width = 0.5)
  
  p <- ggplot(df, aes(x = outcome_time_median/7, y = hr, color = colour_cohort, linetype = linetype)) +
    geom_line() +
    geom_point(size = 2, position = pd) +
    geom_hline(mapping = aes(yintercept = 1), colour = "#A9A9A9") +
    geom_errorbar(size = 1.2,
                  mapping = aes(ymin = ifelse(conf_low < 0.25, 0.25, conf_low), 
                                ymax = ifelse(conf_high > 64, 64, conf_high),
                                width = 0),
                  position = pd) + 
    scale_color_manual(values = levels(df$colour_cohort), labels = levels(df$cohort)) +
    #labs(x = "Time (days)", y = "Hazard ratio", color = "Cohort", linetype = "Analysis")+
    guides(linetype = "none", color = guide_legend(nrow = 3)) +
    guides(fill=ggplot2::guide_legend(ncol = 1, byrow = TRUE) ) +
    facet_wrap(~outcome) +
    theme_minimal() +
    labs(x = "\nWeeks since COVID-19 diagnosis", y = "Hazard ratio and 95% confidence interval") +
    scale_x_continuous(breaks = seq(0, max(df$outcome_time_median)/7, 4)) +  # display labels at 4-week intervals
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          panel.spacing.x = unit(0.5, "lines"),
          panel.spacing.y = unit(0, "lines"),
          legend.key = element_rect(colour = NA, fill = NA),
          legend.title = element_blank(),
          legend.position = "bottom",
          plot.background = element_rect(fill = "white", colour = "white"),
          plot.margin = margin(1, 1, 1, 1, "cm"),
          text = element_text(size = 12),
    )
  ggsave(paste0("output/Figure_1_all_cohorts_",name,"_main.png"), height = 297, width = 210, unit = "mm", dpi = 600, scale = 1)
  
  #return(p)
}


p_symptoms <- plot_estimates(estimates_symptoms,"Symptoms")
p_others<- plot_estimates(estimates_others,"Others")

