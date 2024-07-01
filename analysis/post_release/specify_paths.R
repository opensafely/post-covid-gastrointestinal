# This file is used to specify paths. It is in the .gitignore to keep your information secret.
# To use, please remove "_example" from the file name and add your specific file paths below.

# release <- "output/results/" # directory containing all results
# release2 <- "" # directory containing extended table 1


release <- "C:/Users/rd16568/OneDrive - University of Bristol/grp-EHR/Projects/post-covid-gastrointestinal/OS outputs/death_fix20240305/Outputs/" # Specify path to release directory  

path_aer_input <- paste0(release,"aer_input-main-midpoint6.csv")
path_model_r_output<-paste0(release,"20260627/model_output_midpoint6.csv") 
path_model_stata_output_1<-paste0(release,"stata_model_output_midpoint6_1.csv") 
path_model_stata_output_2<-paste0(release,"stata_model_output_midpoint6_2.csv") 

path_model_output_format<-paste0(release,"20260627/model_output_midpoint6.csv") 
# path_consort <- paste0(release,"20230807/consort_output_rounded.csv")
# path_median_iqr_age <- paste0(release,"20230807/median_iqr_age.csv")
# path_model_output <- paste0(release,"20230818/model_output_rounded.csv")
# path_table1 <- paste0(release,"20230807/table1_output_rounded.csv")

path_table2_prevax <- paste0(release,"table2_prevax_midpoint6.csv") 
path_table2_unvax <- paste0(release,"table2_unvax_midpoint6.csv") 
path_table2_vax <- paste0(release,"table2_vax_midpoint6.csv")
 
path_table2_anticoag_prevax <- paste0(release,"20260627/table2_anticoagulants_prevax_midpoint6.csv") 
path_table2_anticoag_unvax <- paste0(release,"20260627/table2_anticoagulants_unvax_midpoint6.csv") 
path_table2_anticoag_vax <- paste0(release,"20260627/table2_anticoagulants_vax_midpoint6.csv")

path_table2_thromb_prevax <- paste0(release,"20260627/table2_thrombotic_prevax_midpoint6.csv") 
path_table2_thromb_unvax <- paste0(release,"20260627/table2_thrombotic_unvax_midpoint6.csv") 
path_table2_thromb_vax <- paste0(release,"20260627/table2_thrombotic_vax_midpoint6.csv") 
 
# path_venn <- paste0(release,"20230807/venn_output_rounded.csv")
# path_extendedtable1 <- paste0(release,"20230810/extendedtable1_output_rounded.csv")