# STAT 562 Project 1: Discrete Random Variables

This project analyzes a real flight-delay dataset with Poisson, Binomial,
Geometric, Negative Binomial, and Hypergeometric models. It is intentionally a
reproducible analysis template: no dataset values, statistical results, or
literature citations have been invented.

## Start here

1. Download a credible flight-delay dataset and save it as
   `data/raw/flight_delays.csv`.
2. Record the source URL, download date, coverage period, and data dictionary
   in `data/raw/DATA_SOURCE.md` (create this file from the template below).
3. In `R/01_data_cleaning.R`, confirm the detected date and delay columns and
   the delayed-flight definition. The default is `departure delay > 0` minutes.
4. Run the scripts in numeric order, from the project root:

   ```r
   source("R/01_data_cleaning.R")
   source("R/02_descriptive_statistics.R")
   source("R/03_poisson.R")
   source("R/04_binomial.R")
   source("R/05_geometric.R")
   source("R/06_negative_binomial.R")
   source("R/07_hypergeometric.R")
   source("R/08_simulations.R")
   source("R/09_visualizations.R")
   ```

Required packages: `tidyverse`, `lubridate`, and `broom`.

## Dataset notes template

```markdown
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
```

## Output and deliverables

Generated figures are written to `output/figures/`; tables and model results go
to `output/tables/` and `output/results/`. Add a real academic journal article
and structured notes under `literature/`; build the nine-slide presentation in
`presentation/` and the written report in `report/` only after the actual
analysis is complete.

The scripts distinguish empirical data, theoretical calculations, and
simulations. Review distribution assumptions, goodness-of-fit diagnostics, and
all interpretations before submitting.
