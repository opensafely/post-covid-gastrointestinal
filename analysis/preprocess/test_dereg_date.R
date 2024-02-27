library(dplyr)
library(readr)


# Load cohort data -------------------------------------------------------------
print('Load cohort data')
input <- read_rds(file.path("output", paste0("input_unvax.rds")))%>%select(c(index_date,deregistration_date))

sink("output/not-for-review/dereg_date_test.txt")
print (paste0("type of deregistration date: ",(typeof(input$deregistration_date))) )
print(paste0("class of daeath date: ",(class(input$index_date))) )
print(paste0("class of daregistration date: ",(class(input$deregistration_date))))
print(summary(input%>%select(c(deregistration_date,index_date))))
print(str(input%>%select(c(deregistration_date,index_date))))
sink()
