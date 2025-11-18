# -----------------------------------------------------------
# Comprehensive Visualization Report (Bar, Pie, Box, Density, Scatter)
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

# -----------------------------------------------------------
# 1. BAR CHART — Top 10 Countries by Confirmed
# -----------------------------------------------------------
top_confirmed <- df %>% arrange(desc(confirmed)) %>% slice_head(n = 10)

print(
  ggplot(top_confirmed, aes(x = reorder(country, confirmed), y = confirmed)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(title = "Top 10 Countries by Confirmed Cases",
         x = "Country", y = "Confirmed")
)

# -----------------------------------------------------------
# 2. BAR CHART — Top 10 Countries by Deaths
# -----------------------------------------------------------
top_deaths <- df %>% arrange(desc(deaths)) %>% slice_head(n = 10)

print(
  ggplot(top_deaths, aes(x = reorder(country, deaths), y = deaths)) +
    geom_col(fill = "firebrick") +
    coord_flip() +
    labs(title = "Top 10 Countries by Deaths",
         x = "Country", y = "Deaths")
)

# -----------------------------------------------------------
# 3. PIE CHART — WHO Region Distribution
# -----------------------------------------------------------
region_counts <- df %>% group_by(who_region) %>% summarise(n = n())

pie(region_counts$n,
    labels = paste(region_counts$who_region, " (", region_counts$n, ")"),
    main = "Number of Countries by WHO Region",
    col = rainbow(nrow(region_counts)))

# -----------------------------------------------------------
# 4. PIE CHART — Share of Confirmed Cases by WHO Region
# -----------------------------------------------------------
region_confirmed <- df %>% group_by(who_region) %>% summarise(total = sum(confirmed))

pie(region_confirmed$total,
    labels = paste(region_confirmed$who_region, " (",
                   round(region_confirmed$total / sum(region_confirmed$total)*100, 1), "%)"),
    main = "Share of Total Confirmed Cases by Region",
    col = rainbow(nrow(region_confirmed)))

# -----------------------------------------------------------
# 5. BOX PLOT — Deaths by WHO Region
# -----------------------------------------------------------
if ("who_region" %in% names(df)) {
  print(
    ggplot(df, aes(x = who_region, y = deaths)) +
      geom_boxplot(fill = "orange") +
      scale_y_log10(labels = comma) +
      labs(title = "Deaths by WHO Region (log scale)",
           x = "WHO Region", y = "Deaths")
  )
}

# -----------------------------------------------------------
# 6. HISTOGRAM — CFR Distribution
# -----------------------------------------------------------
print(
  ggplot(df %>% filter(cfr < 1), aes(x = cfr)) +
    geom_histogram(bins = 40, fill = "purple", alpha = 0.7) +
    labs(title = "CFR Distribution (<= 100%)",
         x = "Case Fatality Rate", y = "Countries")
)
