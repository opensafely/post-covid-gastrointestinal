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
estimates <-read.csv(paste0(results_dir, "/model_output_subcovid_hist_07032023.csv"))  %>%
  # Extract outcomes to plot
  filter(!outcome %in% disregard) %>%
  filter(model=="mdl_max_adj")%>%
  #keep only rows with time points 
  filter(grepl("days\\d+", term))%>%
  # Modify outcome names
  mutate(outcome = str_remove(outcome, "out_date_")) %>%
  mutate(outcome = str_to_title(outcome)) %>%
  filter(outcome_time_median!="[redact]")%>%
  # mutate(conf_high = ifelse(grepl("Inf", conf_high), NA_real_, conf_high))%>%
  filter(conf_high!="Inf")%>%
  mutate(across(lnhr:outcome_time_median, as.numeric)) 


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
    factor()
  )

# Specify group colors and line types
#analysis_linetypes <- c("sub_covid_hospitalised" = "solid", "sub_covid_nonhospitalised" = "dashed")

# Factor variables for ordering
estimates <- estimates %>%
  mutate(cohort = factor(cohort),
         
         analysis = factor(analysis, levels = c("sub_covid_history")),
         #linetype = factor(analysis_linetypes[analysis], levels = c("solid", "dashed")))

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
  
  p <- ggplot(df, aes(x = outcome_time_median/7, y = hr,color=df$colour_cohort)) +
    geom_line() +
    geom_point(size = 2, position = pd) +
    geom_hline(mapping = aes(yintercept = 1), colour = "#A9A9A9") +
    geom_errorbar(size = 1.2,
                  mapping = aes(ymin = ifelse(conf_low < 0.25, 0.25, conf_low), 
                                ymax = ifelse(conf_high > 64, 64, conf_high),
                                width = 0),
                  position = pd) + 
   #scale_color_manual(values = (df$colour_cohort), labels=(df$cohort)) +
    scale_color_manual(values = as.character(df$colour_cohort), labels = df$cohort)+
  
    #scale_linetype_manual(values =c("solid","dashed"), labels = levels(df$analysis)) + # Add linetype legend
    guides(fill=ggplot2::guide_legend(ncol = 1, byrow = TRUE) ) +
    facet_wrap(~outcome,ncol = 1) +
    theme_minimal() +
    labs(x = "\nWeeks since COVID-19 diagnosis", y = "Hazard ratio and 95% confidence interval") +
    scale_x_continuous(breaks = seq(0, max(df$outcome_time_median)/7, 4)) +  # display labels at 4-week intervals
    scale_y_continuous(lim = c(0.25,32), breaks = c(0.25,0.5,1,2,4,8,16,32), trans = "log")+ 
    
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          panel.spacing.x = unit(0.5, "lines"),
          panel.spacing.y = unit(0, "lines"),
          #legend.key = element_rect(colour = NA, fill = NA),
          legend.title = element_blank(),
          legend.position = "bottom",
          legend.direction = "vertical",
          plot.background = element_rect(fill = "white", colour = "white"),
          plot.margin = margin(1, 1, 1, 1, "cm"),
          strip.text = element_text(size = 13, face = "bold", vjust = 1.5),
          text = element_text(size = 12),
    )
  
  ggsave(paste0("output/",name,"_subcovhist.png"), height = 297, width = 210, unit = "mm", dpi = 600, scale = 1)
  
  return(p)
}


p_symptoms <- plot_estimates(estimates_symptoms,"Symptoms")
p_others<- plot_estimates(estimates_others,"Others")

