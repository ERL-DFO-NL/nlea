# nlea: Curated Ecosystem Data for the Newfoundland and Labrador Region

<!-- badges: start -->
[![R-CMD-check](https://github.com/ERL-DFO-NL/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ERL-DFO-NL/nlea/actions/workflows/R-CMD-check.yaml)
<!-- 
Commenting out as not yet set up
[![codecov](https://codecov.io/gh/ERL-DFO-NL/graph/badge.svg?token=93afkFJUVL)](https://codecov.io/gh/ERL-DFO-NL/nlea)
![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2FERL-DFO-NL%2Fnlea&label=VISITORS&countColor=%23263759&style=flat&labelStyle=lower) -->
<!-- badges: end -->

#### This is an experimental R package currently in development!
---
`nlea` proves curated data sets to support an Ecosystem Approach to Fisheries Management (EAFM) in Canada's Newfoundland and Labrador Region. It contains data sets used for ecosystem summaries and related of oceanographic, environmental, and biological data crucial for research stock assessment.

### Goal 
---
The goal is to:
- place all of the data used for ecosystem summaries and related indices
- create plotting functions for quick visualizations of data
- create plotting functions for use in ecosystem summaries

### Installation
---
You can install the development version of `nlea` from GitHub:

```r
# install.packages("remotes")
remotes::install_github("ERL-DFO-NL/nlea")
```

### Quick Start
---
This is currently under development but here is what we have so far.

```r
library(nlea)
library(ggplot2) #for customization

# 1. Load data (e.g. Newfoundland Climate Index)
data("nlci")

# 2. Look at data
head(nlci)

# 3. Quick plot
plot(nlci)
```

Available Data (development)
---
> List of where we are going

|Dataset   | Description | Source     |
|---------|-----|----------------|
| nlci   | Aggregated NL Climate Index (NLCI)  | [Cyr and Galbrath et al 2021](https://doi.org/10.20383/103.01670)  |
| nlci_sub     | Natural sign NLCI subindices  |  [Cyr and Galbrath et al 2021](https://doi.org/10.20383/103.01670) |
| fg_abundance | Abundance from RV survey of functional groups  | EcoSum Resdoc       |
| fg_biomass | Biomass from RV survey of functional groups  | EcoSum Resdoc       |
| fg_biomass_abundance_ratio | Biomass-Abundance ratio from RV survey of functional groups  | EcoSum Resdoc        |
| fg_scaled_biomass | Scaled biomass from RV survey of functional groups  | EcoSum Resdoc        |
| TBA | Zooplankton indices  | AZMP regional tech report       |
| TBA | Species biomass  | EcoSum Resdoc        |
| TBA | Biomass density by EPU  | EcoSum Resdoc        |
| TBA | Diets of key predators  | EcoSum Resdoc        |
| TBA | Stomach weights  | EcoSum Resdoc        |
| TBA | TCI vs catch ratio  | NAFO SAR        |
| TBA | landings by functional guilds  | NAFO SAR        |
| TBA | Fishing Effort  | Open data/Res doc        |


