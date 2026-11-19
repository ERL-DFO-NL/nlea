# FG biomass, abundance, ba with 95CI Run code line-by-line and check plots.
#  See ?FG_bmass.abund.ba for details.
library(dplyr)

FG_master <- readr::read_csv("~/NLEA/nlea/data_raw/fg_output_CI.csv")

# Make long
vars    <- c("bmass", "abund", "sca.bmass","ba")
ci_cols <- as.vector(outer(vars, c("ci2.5", "ci97.5"), paste, sep = "."))

# add any CI columns that don't exist yet as NA
dat <- FG_master
dat[setdiff(ci_cols, names(dat))] <- NA_real_

FG_long <- dat |>
  select(name, gear, yr, fg, all_of(vars), all_of(ci_cols)) |>
  rename_with(~ paste0(.x, ".value"), all_of(vars)) |>
  pivot_longer(
    cols          = -c(name, gear, yr, fg),
    names_to      = c("variable", ".value"),
    names_pattern = "^(.*)\\.(value|ci2\\.5|ci97\\.5)$"
  ) |>
  rename(series = name,
         year = yr)

# class(hake_recruitment_new) <- c("pacea_recruitment",
#                                  class(hake_recruitment_new))

FG_bmass.abund.ba <- FG_long

attr(FG_bmass.abund.ba, "axis_name") <-
  "RV index"

usethis::use_data(FG_bmass.abund.ba,
                    overwrite = TRUE)
