# Set seed ---------------------------------------------------------------------

set.seed(1)


df_vax<- df %>%
  mutate(
    vax_date_Pfizer_1 = as.Date(vax_date_eligible) + days(round(rnorm(nrow(.), mean = 10, sd = 3))),
    vax_date_AstraZeneca_1 = as.Date(vax_date_eligible) + days(round(rnorm(nrow(.), mean = 10, sd = 3))),
    vax_date_Moderna_1 = as.Date(vax_date_eligible) + days(round(rnorm(nrow(.), mean = 10, sd = 3)))
  ) %>%
  mutate(
    vaccine_1_type = sample(
      x = c("Pfizer", "AstraZeneca", "Moderna",  "None"),
      size = nrow(.),
      replace = TRUE,
      prob = c(0.4, 0.4, 0.05, 0.1)
    ),
    missing_pfizer_2 = rbernoulli(nrow(.), p=0.05),
    missing_az_2 = rbernoulli(nrow(.), p=0.05),
    missing_moderna_2 = rbernoulli(nrow(.), p=0.05),
    missing_pfizer_3 = rbernoulli(nrow(.), p=0.9),
    missing_az_3 = rbernoulli(nrow(.), p=0.9),
    missing_moderna_3 = rbernoulli(nrow(.), p=0.9)
  )%>%
  mutate(across(vax_date_Pfizer_1,
                ~if_else(
                  vaccine_1_type %in% "Pfizer",
                  .x,
                  NA_Date_))) %>%
  mutate(across(vax_date_AstraZeneca_1,
                ~if_else(
                  vaccine_1_type %in% "AstraZeneca",
                  .x,
                  NA_Date_))) %>%
  mutate(across(vax_date_Moderna_1,
                ~if_else(
                  vaccine_1_type %in% "Moderna",
                  .x,
                  NA_Date_))) %>%

  mutate(across(matches("vax_date\\w+_1"),
                ~ if_else(
                  vaccine_1_type %in% "None",
                  NA_Date_,
                  .x
                ))) %>%
  mutate(
    vax_date_Pfizer_2 = vax_date_Pfizer_1 + days(round(rnorm(nrow(.), mean = 10*7, sd = 3))),
    vax_date_AstraZeneca_2 = vax_date_AstraZeneca_1 + days(round(rnorm(nrow(.), mean = 10*7, sd = 3))),
    vax_date_Moderna_2 = vax_date_Moderna_1  + days(round(rnorm(nrow(.), mean = 10*7, sd = 3))),
  ) %>%
  # change in 2nd vaccine type
  mutate(vaccine_2_type =  ifelse(runif(nrow(df),0,1)>0.95 & vaccine_1_type!="None",
         sample(
                x = c("Pfizer", "AstraZeneca", "Moderna",  "None"),
                size = nrow(.),
                replace = TRUE,
                prob = c(0.4, 0.4, 0.05, 0.1)
              ),
  vaccine_1_type)
  ) %>%
  mutate(across(vax_date_Pfizer_2,
                ~if_else(
                  vaccine_2_type %in% "Pfizer",
                  .x,
                  NA_Date_))) %>%
  mutate(across(vax_date_AstraZeneca_2,
                ~if_else(
                  vaccine_2_type %in% "AstraZeneca",
                  .x,
                  NA_Date_))) %>%
  mutate(across(vax_date_Moderna_2,
                ~if_else(
                  vaccine_1_type %in% "Moderna",
                  .x,
                  NA_Date_))) %>%

  mutate(across(matches("vax_date\\w+_2"),
                ~ if_else(
                  vaccine_2_type %in% "None",
                  NA_Date_,
                  .x
                ))) %>%

  mutate(across(vax_date_Pfizer_2,
                ~if_else(
                  missing_pfizer_2,
                  NA_Date_,
                  .x))) %>%
  mutate(across(vax_date_AstraZeneca_2,
                ~if_else(
                  missing_az_2,
                  NA_Date_,
                  .x))) %>%
  mutate(across(vax_date_Moderna_2,
                ~if_else(
                  missing_moderna_2,
                  NA_Date_,
                  .x))) %>%

  mutate(vaccine_3_type =  ifelse( vaccine_2_type!="None",
                                sample(
                                  x = c("Pfizer", "AstraZeneca" ,"Moderna",  "None"),
                                  size = nrow(.),
                                  replace = TRUE,
                                  prob = c(0.6, 0.1, 0.3, 0.1)
                                ),vaccine_2_type
                               )
  ) %>%
   mutate(
    vax_date_Pfizer_3 = vax_date_Pfizer_2 + days(round(rnorm(nrow(.), mean = 6*4*7, sd = 7))),
    vax_date_AstraZeneca_3 = vax_date_AstraZeneca_2 + days(round(rnorm(nrow(.), mean = 6*4*7, sd = 7))),
    vax_date_Moderna_3 = vax_date_Moderna_2 + days(round(rnorm(nrow(.), mean = 6*4*7, sd = 7))),
  ) %>%
    mutate(across(vax_date_Pfizer_3,
                  ~if_else(
                    vaccine_3_type %in% "Pfizer",
                    .x,
                    NA_Date_))) %>%
    mutate(across(vax_date_AstraZeneca_3,
                  ~if_else(
                    vaccine_3_type %in% "AstraZeneca",
                    .x,
                    NA_Date_))) %>%
    mutate(across(vax_date_Moderna_3,
                  ~if_else(
                    vaccine_1_type %in% "Moderna",
                    .x,
                    NA_Date_))) %>%

    mutate(across(matches("vax_date\\w+_3"),
                  ~ if_else(
                    vaccine_3_type %in% "None",
                    NA_Date_,
                    .x
                  ))) %>%

    mutate(across(vax_date_Pfizer_3,
                  ~if_else(
                    missing_pfizer_3,
                    NA_Date_,
                    .x))) %>%
    mutate(across(vax_date_AstraZeneca_3,
                  ~if_else(
                    missing_az_3,
                    NA_Date_,
                    .x))) %>%
    mutate(across(vax_date_Moderna_3,
                  ~if_else(
                    missing_moderna_3,
                    NA_Date_,
                    .x)))%>%

