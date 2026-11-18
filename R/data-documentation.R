#' Functional Group Indexes (FG_bmass.abund.ba)
#'
#' Indexes of biomass, abundance, and biomass ratio at the functional group level.
#'
#' This dataset was updated on November 18, 2026 and upto the Fall 2025 survey
#'
#' @format An `tbl_df` object with:
#' \describe{
#'   \item{data}{A tibble with columns:
#'     \describe{
#'       \item{series}{Ecosystem Production Unit and Season including 2J3KL (character)}
#'       \item{gear}{Name of gear (numeric, 1–12)}
#'       \item{yr}{Year)}
#'       \item{fg}{Functional Group}
#'       \item{variable}{Variable Name (bmass-biomass in tonnes, abund-abundance in 1000s, sca.bmass-scaled biomass in campelan units, ba-ratio of sca.bmass/abund)}
#'       \item{value}{Index}
#'       \item{ci2.5}{Lower 2.5% confidence interval assuming gamma distribution}
#'       \item{ci97.5}{Upper 97.5% confidence interval assuming gamma distribution}
#' }
#' @name FG_bmass.abund.ba
#' @docType data
#' @author Hannah Munro
#' @source Generated in data_raw/fg_master.R
#' @references Add this once published
"FG_bmass.abund.ba"

#' Newfoundland and Labrador Climate Index (ea_data)
#'
#' The Newfoundland and Labrador (NL) climate index aims to describe the environmental conditions on the NL shelf
#'  and in the Northwest Atlantic as a whole. It consists of annual normalized anomalies of 10 subindices with
#'  equal contribution: Winter North Atlantic Oscillation, air temperature, sea ice, icebergs, sea surface temperature,
#'  vertically-averaged temperature and salinity at Station~27, cold intermediate layer (CIL) core temperature at Station~27,
#'  CIL area on 3 hydrographic sections and bottom temperature on the NL shelf.
#'  This index runs from 1951 to 2019 and will be updated annually.
#'
#' @format An `ea_data` object with:
#' \describe{
#'    \item{data}{A tibble:
#'     \describe{
#'       \item{year}{year (numeric)}
#'       \item{nlci_value}{nlci_value (numeric)}
#'     }
#'   }
#'   \item{meta}{A named list with:
#'     \describe{
#'       \item{data_type}{"NL Climate Index"}
#'       \item{region}{ "Newfoundland and Labrador Shelf"}
#'       \item{location_descriptor}{"Newfoundland and Labrador Shelf"}
#'       \item{units}{""}
#'       \item{species}{"subindices: Winter North Atlantic Oscillation, air temperature, sea ice, icebergs, sea surface temperature, vertically-averaged temperature and salinity at Station~27, cold intermediate layer (CIL) core temperature at Station~27, CIL area on 3 hydrographic sections and bottom temperature on the NL shelf"}
#'       \item{source_citation}{Character. "Cyr, F. and Galbraith, P. S. 2021. A climate index for the Newfoundland and Labrador shelf, Earth Syst. Sci. Data, 13, 1807–1828, https://doi.org/10.5194/essd-13-1807-2021"}
#'       \item{original_value_col}{Character. "nlci"}
#'       \item{comment}{Character. "Data and associated sources are from https://doi.org/10.20383/101.0301"}
#'     }
#'   }
#' }
#' @docType data
#' @name nlci
#' @author Jamie C. Tam
#' @source \url{https://doi.org/10.20383/101.0301}
"nlci"

