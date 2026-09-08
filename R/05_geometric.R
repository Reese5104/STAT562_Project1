script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
daily <- read_daily_data()
p_estimate <- mean(daily$major_delay_day)
if (is.na(p_estimate)) stop("This aggregate dataset does not identify whether an individual flight exceeded 30 minutes. Use flight-level delay data for the required geometric analysis.")
if (p_estimate == 0) stop("No days exceed 30 minutes; geometric model cannot be estimated.")
geometric_results <- tibble(p = p_estimate, expected_wait_days = 1 / p_estimate,
  variance = (1 - p_estimate) / p_estimate^2, probability_first_day = p_estimate,
  probability_wait_over_5_days = pgeom(4, p_estimate, lower.tail = FALSE))
write_csv(geometric_results, "output/results/geometric_results.csv")
# Uses first-success convention X = 1,2,...; R's dgeom/rgeom count failures, so use X - 1.
