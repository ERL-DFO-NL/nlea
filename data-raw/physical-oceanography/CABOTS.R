# Bottom Temp and Salinity from CABOTS index
# Run code line-by-line and check plots.
#  See ?CABOTS for details.

library(dplyr)

# From Jon Coyne and Fred Cyr.
# data-raw file created by Hannah Munro

# The NL Climate Index is included in the AZMP Atlantic zone report. Data is stored as .csv files here: https://doi.org/10.20383/101.0301

# Citation:
# ????

# This the final analysed NL climate index AND all fields natural signs.

# This data raw process begins with downloading the latest .csv file into a local download folder for the combined index and all fields natural signs.

NLCI_data_raw <-
  readr::read_csv("data_raw/NL_climate_index.csv") #df with 2 variables

NLCI_data_all <-
  readr::read_csv("data_raw/NL_climate_index_all_fields_natural_signs.csv") #df with 11 variables


NLCI <- NLCI_data_raw |>
  transmute(year = Year,
        variable ="nlci",
        value = `Climate index`
         ) |>
  bind_rows(
    NLCI_data_all |>
      pivot_longer(cols = (-Year),
                   values_to = "value",
                   names_to = "variable") |>
      rename(year = Year)
  )

nlci <- NLCI
usethis::use_data(nlci,
                  overwrite = TRUE)
