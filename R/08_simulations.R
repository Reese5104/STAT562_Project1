script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
daily <- read_daily_data(); flights <- read_clean_data(); simulations <- 10000L
lambda <- mean(daily$delayed_flights); p_day <- mean(daily$over_three_delays)
p_major <- mean(daily$major_delay_day); p_flight <- sum(flights$delay_flight_count) / sum(flights$total_flights); r <- 5L
if (is.na(p_major)) stop("This aggregate dataset does not identify individual delays over 30 minutes. Use flight-level data for the geometric simulation.")
if (any(c(p_major, p_flight) == 0)) stop("A required success probability is zero; inspect the data and definitions.")
simulated <- tibble(
  poisson = rpois(simulations, lambda), binomial = rbinom(simulations, 10, p_day),
  geometric_days = rgeom(simulations, p_major) + 1L,
  negative_binomial_trials = rnbinom(simulations, r, p_flight) + r,
  hypergeometric = rhyper(simulations, sum(flights$delay_flight_count), sum(flights$total_flights - flights$delay_flight_count), min(100L, sum(flights$total_flights)))
)
write_csv(summarise_all(simulated, list(mean = mean, variance = var)), "output/results/simulation_summary.csv")
saveRDS(simulated, "output/results/simulations.rds")
