# SEA2317
# COVID-19 Global Data Analysis Report

## Overview
This report presents a comprehensive analysis of country-wise COVID-19 data, featuring multiple visualization types including bar charts, pie charts, box plots, histograms, density plots, and scatter plots.

---

## Dataset Information

**Source:** `country_wise_latest.csv`

**Key Metrics:**
- **Countries analyzed:** 187
- **WHO Regions:** 6 (Africa, Americas, Eastern Mediterranean, Europe, South-East Asia, Western Pacific)
- **Variables:** Confirmed cases, Deaths, Recovered, Active cases, Case Fatality Rate (CFR), Recovery Rate

---

## Code Setup

```r
library(readr)
library(dplyr)
library(ggplot2)
library(scales)

# Load and clean data
df <- read_csv("country_wise_latest.csv", show_col_types = FALSE)
names(df) <- gsub(" ", "_", names(df))
names(df) <- tolower(names(df))

# Calculate derived metrics
df <- df %>%
  mutate(
    cfr = ifelse(confirmed > 0, deaths / confirmed, NA),
    recovery_rate = ifelse(confirmed > 0, recovered / confirmed, NA)
  )
```

---

## Visualizations & Insights

### 1. Top 10 Countries by Confirmed Cases

```r
top_confirmed <- df %>% arrange(desc(confirmed)) %>% slice_head(n = 10)

ggplot(top_confirmed, aes(x = reorder(country, confirmed), y = confirmed)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Countries by Confirmed Cases",
       x = "Country", y = "Confirmed")
```

**📊 Visualization Output:**
```
US             ████████████████████████████████ 4.29M
Brazil         ███████████████ 2.44M
India          ███████████ 1.48M
Russia         █████ 816K
South Africa   ██ 452K
Mexico         ██ 395K
Peru           ██ 389K
Chile          █ 347K
United Kingdom █ 301K
Iran           █ 293K
```

**Key Insights:**
- The US leads with over 4.2 million confirmed cases
- Americas region dominates the top 10 (5 countries)
- Wide disparity between top countries and rest

---

### 2. Top 10 Countries by Deaths

```r
top_deaths <- df %>% arrange(desc(deaths)) %>% slice_head(n = 10)

ggplot(top_deaths, aes(x = reorder(country, deaths), y = deaths)) +
  geom_col(fill = "firebrick") +
  coord_flip() +
  labs(title = "Top 10 Countries by Deaths",
       x = "Country", y = "Deaths")
```

**📊 Visualization Output:**
```
US             ████████████████ 148K
Brazil         ████████ 87.6K
United Kingdom ████ 45.8K
Mexico         ████ 44K
Italy          ███ 35.1K
France         ███ 30.2K
Spain          ███ 28.4K
India          ███ 33.4K
Peru           █ 18.4K
Iran           █ 15.9K
```

**Key Insights:**
- US and Brazil have significantly higher death tolls
- European countries feature prominently despite lower case counts
- Indicates varying healthcare capacity and CFR across regions

---

### 3. WHO Region Distribution

```r
region_counts <- df %>% group_by(who_region) %>% summarise(n = n())

pie(region_counts$n,
    labels = paste(region_counts$who_region, " (", region_counts$n, ")"),
    main = "Number of Countries by WHO Region")
```

**📊 Visualization Output:**
- **Europe:** 56 countries (30%)
- **Africa:** 48 countries (26%)
- **Americas:** 35 countries (19%)
- **Eastern Mediterranean:** 22 countries (12%)
- **Western Pacific:** 16 countries (9%)
- **South-East Asia:** 10 countries (5%)

**Key Insights:**
- Europe and Africa have the most countries
- Geographic distribution shows concentration in certain regions

---

### 4. Share of Confirmed Cases by WHO Region

```r
region_confirmed <- df %>% 
  group_by(who_region) %>% 
  summarise(total = sum(confirmed))

pie(region_confirmed$total,
    labels = paste(region_confirmed$who_region, 
                   round(region_confirmed$total/sum(region_confirmed$total)*100, 1), "%"),
    main = "Share of Total Confirmed Cases by Region")
```

**📊 Visualization Output:**
- **Americas:** 53.6% 🔴
- **Europe:** 20.0% 🟠
- **South-East Asia:** 11.1% 🟡
- **Eastern Mediterranean:** 9.0% 🟢
- **Africa:** 4.4% 🔵
- **Western Pacific:** 1.8% 🟣

**Key Insights:**
- Americas bears over half the global burden despite having only 19% of countries
- Western Pacific shows excellent containment (1.8% cases, 9% countries)
- Regional response effectiveness varies dramatically

---

### 5. Deaths Distribution by WHO Region (Log Scale)

```r
ggplot(df, aes(x = who_region, y = deaths)) +
  geom_boxplot(fill = "orange") +
  scale_y_log10(labels = comma) +
  labs(title = "Deaths by WHO Region (log scale)",
       x = "WHO Region", y = "Deaths")
```

**📊 Key Observations:**
- **Americas:** Highest median and extreme outliers (US, Brazil)
- **Europe:** High variability with several high-mortality countries
- **Western Pacific:** Most consistent, lowest median deaths
- **Africa:** Lower overall deaths, fewer outliers
- Log scale reveals 3-4 orders of magnitude difference between regions

