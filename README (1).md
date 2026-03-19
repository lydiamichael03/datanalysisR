# Gonorrhea Surveillance and Trend Analysis in the United States (2000–2022)

## Project Description

This project analyzes gonorrhea (*Neisseria gonorrhoeae*) surveillance data from the CDC's STI National Data Reporting System. It explores temporal and demographic trends in gonorrhea case rates, simulates outbreak scenarios under varying transmission parameters, and visualizes geographic disparities.

---

## Author

**[Your Name]**  
Department of [Your Department]  
[Your Institution]  
📧 [your.email@institution.edu]

---

## Research Question / Objectives

1. How have gonorrhea case rates changed in the United States from 2000 to 2022, and do trends differ by sex and age group?
2. What demographic groups are disproportionately affected?
3. Under simulated transmission scenarios, what intervention thresholds could reduce incidence most effectively?

---

## Data Source and Description

**Source:** [CDC STI Surveillance Data](https://www.cdc.gov/std/statistics/default.htm)

| File | Description |
|------|-------------|
| `data/raw/gonorrhea_us_2000_2022.csv` | Annual case counts and rates by sex and age group, United States, 2000–2022 |
| `data/processed/gonorrhea_clean.csv` | Cleaned and reshaped dataset ready for analysis |
| `data/processed/gonorrhea_simulated.csv` | Simulated incidence data from stochastic transmission model |

See `data/data_dictionary.md` for full variable descriptions.

---

## Repository Structure

```
gonorrhea_project/
├── README.md
├── .gitignore
├── data/
│   ├── data_dictionary.md
│   ├── raw/
│   │   └── gonorrhea_us_2000_2022.csv
│   └── processed/
│       ├── gonorrhea_clean.csv
│       └── gonorrhea_simulated.csv
├── scripts/
│   ├── 01_data_exploration.R
│   └── 02_data_simulation.R
└── output/
    ├── figures/
    │   ├── trend_by_sex.png
    │   ├── trend_by_age.png
    │   └── simulation_outcomes.png
    └── reports/
        └── gonorrhea_analysis_report.html
```

---

## How to Run

1. Clone this repository
2. Open R (≥ 4.2.0) and install required packages:
   ```r
   install.packages(c("tidyverse", "ggplot2", "dplyr", "readr", "knitr", "rmarkdown"))
   ```
3. Run scripts in order:
   ```r
   source("scripts/01_data_exploration.R")
   source("scripts/02_data_simulation.R")
   ```

---

## Deliverables

- 📊 [Figures](output/figures/)
- 📄 [Analysis Report](output/reports/gonorrhea_analysis_report.html)

---

## AI Tool Disclosure

Portions of this project were developed with assistance from Claude (Anthropic), an AI assistant. All code was reviewed and validated by the author. AI assistance was used for: script structure, documentation formatting, and simulation model setup.
...This is a line from RStudio...
---

## References

- Centers for Disease Control and Prevention. (2023). *Sexually Transmitted Disease Surveillance 2022*. Atlanta: U.S. Department of Health and Human Services.
- Anderson, R.M., & May, R.M. (1991). *Infectious Diseases of Humans: Dynamics and Control*. Oxford University Press.
- Chesson, H.W., et al. (2021). The estimated direct lifetime medical costs of sexually transmitted infections acquired in the United States in 2018. *Sexually Transmitted Diseases*, 48(4), 215–221.
