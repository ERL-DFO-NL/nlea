# FG biomass, abundance, ba with 95CI Run code line-by-line and check plots.
#  See ?FG_bmass.abund.ba for details.
library(dplyr)

FG_master <- readr::read_csv(paste0(here::here(),
                                    "/data_raw/fg_output_CI.csv"))

# Make long
vars    <- c("bmass", "abund", "sca.bmass","ba")
ci_cols <- as.vector(outer(vars, c("ci2.5", "ci97.5"), paste, sep = "."))

# add any CI columns that don't exist yet as NA
dat <- FG_master
dat[setdiff(ci_cols, names(dat))] <- NA_real_

FG_long <- dat |>
  select(name, gear, yr, fg, all_of(vars), all_of(ci_cols)) |>
  rename_with(~ paste0(.x, ".value"), all_of(vars)) |>
  tidyr::pivot_longer(
    cols          = -c(name, gear, yr, fg),
    names_to      = c("variable", ".value"),
    names_pattern = "^(.*)\\.(value|ci2\\.5|ci97\\.5)$"
  ) |>
  rename(series = name,
         year = yr,
         low = "ci2.5",
         high = "ci97.5")

# class(hake_recruitment_new) <- c("pacea_recruitment",
#                                  class(hake_recruitment_new))

fg_biomass <- filter(FG_long,
                     variable == "bmass") %>%
  select(-"variable") %>%
  mutate(series = factor(series),
         gear = factor(gear),
         fg = factor(fg))

fg_abundance <- filter(FG_long,
                       variable == "abund") %>%
  select(-"variable") %>%
  mutate(series = factor(series),
         gear = factor(gear),
         fg = factor(fg))

fg_scaled_biomass <- filter(FG_long,
                            variable == "sca.bmass") %>%
  select(-"variable") %>%
  mutate(series = factor(series),
         gear = factor(gear),
         fg = factor(fg))

fg_biomass_abundance_ratio <- filter(FG_long,
                                     variable == "ba") %>%
  select(-"variable") %>%
  mutate(series = factor(series),
         gear = factor(gear),
         fg = factor(fg))

#attr(fg_biomass, "axis_name") <-
#  "RV index"

usethis::use_data(fg_biomass,
                  overwrite = TRUE)

usethis::use_data(fg_abundance,
                  overwrite = TRUE)

usethis::use_data(fg_scaled_biomass,
                  overwrite = TRUE)

usethis::use_data(fg_biomass_abundance_ratio,
                  overwrite = TRUE)
