# process actions and statuses (fail/success) copied from the job server and save to csv file
process_text_file <- function(file_path) {
  lines <- readLines(file_path)
  results <- data.frame(model = character(), success = logical(), outcome = character(), analysis = character(), cohort = character(), stringsAsFactors = FALSE)
  
  # Find models lines
  for (i in 1:length(lines)) {
    if (startsWith(lines[i], "cox_ipw")) {
      model <- lines[i]
      # Find successful/failed status
      success <- lines[i + 2] == "Successful"
    #   Find cohort,analysis, outcome
      parts <- strsplit(model, "-")[[1]]
      outcome <- tail(parts, n=1)
      analysis <- parts[length(parts)-1]
      cohort <- ifelse(grepl("prevax", model), "prevax", ifelse(grepl("unvax", model), "unvax", "vax"))
      
      # Append the extracted information to the results data frame
      results <- rbind(results, data.frame(model = model, success = success, outcome = outcome, analysis = analysis, cohort = cohort))
    }
  }
  
  write.csv(results, "lib/actions_20240220.csv", row.names = FALSE,quote=FALSE)
}

process_text_file("lib/actions_raw_20240220.txt")
