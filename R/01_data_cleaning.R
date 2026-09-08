script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))

raw_path <- "data/raw/flight_delays.csv"
if (!file.exists(raw_path)) {
  stop("Place a real CSV dataset at data/raw/flight_delays.csv before running.")
}

flights_raw <- read_csv(raw_path, show_col_types = FALSE, name_repair = "unique")
names(flights_raw) <- names(flights_raw) |> str_to_lower() |> str_replace_all("[^a-z0-9]+", "_") |> str_remove("_$")

# Inspect before deciding on exclusions.
print(dim(flights_raw)); print(head(flights_raw)); glimpse(flights_raw)
write_csv(enframe(colSums(is.na(flights_raw)), name = "variable", value = "missing_count"),
          "output/tables/missing_values_raw.csv")
write_csv(tibble(duplicate_rows = sum(duplicated(flights_raw))), "output/tables/duplicate_rows_raw.csv")

# Recognize either flight-level records or BTS-style airport/carrier/month aggregates.
date_candidates <- c("flight_date", "fl_date", "date", "departure_date")
delay_candidates <- c("dep_delay", "departure_delay", "departure_delay_minutes")
date_col <- intersect(date_candidates, names(flights_raw))[1]
delay_col <- intersect(delay_candidates, names(flights_raw))[1]
is_aggregate <- all(c("year", "month", "arr_flights", "arr_del15", "arr_delay") %in% names(flights_raw))

if (is_aggregate) {
  # This file is aggregated by airport, carrier, and month. `arr_del15` counts
  # arrival delays of 15+ minutes; `arr_delay` is total delay minutes.
  flights_cleaned <- flights_raw |>
    mutate(
      flight_date = make_date(as.integer(year), as.integer(month), 1L),
      total_flights = as.numeric(arr_flights),
      delay_flight_count = as.numeric(arr_del15),
      dep_delay_minutes = if_else(delay_flight_count > 0, as.numeric(arr_delay) / delay_flight_count, NA_real_),
      delayed = NA, delay_over_30 = NA, data_granularity = "airport-carrier-month aggregate"
    ) |>
    filter(!is.na(flight_date), !is.na(total_flights), !is.na(delay_flight_count),
           total_flights >= 0, delay_flight_count >= 0, delay_flight_count <= total_flights) |>
    distinct()
  date_col <- "year + month"; delay_col <- "arr_del15 (arrival delays of 15+ minutes)"
} else {
  if (is.na(date_col) || is.na(delay_col)) {
    stop("This file lacks both flight-level date/delay columns and the recognized BTS aggregate schema. See data/raw/DATA_SOURCE.md and update the candidate names if needed.")
  }
  flights_cleaned <- flights_raw |>
    mutate(
      flight_date = suppressWarnings(ymd(.data[[date_col]])),
      dep_delay_minutes = as.numeric(.data[[delay_col]]),
      delayed = !is.na(dep_delay_minutes) & dep_delay_minutes > 0,
      delay_over_30 = !is.na(dep_delay_minutes) & dep_delay_minutes > 30,
      total_flights = 1, delay_flight_count = as.numeric(delayed), data_granularity = "flight-level record"
    ) |>
    filter(!is.na(flight_date), !is.na(dep_delay_minutes)) |>
    distinct()
}

daily_delays <- flights_cleaned |>
  group_by(flight_date) |>
  summarise(
    flights = sum(total_flights), delayed_flights = sum(delay_flight_count),
    major_delay_day = if (is_aggregate) NA else any(delay_over_30),
    .groups = "drop"
  ) |>
  mutate(over_three_delays = delayed_flights > 3)

saveRDS(flights_cleaned, "data/cleaned/flights_cleaned.rds")
saveRDS(daily_delays, "data/cleaned/daily_delays.rds")
write_csv(daily_delays, "data/cleaned/daily_delays.csv")
write_csv(tibble(rows_raw = nrow(flights_raw), rows_cleaned = nrow(flights_cleaned),
                 date_column = date_col, delay_column = delay_col,
                 granularity = first(flights_cleaned$data_granularity)),
          "output/tables/preprocessing_summary.csv")
