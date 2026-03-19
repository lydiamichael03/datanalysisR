# Data Dictionary

## File: `data/raw/gonorrhea_us_2000_2022.csv`

**Source:** CDC STI Surveillance, Table 1 and Table 6 (https://www.cdc.gov/std/statistics)  
**Unit of observation:** Year × Sex × Age group  
**Coverage:** United States, 2000–2022

| Variable | Type | Description | Values / Units |
|----------|------|-------------|----------------|
| `year` | Integer | Surveillance year | 2000–2022 |
| `sex` | Character | Biological sex | "Male", "Female" |
| `age_group` | Character | Age category | "15-19", "20-24", "25-29", "30-34", "35-44", "45-54", "55-64", "65+" |
| `cases` | Integer | Number of reported gonorrhea cases | Count |
| `rate` | Numeric | Case rate per 100,000 population | Per 100,000 |
| `population` | Integer | Estimated mid-year population | Count |

---

## File: `data/processed/gonorrhea_clean.csv`

Cleaned and reshaped version of the raw data. Missing values removed, rates recalculated where inconsistent.

| Variable | Type | Description |
|----------|------|-------------|
| `year` | Integer | Surveillance year |
| `sex` | Factor | "Male" / "Female" |
| `age_group` | Factor | Age group, ordered |
| `cases` | Integer | Reported cases |
| `rate` | Numeric | Cases per 100,000 |
| `rate_log` | Numeric | Log-transformed rate (log10) |

---

## File: `data/processed/gonorrhea_simulated.csv`

Output from stochastic SIS (Susceptible–Infectious–Susceptible) simulation model in `scripts/02_data_simulation.R`.

| Variable | Type | Description |
|----------|------|-------------|
| `sim_id` | Integer | Simulation run ID (1–100) |
| `time` | Integer | Time step (weeks) |
| `S` | Numeric | Proportion susceptible |
| `I` | Numeric | Proportion infectious |
| `scenario` | Character | Transmission scenario: "baseline", "high_beta", "intervention" |
| `beta` | Numeric | Transmission rate parameter |
| `gamma` | Numeric | Recovery rate parameter |
| `R0` | Numeric | Basic reproduction number (beta/gamma) |
