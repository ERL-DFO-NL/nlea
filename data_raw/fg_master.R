# FG biomass, abundance, ba with 95CI Run code line-by-line and check plots.
#  See ?FG_master for details.
library(tidyverse)

FG_master <- readr::read_csv("~/NLEA/nlea/data_raw/fg_master.csv")

# Make long
vars <- c("bmass", "abund", "sca.bmass", "ba")

dat <- FG_master |>
  mutate(.row = row_number())   # guards against duplicate gear/yr/fg combos

vals <- dat |>
  select(.row, gear, yr, fg, name, all_of(vars)) |>
  pivot_longer(all_of(vars),
               names_to  = "variable",
               values_to = "value")

errs <- dat |>
  select(.row, all_of(paste0(vars, ".sd"))) |>
  pivot_longer(-.row,
               names_to  = "error",
               values_to = "sd.value") |>
  mutate(variable = sub("\\.sd$", "", error))

FG_long <- vals |>
  left_join(errs, by = c(".row", "variable")) |>
  transmute(series = name,
            gear, yr, fg, variable, value,  sd.value)


# class(hake_recruitment_new) <- c("pacea_recruitment",
#                                  class(hake_recruitment_new))

FG_bmass.abund.ba <- FG_long

attr(FG_bmass.abund.ba, "axis_name") <-
  "RV index"

usethis::use_data(FG_bmass.abund.ba,
                    overwrite = TRUE)
