library(readr)
library(data.table)
library(tidyverse)
library(ggplot2)
library(stringr)



#################
#1- Get data
#################
df <- readr::read_csv("output/plot_model_output.csv",
                      show_col_types = FALSE) 
df<-df%>%
  
  filter(model=="mdl_max_adj")%>%
  #keep only rows with time points 
  filter(grepl("days\\d+", term))%>%
  # remove day0
  filter(term!="days0_1")%>%
  # Modify outcome names
  mutate(outcome = str_remove(outcome, "out_date_")) %>%
  mutate(outcome = str_to_title(outcome)) %>%
  filter(!is.na(hr) & hr != "" & hr!="[redact]")%>% 
  filter(stringr::str_detect(pattern="covid_hospitalised_",analysis))%>% # Anti coagulants (_c) and Thrombotic events (_te) analyses
  filter(!is.na(outcome_time_median))
 

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
df$outcome_label<- str_replace_all(df$outcome,"_"," ")
df$outcome_label<- str_replace(df$outcome_label,"gi","gastrointestinal")
# labels 
outcomes_order <- c("Nonvariceal gastrointestinal bleeding", "Lower gastrointestinal bleeding", "Upper gastrointestinal bleeding","Variceal gastrointestinal bleeding") 
df$outcome_label <- factor(df$outcome_label, levels = outcomes_order)
df$analysis_label <- factor(df$analysis, 
                      levels = c("sub_covid_hospitalised_te_true",
                                 "sub_covid_hospitalised_ac_true",
                                 "sub_covid_hospitalised_ac_false"),
                      labels = c("Thrombotic events after COVID19",
                                 "Anticoagulant prescription post discharge",
                                 "No anticoagulant prescription post discharge"))

####################
#3-Plotting function
####################
plot_estimates <- function(df,suffix) {
  pd <- position_dodge(width = 0.25)
   p <- ggplot(df, aes(x = outcome_time_median/7, y = hr, color = colour_cohort)) +
    geom_line(aes(linetype=analysis_label)) +
    geom_point(size = 2, position = pd) +
    geom_hline(mapping = aes(yintercept = 1), colour = "#A9A9A9") +
     geom_errorbar(size = 1.2, 
                   aes(ymin = ifelse(conf_low < 0.25, 0.25, conf_low),
                       ymax = ifelse(conf_high > 132, 132, conf_high),
                       width = 0.25), 
                  position = pd) +
    scale_color_manual(values = levels(df$colour_cohort), labels = levels(df$cohort)) +
    guides(fill=ggplot2::guide_legend(ncol = 4, byrow =TRUE),color= guide_legend(ncol=2) ) +
    facet_wrap(~outcome_label , ncol=3,scales="free_y") +
    theme_minimal() +
    labs(x = "\nWeeks since COVID-19 diagnosis", y = "Hazard ratio and 95% confidence interval") +
    scale_x_continuous(breaks = seq(0, max(df$outcome_time_median)/7, 8)) +  # display labels at 4-week intervals

    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          panel.spacing.x = unit(0.5, "lines"),
          panel.spacing.y = unit(0, "lines"),
          legend.key = element_rect(colour = NA, fill = NA),
          legend.title = element_blank(),
          legend.position = "bottom",
          plot.background = element_rect(fill = "white", colour = "white"),
          plot.margin = margin(1, 1, 1, 1, "cm"),
          text = element_text(size = 11),
          strip.text= element_text(size=11, face="bold")
    )
    if (suffix=="te"){
    p<- p + scale_y_continuous(lim = c(0.25,32), breaks = c(0.25,0.5,1,2,4,8,16,32), trans = "log")

    }else{
    p <- p+ scale_y_continuous(lim = c(0.25,132), breaks = c(0.25,0.5,1,2,4,8,16,32,64,132), trans = "log")

    }
   ggsave(paste0("output/post_release/Figure_4_",suffix,".png"), height = 250, width = 380, unit = "mm", dpi = 600, scale = 0.8)
  
  return(p)
}

df_ac<- df%>%
filter(stringr::str_detect(pattern="_ac_",analysis))
plot_estimates(df_ac,"ac")
df_te<- df%>%
  filter(stringr::str_detect(pattern="_te_",analysis))
plot_estimates(df_te,"te")

