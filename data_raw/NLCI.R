# Newfoundland and Labrador Climate index
# Run code line-by-line and check plots.
#  See ?NLCI for details.

library(dplyr)
library(tidyverse)

# From Fred Cyr and Peter Galbraith.
# data-raw file created by Hannah Munro

# The NL Climate Index is included in the AZMP Atlantic zone report. Data is stored as .csv files here: https://doi.org/10.20383/101.0301

# Citation:
# Cyr, F. and Galbraith, P. S.: A climate index for the Newfoundland and Labrador shelf, Earth Syst. Sci. Data, 13, 1807–1828, https://doi.org/10.5194/essd-13-1807-2021, 2021.

# This the final analysed NL climate index AND all fields natural signs.

# This data raw process begins with downloading the latest .csv file into a local download folder for the combined index and all fields natural signs.


NLCI_data_raw <-
  readr::read_csv("data_raw/NL_climate_index.csv") #df with 2 variables

NLCI_data_all <-
  readr::read_csv("data_raw/NL_climate_index_all_fields_natural_signs.csv") #df with 11 variables

#all to lower case

NLCI <- NLCI_data_raw |>
  transmute(year = Year,
        variable ="nlci",
        value = `Climate index`
         )

NLCI_sub <- NLCI_data_all|>
      pivot_longer(cols = (-Year),
                   values_to = "value",
                   names_to = "variable") |>
      transmute(year = Year,
                value,
                variable = variable %>%
                  str_replace_all("[. _]+", "_") %>%
                  str_remove_all("^_|_$") |>  # Optional: removes leading or trailing underscores
                  str_to_lower())

nlci <- NLCI
nlci_sub <- NLCI_sub

class(nlci) <- c("nlea_nlci",
                 class(nlci))

class(nlci_sub) <- c("nlea_nlci_sub",
                     class(nlci_sub))

usethis::use_data(nlci,
                  overwrite = TRUE)
usethis::use_data(nlci_sub,
                  overwrite = TRUE)
