script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
daily <- read_daily_data(); n_days <- 10L
p_estimate <- mean(daily$over_three_delays)
binomial_results <- tibble(n = n_days, p = p_estimate, expected_value = n_days * p_estimate,
  variance = n_days * p_estimate * (1 - p_estimate), probability_no_successes = dbinom(0, n_days, p_estimate),
  probability_at_least_one = pbinom(0, n_days, p_estimate, lower.tail = FALSE))
write_csv(binomial_results, "output/results/binomial_results.csv")
# M_X(t) = (1 - p + p * exp(t))^n. Discuss fixed trials, binary outcomes, constant p, independence.