select(-starts_with("missing"),-matches("vaccine_\\d_type"))

  
  
# ##OLD APPROACH------------------------------------------------------------------- 
# tmp <- df %>%
#   select(c(patient_id,vax_date_eligible)) %>%
#   mutate (seq = 1)
#   tmp$product = c("AstraZeneca","Pfizer","None","Moderna")[ceiling(runif(nrow(tmp),0,3.5))]
#   tmp$date = as.Date(tmp$vax_date_eligible + round(rnorm(nrow(tmp), mean = 10, sd = 3)))
# 
# 
# # Generate second vaccine information ------------------------------------------
# 
# tmp2 <- tmp
# tmp2$date <- as.Date(tmp2$date + round(rnorm(nrow(tmp2), mean = 10*7, sd = 7)), origin = '1970-01-01')
# tmp2$seq <- 2
# tmp2$product <- ifelse(runif(nrow(tmp2),0,1)>0.95 & tmp2$product!="None",c("AstraZeneca","Pfizer","None","Moderna")[ceiling(runif(nrow(tmp2),0,3.5))],tmp2$product)
# tmp <- rbind(tmp,tmp2)
# 
# # Generate third vaccine information -------------------------------------------
# 
# tmp3 <- tmp2
# tmp3$date <- as.Date(tmp3$date + round(rnorm(nrow(tmp3), mean = 6*4*7, sd = 7)))
# tmp3$seq <- 3
# tmp3$product <- ifelse(tmp3$product!="None",c("Pfizer","None","Moderna","AstraZeneca")[ceiling(runif(nrow(tmp3),0,3.01))],"None")
# tmp <- rbind(tmp,tmp3)
# 
# 
# # Remove sequence information by patient only ----------------------------------
# 
# tmp$seq <- NULL
# 
# # Remove records of no product -------------------------------------------------
# 
# tmp <- tmp[tmp$product!="None",]
# 
# # Add sequence information by patient and product ------------------------------
# 
# tmp <- tmp %>%
#   dplyr::arrange(patient_id,product,date) %>%
#   dplyr::group_by(patient_id,product) %>%
#   dplyr::mutate(product_rank=rank(date))
# 
# # Make wide format table -------------------------------------------------------
# 
# tmp <- tidyr::pivot_wider(tmp,
#                    names_from = c("product","product_rank"),
#                    names_prefix = "vax_date_",
#                    values_from = "date")
# 
# # Order variables --------------------------------------------------------------
# 
# # tmp <- tmp[,c("patient_id",
# #               "vax_date_AstraZeneca_1","vax_date_AstraZeneca_2","vax_date_AstraZeneca_3",
# #               "vax_date_Pfizer_1","vax_date_Pfizer_2","vax_date_Pfizer_3",
# #               "vax_date_Moderna_1","vax_date_Moderna_2","vax_date_Moderna_3")]
# 
# # The code above gives an error when one column is missing "vax_date_AstraZeneca_3" when n = 1000 
# tmp <- tmp %>% 
#   relocate(any_of(c("patient_id",
#                     "vax_date_AstraZeneca_1","vax_date_AstraZeneca_2","vax_date_AstraZeneca_3",
#                     "vax_date_Pfizer_1","vax_date_Pfizer_2","vax_date_Pfizer_3",
#                     "vax_date_Moderna_1","vax_date_Moderna_2","vax_date_Moderna_3")))
# 
# # Replace vax data in main dataset ---------------------------------------------
# 
# df[,c("vax_date_AstraZeneca_1","vax_date_AstraZeneca_2","vax_date_AstraZeneca_3",
#       "vax_date_Pfizer_1","vax_date_Pfizer_2","vax_date_Pfizer_3",
#       "vax_date_Moderna_1","vax_date_Moderna_2","vax_date_Moderna_3")] <- NULL
# 
# df <- merge(df, tmp, by = "patient_id", all.x = TRUE)
# 
# rm(tmp, tmp2, tmp3)








  



