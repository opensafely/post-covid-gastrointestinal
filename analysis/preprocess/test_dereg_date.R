library(dplyr)
library(readr)


# Load cohort data -------------------------------------------------------------
print('Load cohort data')
input <- read_rds(file.path("output", paste0("input_unvax.rds")))%>%select(c(index_date_cohort,deregistration_date))

sink("output/not-for-review/dereg_date_test.txt")
# print (paste0("type of deregistration date: ",(typeof(input$deregistration_date))) )
# print(paste0("class of index date: ",(class(input$index_date_cohort))) )
# print(paste0("class of daregistration date: ",(class(input$deregistration_date))))
# print(summary(input%>%select(c(deregistration_date,index_date_cohort))))
# print(str(input%>%select(c(deregistration_date,index_date_cohort))))
input <- input %>% 
  mutate(active_registration=(is.na(deregistration_date) | (!is.na(deregistration_date) & deregistration_date>=index_date_cohort)) )
  table(input$active_registration)
print(paste0("nrow before filter: ",nrow(input)))
  input<- input%>%filter(is.na(deregistration_date) | (!is.na(deregistration_date) & deregistration_date>=index_date_cohort)) 
  print(paste0("nrow after filter: ",nrow(input)))
input <- input[!is.na(input$deregistration_date),]
  print(paste0("nrow !na deregestration: ",nrow(input)))


print (head(input[1:10,]))
print(head(input[11:20,]))
print(head(input[21:30,]))
print(head(input[31:40,]))
print(head(input[41:50,]))
print(head(input[51:60,]))
print(head(input[61:70,]))

sink()
