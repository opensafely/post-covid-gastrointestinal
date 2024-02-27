library(dplyr)
library(readr)


# Load cohort data -------------------------------------------------------------
print('Load cohort data')
input <- readr::read_rds(paste0("output/input_unvax_stage1.rds"))%>%select(c(index_date,deregistration_date))

sink("output/not-for-review/dereg_date_test.txt")

input <- input %>% 
  mutate(active_registration=(is.na(deregistration_date) | (!is.na(deregistration_date) & deregistration_date>=index_date)) )
  table(input$active_registration)
print(paste0("nrow before filter: ",nrow(input)))
  input<- input%>%filter(is.na(deregistration_date) | (!is.na(deregistration_date) & deregistration_date>=index_date)) 
  print(paste0("nrow after filter: ",nrow(input)))
input <- input[!is.na(input$deregistration_date),]
  print(paste0("nrow !na deregestration: ",nrow(input[!is.na(input$deregistration_date),])))


print (head(input[1:10,]))
print(head(input[11:20,]))
print(head(input[21:30,]))
print(head(input[31:40,]))
print(head(input[41:50,]))
print(head(input[51:60,]))
print(head(input[61:70,]))

sink()
