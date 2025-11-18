# -----------------------------------------------------------
# Comprehensive Visualization Report (Bar, Pie, Box, Scatter)
# -----------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)
library(scales)

# Load dataset
df <- read_csv("country_wise_latest.csv", show_col_types = FALSE)

# Clean column names
names(df) <- gsub(" ", "_", names(df))
names(df) <- tolower(names(df))

# Rename key columns if present
df <- df %>%
  rename(
    country = `country/region`,
    who_region = `who_region`,
    confirmed = confirmed,
    deaths = deaths,
    recovered = recovered,
    active = active
  )

# Create additional columns
df <- df %>%
  mutate(
    cfr = ifelse(confirmed > 0, deaths / confirmed, NA),
    recovery_rate = ifelse(confirmed > 0, recovered / confirmed, NA)
  )

# Output PDF
pdf("complete_visualization_report.pdf", width = 11, height = 8.5)

theme_set(theme_minimal(base_size = 12))