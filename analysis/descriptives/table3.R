source("analysis/utility.R")
# Load data --------------------------------------------------------------------
print("Load data")

output_dir <- "/Users/cu20932/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofBristol/grp-EHR - OS outputs/Day0/models_30_11_2023/"

df <- readr::read_csv("output/plot_model_output.csv",
                      show_col_types = FALSE)

# Filter data ------------------------------------------------------------------
print("Filter data")

df <- df[grepl("days\\d", df$term), ]

df <- df[df$model=="mdl_max_adj",
         c("analysis","cohort","outcome","term","hr","conf_low","conf_high")]


# Add less than 50 events ------------------------------------------------------
print("Add less than 50 events")

tmp <- readr::read_csv(paste0(output_dir,"model_output_midpoint6.csv"),
                       show_col_types = FALSE)

tmp$source <- "R"

tmp <- tmp[!is.na(tmp$error),colnames(df)]

tmp$term <- NULL

tmp2 <- unique(df[,c("cohort","analysis","term")])
tmp <- merge(tmp, tmp2, by = c("cohort","analysis"))

tmp$hr <- "X"

df <- rbind(df,tmp)

# Add plot labels --------------------------------------------------------------
print("Add plot labels")

plot_labels <- readr::read_csv("lib/plot_labels.csv",
                               show_col_types = FALSE)

df <- merge(df, plot_labels[,c("term","label")], by.x = "outcome", by.y = "term", all.x = TRUE)
df <- dplyr::rename(df, "outcome_label" = "label")

df <- merge(df, plot_labels[,c("term","label")], by.x = "analysis", by.y = "term", all.x = TRUE)
df <- dplyr::rename(df, "analysis_label" = "label")
df$analysis_label <- ifelse(grepl("main",df$analysis),"Primary",df$analysis_label)

# Annotate episodes ------------------------------------------------------------
print("Annotate episodes")

df$episodes <- "Day zero"
# df$episodes <- ifelse(grepl("day0",df$analysis),"Day zero", df$episodes)
# df$episodes <- ifelse(grepl("detailed",df$analysis),"Detailed", df$episodes)

# Tidy estimate ----------------------------------------------------------------
print("Tidy estimate")

df$estimate <- ifelse(df$hr=="X",
                      "X",
                      paste0(display(as.numeric(df$hr))," (",display(as.numeric(df$conf_low)),"-",display(as.numeric(df$conf_high)),")"))

# Tidy term --------------------------------------------------------------------
print("Tidy term")

df$weeks <- ""
df$weeks <- ifelse(df$term=="days0_1", "Day 0", df$weeks)
df$weeks <- ifelse(df$term=="days1_28", "Weeks 1-4, without day 0", df$weeks)
df$weeks <- ifelse(df$term=="days1_7", "Week 1, without day 0", df$weeks)
df$weeks <- ifelse(df$term=="days7_14", "Week 2", df$weeks)
df$weeks <- ifelse(df$term=="days14_21", "Week 3", df$weeks)
df$weeks <- ifelse(df$term=="days21_28", "Week 4", df$weeks)
df$weeks <- ifelse(df$term=="days0_28", "Weeks 1-4", df$weeks)
df$weeks <- ifelse(df$term=="days28_197", "Weeks 5-28", df$weeks)
df$weeks <- ifelse(df$term=="days197_365", "Weeks 29-52", df$weeks)
df$weeks <- ifelse(df$term=="days365_714", "Weeks 53-102", df$weeks)

df$weeks <- factor(df$weeks, levels = c("Day 0",
                                        "Week 1, without day 0",
                                        "Week 2",
                                        "Week 3",
                                        "Week 4",
                                        "Weeks 1-4, without day 0",
                                        "Weeks 1-4",
                                        "Weeks 5-28",
                                        "Weeks 29-52",
                                        "Weeks 53-102"))

# Pivot table ------------------------------------------------------------------
print("Pivot table")

df <- df[,c("episodes","analysis_label","cohort","outcome_label","weeks","estimate")]

df <- tidyr::pivot_wider(df,
                         id_cols = c("episodes","analysis_label","outcome_label","weeks"),
                         names_from = "cohort",
                         values_from = "estimate")
# Order analyses ---------------------------------------------------------------
print("Order analyses")

df$analysis_label <- factor(df$analysis_label,
                            levels = c("Primary",
                                       "Hospitalised COVID-19",
                                       "Non-hospitalised COVID-19",
                                       "No prior history of event",
                                       "Prior history of gastrointestinal event",
                                       "No prior history of gastrointestinal event",
                                       "Prior gastrointestinal operation",
                                       "No prior gastrointestinal operation",
                                       "History of COVID-19",
                                       "Age group: 18-39",
                                       "Age group: 40-59",
                                       "Age group: 60-79",
                                       "Age group: 80-110",
                                       "Sex: Female",                                   
                                       "Sex: Male",
                                       "Ethnicity: White",
                                       "Ethnicity: South Asian",
                                       "Ethnicity: Black",
                                       "Ethnicity: Other",                       
                                       "Ethnicity: Mixed"))

# Order outcomes ---------------------------------------------------------------
print("Order outcomes")

df$outcome_label <- factor(df$outcome_label,
                           levels = c("Nonvariceal gastrointestinal bleeding",
                                      "Lower gastrointestinal bleeding",
                                      "Variceal gastrointestinal bleeding",
                                      "Upper gastrointestinal bleeding",
                                      "Gastro oesophageal reflux",
                                      "Gallstones",
                                      "Ibs",
                                      "Acute pancreatitis",
                                      "Peptic ulcer",
                                      "Appendicitis",
                                      "Nonalcoholic steatohepatiti"))
# 
# # Order episodes ---------------------------------------------------------------
# print("Order episodes")
# 
# df$episodes <- factor(df$episodes,
#                       levels = c("Standard",
#                                  "Day zero",
#                                  "Detailed"))





# Tidy table -------------------------------------------------------------------
print("Tidy table")

df <- df[order(df$analysis_label,df$outcome_label,df$weeks),
         c("analysis_label","outcome_label","weeks","prevax","vax","unvax")]

df <- dplyr::rename(df,
                    "Analysis" = "analysis_label",
                    "Outcome" = "outcome_label",
                    "Time since COVID-19" = "weeks",
                    "Pre-vaccination cohort" = "prevax",
                    "Vaccinated cohort" = "vax",
                    "Unvaccinated cohort" = "unvax")

# Save table -------------------------------------------------------------------
print("Save table")

readr::write_csv(df, "output/post_release/table3.csv", na = "-")