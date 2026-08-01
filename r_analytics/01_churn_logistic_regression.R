# ==============================================================================
# OTT CONTENT INTELLIGENCE & VIEWER ANALYTICS PLATFORM
# R Statistical Analytics Module: Churn Logistic Regression & Demand Forecast
# Author: Principal Data Analytics Architect
# ==============================================================================

suppressPackageStartupMessages({
  library(stats)
  library(utils)
})

cat("------------------------------------------------------------------------\n")
cat("1. LOGISTIC REGRESSION: SUBSCRIBER CHURN RISK MODELING\n")
cat("------------------------------------------------------------------------\n")

# Synthetic data generation for statistical demo
set.seed(42)
n <- 1000
buffering_events <- rpois(n, lambda = 2.5)
watch_hours_weekly <- rnorm(n, mean = 12, sd = 4)
price_tier <- sample(c(4.99, 8.99, 13.99, 19.99), n, replace = TRUE)
customer_tenure_months <- sample(1:24, n, replace = TRUE)

# Calculate log-odds of churn
log_odds <- -1.5 + 0.35 * buffering_events - 0.12 * watch_hours_weekly + 0.05 * price_tier - 0.08 * customer_tenure_months
prob_churn <- 1 / (1 + exp(-log_odds))
churn_status <- rbinom(n, size = 1, prob = prob_churn)

df_churn <- data.frame(
  churn = churn_status,
  buffering_events = buffering_events,
  watch_hours = watch_hours_weekly,
  price_tier = price_tier,
  tenure = customer_tenure_months
)

# Fit Logistic Regression Model
churn_model <- glm(churn ~ buffering_events + watch_hours + price_tier + tenure, 
                   data = df_churn, family = binomial(link = "logit"))

cat("\n--- Churn Logistic Regression Summary ---\n")
print(summary(churn_model))

# Calculate Odds Ratios
cat("\n--- Odds Ratios (95% CI) ---\n")
odds_ratios <- exp(cbind(OR = coef(churn_model), confint.default(churn_model)))
print(round(odds_ratios, 4))


cat("\n------------------------------------------------------------------------\n")
cat("2. TIME-SERIES DEMAND FORECASTING: WEEKLY WATCH HOURS\n")
cat("------------------------------------------------------------------------\n")

# Generate weekly time series data
weeks <- 78 # 1.5 years
trend <- seq(100000, 180000, length.out = weeks)
seasonality <- 15000 * sin(2 * pi * (1:weeks) / 12)
noise <- rnorm(weeks, mean = 0, sd = 4000)
watch_hours_ts <- ts(trend + seasonality + noise, frequency = 52, start = c(2025, 1))

# Fit Holt-Winters Exponential Smoothing Model
hw_model <- HoltWinters(watch_hours_ts, gamma = FALSE)

cat("\n--- Holt-Winters Exponential Smoothing Summary ---\n")
print(hw_model)

# 12-Week Forecast
cat("\n--- 12-Week Watch Time Demand Forecast ---\n")
predict_hw <- predict(hw_model, n.ahead = 12, prediction.interval = TRUE, level = 0.95)
print(round(predict_hw, 2))


cat("\n------------------------------------------------------------------------\n")
cat("3. HYPOTHESIS TESTING: ANOVA (BUFFERING RATIO ACROSS DEVICE CATEGORIES)\n")
cat("------------------------------------------------------------------------\n")

device_categories <- factor(sample(c("Smart TV", "Mobile", "Desktop", "Tablet"), n, replace = TRUE))
buffer_ratio <- rnorm(n, mean = 2.1, sd = 0.8) + ifelse(device_categories == "Mobile", 0.6, 0.0)

anova_model <- aov(buffer_ratio ~ device_categories)
cat("\n--- One-Way ANOVA Summary: Buffer Ratio by Device ---\n")
print(summary(anova_model))

cat("\nR Statistical Analysis Pipeline Executed Successfully.\n")
