#' Functional Group Indexes (fg_biomass, fg_abundance, fg_scaled_biomass, fg_biomass_abundance_ratio)
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
#' @docType data
#' @author Hannah Munro
#' @source Generated in data_raw/fg_master.R
#' @references Add this once published
"fg_biomass"

##' @rdname fg_biomass
"fg_abundance"

##' @rdname fg_biomass
"fg_scaled_biomass"

##' @rdname fg_biomass
"fg_biomass_abundance_ratio"

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
#'       \item{variable}{index name (character)}
#'       \item{value}{noramlized anomaly (numeric)}
#'     }
#'   }
#' }
#' @docType data
#' @name nlci
#' @author Hannah Munro
#' @source \url{https://doi.org/10.20383/101.0301}
"nlci"

