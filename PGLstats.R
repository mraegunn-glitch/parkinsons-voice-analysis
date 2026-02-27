# WELCOME! Script meant to analyze CSV obtained from Praat Script
# input: CSV with 2-group of acoustic features extracted from waveform files
# output: descriptive stats, MANOVA + subsequent t-tests (w. visualizations)
# written by Melissa Rae Gunning [6 Dec 2025]

# ============================
# RELEVANT PACKAGES
# ============================
library(tidyverse) # basic business
library(effectsize) # for Cohen's d and 95% CI
library(dplyr) # some other stats
library(ggplot2) # make it look pretty
# ============================
# LOAD DATA
# ============================
df <- read_csv("/Users/melissarae/Desktop/Mini Proj (PGL)/PD_HC/voice_measures.csv")
# group properly
df$group <- factor(df$group, levels = c("PwPD", "HC"))

# Acoustic features of interest
acoustic_vars <- df %>%
  select(meanF0, sdF0, jitterLocal, rap, ppq5,shimmerLocal, apq5, hnr, nhr, duration)

# viewing the distributions
acoustic_long <- df %>%
  pivot_longer(
    cols = c(meanF0, sdF0, jitterLocal, rap, ppq5, shimmerLocal, apq5, hnr, nhr),
    names_to = "measure",
    values_to = "value"
  )

acoustic_long %>%
  group_by(measure) %>%
  mutate(mean_diff = mean(value[group == "PwPD"], na.rm = TRUE) -
           mean(value[group == "HC"], na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(x = group, y = value, fill = group)) +
  geom_violin(trim = FALSE, alpha = 0.5) +
  geom_boxplot(width = 0.2, outlier.shape = NA) +
  facet_wrap(~ reorder(measure, mean_diff), scales = "free_y") +
  theme_minimal()

# ============================
# DESCRIPTIVE
# ============================
acoustic_names <- c("meanF0", "sdF0", "jitterLocal", "rap", "ppq5",
                    "shimmerLocal", "apq5", "hnr", "nhr", "duration")

summ_df <- df %>%
  group_by(group) %>%
  summarise(
    across(
      all_of(acoustic_names),
      list(mean = mean,
           sd   = sd),
      .names = "{.col}_{.fn}"
    )
  )

print(summ_df)
# ============================
# MANOVA
# ============================

# fit
manova_model <- manova(as.matrix(acoustic_vars) ~ group, data = df)
summary(manova_model, test = "Pillai")  # Pillai's Trace preferred

# ============================
# FOLLOW-UP TESTS (t-tests)
#    *with Holm correction
# ============================

# independent-samples t-tests for each variable
t_results <- lapply(acoustic_vars, function(var) {
  t.test(var ~ df$group, var.equal = FALSE)  # Welch t-test
})
summary(t_results)
# Cohen's d results
d_results <- lapply(acoustic_vars, function(var) {
  cohens_d(var ~ df$group, ci = 0.95)
})

# raw p-values
raw_p <- sapply(t_results, function(x) x$p.value)
names(raw_p) <- names(acoustic_vars)

# Holm correction
holm_p <- p.adjust(raw_p, method = "holm")

# Cohen's d values
d_values <- sapply(d_results, function(x) x$Cohens_d)

# extract 95% CI for d
d_lower <- sapply(d_results, function(x) x$CI_low)
d_upper <- sapply(d_results, function(x) x$CI_high)

# combine into table
followup_table <- data.frame(
  Variable = names(acoustic_vars),
  Raw_p = raw_p,
  Holm_corrected_p = holm_p,
  Cohens_d = d_values,
  CI_lower = d_lower,
  CI_upper = d_upper
)

print(followup_table)

# or other pretty visualizations
means_acoustic <- acoustic_long %>%
  group_by(group, acoustic_names) %>%
  summarize(
    mean = mean(Value, na.rm = TRUE),
    sd = sd(Value, na.rm = TRUE)
  )

ggplot(means_acoustic, aes(x = Variable, y = mean, color = group, group = group)) +
  geom_point(position = position_dodge(width = 0.4), size = 3) +
  geom_errorbar(
    aes(ymin = mean - sd, ymax = mean + sd),
    width = 0.2,
    position = position_dodge(width = 0.4)
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))