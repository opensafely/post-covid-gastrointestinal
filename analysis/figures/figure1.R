############
# Figure 1 #
############
#libraries
library(readr)
library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)

# Using local path - for testing
#dir <- "C:/Users/gic30/OneDrive - University of Cambridge/2. Long Covid/Code/Post-covid-vaccinated - stage 6 - Figure 1 - 2022.02"
dir<-"/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/models"
#setwd(dir)

#------------------#
# 1. Load argument #
#------------------#

# Define cohort(s)
cohort=c("vax","unvax","prevax")

#-------------------------#
# 2. Get outcomes to plot #
#-------------------------#
active_analyses <- read_rds("lib/active_analyses.rds")%>%
filter(analysis=="main" & !outcome %in% c("out_date_bowel_ischaemia","out_date_intestinal_obstruction","out_date_nonalcoholic_steatohepatitis","out_date_variceal_gi_bleeding","out_date_belching"))
outcome_name_table  <- distinct(active_analyses, outcome)%>%
mutate( outcome=str_replace(outcome, "out_date_", ""))



# Focus on symptoms first 
outcome_to_plot <- outcome_name_table$outcome[outcome_name_table$outcome%in% c("ibs","nausea","vomiting","bloody_stools","abdominal_paindiscomfort","abdominal_distension","diarrhoea")]

#---------------------------------------------#
# 3. Load and combine all estimates in 1 file #
#---------------------------------------------#

estimates <- read.csv(paste0(dir,"/model_output_main_17-02-23.csv"))

# Get estimates for main analyses and list of outcomes from active analyses
main_estimates <-estimates %>% 
  filter(analysis == "main" & outcome %in% outcome_to_plot & term %in% term[grepl("^days",term)])

#--------------------------------------#
# 4. Specify time in weeks (mid-point) #
#--------------------------------------#
term=unique(main_estimates$term)
#class(term)
#term=as.character()

cuts=c()
for(i in 1:length(term)){
  time_period=sub("days","",term[i])
  cuts=append(cuts,as.numeric(sub('\\_.*', '', time_period)))
  cuts=append(cuts,as.numeric(gsub(".*_", "",time_period)))
}
cuts=unique(cuts) 
cuts=sort(cuts, decreasing = F)
# cuts are        0  14  28  56  84   197(should be 196-28 weeks)
# mid-points are    7  21  42  70  140
# In weeks (/7)     1   3   6  10   20

# Find the mid point in weeks of the time periods
time=c()
for(i in 1:(length(cuts)-2)){
  time=append(time,(cuts[i+1]+cuts[i])/14)
}
time=append(time,((cuts[length(cuts)]-1)+cuts[length(cuts)-1])/14) # change 197 to 196 i.e. cuts[length(cuts)]-1 for the last time

# Add time in weeks for the reduced time periods at the end
time=append(time,2) 
time=append(time,((cuts[length(cuts)]-1)+28)/14)

# Create a character vector of all the time period terms in increasing order with the reduced time periods at the end
term=as.character()
for(i in 1:(length(cuts)-1)){
  term=append(term,as.character(paste0("days",cuts[i],"_",cuts[i+1])))
}
term=append(term,as.character("days0_28"))
term=append(term,as.character(paste0("days28_",cuts[length(cuts)])))

# Get time and term into a data frame to link
term_to_time <- data.frame(term = term, time = time)

# Add time to estimates dataset 
main_estimates <- merge(main_estimates, term_to_time, by = c("term"), all.x = TRUE)

#------------------------------------------#
# 4. Specify groups and their line colours #
#------------------------------------------#
# Specify colours
main_estimates$colour <- ""
main_estimates$colour <- ifelse(main_estimates$model=="mdl_agesex","#bababa",main_estimates$colour) # Grey
main_estimates$colour <- ifelse(main_estimates$model=="mdl_max_adj","#000000",main_estimates$colour) # Black

# Factor variables for ordering
main_estimates$model <- factor(main_estimates$model, levels=c("mdl_agesex", "mdl_max_adj")) 
main_estimates$colour <- factor(main_estimates$colour, levels=c("#bababa", "#000000"))

# Rename adjustment groups
levels(main_estimates$model) <- list("Age/sex/region adjustment"="mdl_agesex", "Extensive adjustment"="mdl_max_adj")

#-------------------------#
# 5. Specify outcome name #
#-------------------------#
# Use the nice names from active_analyses table i.e. outcome_name_table
main_estimates <- main_estimates %>% left_join(outcome_name_table %>% select(outcome, outcome), by = c("event"="outcome"))

#---------#
# 6. Plot #
#---------#
for(c in cohort){
  
  df=main_estimates %>% filter(cohort ==c)

  ggplot2::ggplot(data=df,
                mapping = ggplot2::aes(x=time, y = estimate, color = model, shape=model, fill=model))+
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 1)) +
    ggplot2::geom_hline(mapping = ggplot2::aes(yintercept = 1), colour = "#A9A9A9") +
    ggplot2::geom_errorbar(mapping = ggplot2::aes(ymin = ifelse(conf.low<0.25,0.25,conf.low), 
                                                  ymax = ifelse(conf.high>64,64,conf.high),  
                                                  width = 0), 
                           position = ggplot2::position_dodge(width = 1))+   
    ggplot2::geom_line(position = ggplot2::position_dodge(width = 1)) +    
    ggplot2::scale_y_continuous(lim = c(0.25,8), breaks = c(0.5,1,2,4,8), trans = "log") +
#   ggplot2::scale_y_continuous(lim = c(0.25,64), breaks = c(0.5,1,2,4,8,16,32,64), trans = "log") +
    ggplot2::scale_x_continuous(lim = c(0,28), breaks = seq(0,28,4)) +
    ggplot2::scale_fill_manual(values = levels(df$colour), labels = levels(df$model))+ 
    ggplot2::scale_color_manual(values = levels(df$colour), labels = levels(df$model)) +
    ggplot2::scale_shape_manual(values = c(rep(21,22)), labels = levels(df$model)) +
    ggplot2::labs(x = "\nWeeks since COVID-19 diagnosis", y = "Hazard ratio and 95% confidence interval") +
    ggplot2::guides(fill=ggplot2::guide_legend(ncol = 2, byrow = TRUE)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.spacing.x = ggplot2::unit(0.5, "lines"),
                   panel.spacing.y = ggplot2::unit(0, "lines"),
                   legend.key = ggplot2::element_rect(colour = NA, fill = NA),
                   legend.title = ggplot2::element_blank(),
                   legend.position="bottom",
                   plot.background = ggplot2::element_rect(fill = "white", colour = "white")) +    
    ggplot2::facet_wrap(outcome~., ncol = 2)

  ggplot2::ggsave(paste0("output/Figure1","_",c,".png"), height = 297, width = 210, unit = "mm", dpi = 600, scale = 1)
}