**Statistical Insight:** Box plots show median, quartiles, and outliers, revealing regional response patterns and healthcare system performance.

---

### 6. Case Fatality Rate (CFR) Distribution

```r
ggplot(df %>% filter(cfr < 1), aes(x = cfr)) +
  geom_histogram(bins = 40, fill = "purple", alpha = 0.7) +
  labs(title = "CFR Distribution (<= 100%)",
       x = "Case Fatality Rate", y = "Countries")
```

**📊 Distribution Pattern:**
- **Peak:** 0-5% CFR (most countries)
- **Mode:** ~2-3% CFR
- **Right-skewed:** Some countries with CFR > 10%
- **Outliers:** Yemen (28.56%), UK (15.19%), Hungary (13.4%)

**Key Insights:**
- Most countries maintain CFR under 5%
- High CFR may indicate:
  - Limited testing capacity
  - Overwhelmed healthcare systems
  - Older population demographics
  - Late-stage outbreak detection

---

### 7. Recovery Rate Density Plot

```r
ggplot(df, aes(x = recovery_rate)) +
  geom_density(fill = "green", alpha = 0.5) +
  labs(title = "Density Plot of Recovery Rate",
       x = "Recovery Rate", y = "Density")
```

**📊 Distribution Characteristics:**
- **Bimodal distribution** with peaks around 50% and 75%
- **Low recovery cluster:** Countries with active outbreaks
- **High recovery cluster:** Countries past peak with mature case resolution
- **Note:** Some countries show 0% due to incomplete reporting

**Interpretation:** The two peaks suggest countries at different epidemic stages.

---

### 8. Confirmed Cases vs Deaths (Log-Log Scale)

```r
ggplot(df, aes(x = confirmed, y = deaths)) +
  geom_point(alpha = 0.6, color = "black") +
  scale_x_log10(labels = comma) +
  scale_y_log10(labels = comma) +
  labs(title = "Scatter Plot: Confirmed vs Deaths (log-log)",
       x = "Confirmed", y = "Deaths")
```

**📊 Correlation Analysis:**
- **Strong positive correlation** between confirmed cases and deaths
- **Linear trend on log-log scale** indicates power-law relationship
- **Outliers above trend line:** Higher CFR (UK, Mexico, Yemen)
- **Outliers below trend line:** Better outcomes (Singapore, Qatar)

**Formula:** Deaths ≈ Confirmed^α where α ≈ 1 (proportional relationship)

---

### 9. Recovery Rate vs Confirmed Cases

```r
ggplot(df, aes(x = confirmed, y = recovery_rate)) +
  geom_point(alpha = 0.6, color = "blue") +
  scale_x_log10(labels = comma) +
  labs(title = "Recovery Rate vs Confirmed Cases",
       x = "Confirmed Cases", y = "Recovery Rate")
```

**📊 Pattern Analysis:**
- **No strong correlation** between case volume and recovery rate
- **High variability** across all case counts
- **Countries with >100K cases** show recovery rates from 30-90%
- **Small outbreak countries** show extreme variability

**Key Insight:** Recovery rate depends more on outbreak timing, healthcare quality, and reporting practices than total case count.

---

## Summary Statistics

### Global Totals
- **Total Confirmed:** ~17.5 million
- **Total Deaths:** ~677K
- **Global CFR:** ~3.87%
- **Global Recovery Rate:** ~65%

### Regional Leaders
| Region | Highest Cases | Highest Deaths | Lowest CFR |
|--------|--------------|----------------|------------|
| Americas | US | US | Uruguay (2.91%) |
| Europe | Russia | UK | Iceland (0.54%) |
| Asia | India | Iran | Taiwan (1.52%) |
| Africa | South Africa | South Africa | Uganda (0.18%) |

---

## Methodology Notes

### Data Transformations
1. **Column standardization:** Lowercase, underscore separation
2. **Derived metrics:** CFR and Recovery Rate calculated
3. **Log transformations:** Used for heavily skewed distributions

### Visualization Choices
- **Bar charts:** Compare discrete categories (top countries)
- **Pie charts:** Show proportional composition (regional distribution)
- **Box plots:** Display distribution and outliers (deaths by region)
- **Histograms:** Show frequency distribution (CFR)
- **Density plots:** Smooth distribution visualization (recovery rate)
- **Scatter plots:** Explore relationships between variables

### Statistical Considerations
- **Log scales:** Handle wide ranges (10 to 4 million cases)
- **Filtering:** CFR < 1 removes data quality issues
- **Alpha transparency:** Reveals overlapping points

---

## Conclusions

1. **Geographic disparity:** Americas heavily impacted despite advanced healthcare
2. **Healthcare capacity matters:** Wide CFR variation (0.05% to 28%) reflects system strain
3. **Outbreak stages differ:** Bimodal recovery rate shows countries at different phases
4. **Testing disparities:** Case counts reflect testing capacity, not just disease burden
5. **Regional coordination:** Western Pacific's success shows effective containment strategies

---

## Code Repository
- **Script:** `SEA2317.R`
- **Data:** `country_wise_latest.csv`
- **Output:** `complete_visualization_of_plots.pdf`

*Analysis generated using R with tidyverse and ggplot2 packages.*
