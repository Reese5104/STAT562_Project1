# Data source

- Source URL:
- Publisher / owner:
- Download date:
- Coverage period:
- Unit of observation:
- Date column used:
- Departure-delay column used (minutes):
- Definition of a delayed flight:
- Exclusions and justification:

## Detected schema note

The current `flight_delays.csv` is an airport/carrier/month aggregate dataset.
It records total arriving flights (`arr_flights`) and arrival delays of at least
15 minutes (`arr_del15`), but not individual flight delay times or daily
observations. It supports aggregate-count analyses, but a flight-level dataset
with a date and delay-in-minutes field is required for the assignment's exact
daily and `> 30 minute` geometric questions.
