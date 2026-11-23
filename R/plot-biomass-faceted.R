##' Plot Biomass by Functional Group with Confidence Intervals
##'
##' Creates a faceted plot of RV biomass trends for each functional group,
##' with confidence interval ribbons. Optionally includes both Engels and
##' Campelen survey gears, or Campelen only.
##'
##' @param data A data frame containing biomass data with columns:
##'   series, gear, year, fg, value, low, high
##' @param series_filter Character vector specifying which series to plot.
##'   Defaults to "2H_Fall".
##' @param min_year Minimum year to include in the plot. Defaults to 1995.
##' @param campelen_only Logical. If TRUE (default), filters to Campelen gear
##'   only. If FALSE, includes both Engels and Campelen with different styling.
##' @param colours Named character vector of colours for functional groups.
##'   If NULL (default), uses a standard colour scheme.
##'
##' @return A ggplot object showing faceted biomass trends
##'
##' @details
##' The function:
##' - Optionally filters for Campelen survey gear only (or includes Engels)
##' - Scales biomass values to thousand tonnes
##' - Groups single-year values and multi-year sequences for separate
##'   rendering (ribbons for ranges, points for single values)
##' - Shows all functional groups except Finfish (included as combined panel)
##'
##' @examples
##' \dontrun{
##'   plot_biomass_faceted(fg_biomass, series_filter = "2H_Fall")
##'   plot_biomass_faceted(fg_biomass, series_filter = "2H_Fall", 
##'                        campelen_only = FALSE)
##' }
##'
##' @importFrom dplyr filter mutate arrange group_by summarise ungroup
##'   bind_rows
##' @importFrom ggplot2 ggplot aes geom_ribbon geom_linerange geom_line
##'   geom_point geom_text facet_wrap scale_x_continuous scale_y_continuous
##'   scale_colour_manual scale_fill_manual labs ggtitle theme
##'   element_text expansion geom_vline
##' @export
plot_biomass_faceted <- function(
    data,
    series_filter = "2H_Fall",
    min_year = 1995,
    campelen_only = TRUE,
    colours = NULL) {

  if(is.null(colours)){
    colours <- c(
      "#88CCEE",  # light blue  SM BEN
      "#44AA99",  # teal        MED BEN
      "#117733",  # green       LG BEN
      "#332288",  # dark blue   PISC
      "#D55E00",  # orange      PLANKPISC
      "#FFC125",  # mustard     PLANK FIXX
      "#AA4499",  # purple      SHELLFISH
      "black",    # black       TOTAL BIOMASS
      "#0000FF"   # blue        FINFISH
    )
    names(colours) <- c("Small Benthivore","Medium Benthivore","Large Benthivore",
                     "Piscivore","PlankPiscivore","Planktivores","Shellfish",
                     "Total Biomass", "Finfish")
  }

  # Filter for series
  dat.facet <- data%>%
    dplyr::filter(series %in% series_filter)%>%
    dplyr::mutate(
      value = value / 1000,
      low = low / 1000,
      high = high / 1000
    )%>%
    dplyr::arrange(year, series, fg)
  
  # Conditionally filter for Campelen only
  # Note: Total Biomass has NA gear, so we need to allow that
  if(campelen_only){
    dat.facet <- dat.facet%>%
      dplyr::filter((gear == "Campelen" | is.na(gear)), year >= min_year)
  }
  
  # Calculate Finfish as sum of all non-Shellfish, non-Total Biomass groups
  dat.fin <- dat.facet%>%
    dplyr::filter(!(fg %in% c("Shellfish", "Total Biomass")))%>%
    dplyr::group_by(series, year)%>%
    dplyr::summarise(
      value = {
        vals <- value
        if(all(is.na(vals))) NA_real_ else sum(vals, na.rm = TRUE)
      },
      low = {
        vals <- low
        if(all(is.na(vals))) NA_real_ else sum(vals, na.rm = TRUE)
      },
      high = {
        vals <- high
        if(all(is.na(vals))) NA_real_ else sum(vals, na.rm = TRUE)
      },
      .groups = "drop"
    )%>%
    dplyr::mutate(
      fg = factor("Finfish", levels = names(colours)),
      gear = NA_character_
    )
  
  # Combine with original data
  dat.facet <- dplyr::bind_rows(dat.facet, dat.fin)

  # Assign each fg to its own facet group
  dat.base <- dat.facet%>%
    dplyr::filter(as.character(fg) %in% names(colours))%>%
    dplyr::mutate(
      fg = factor(as.character(fg), levels = names(colours)),
      facet_group = as.character(fg)
    )

  # Create combined Shellfish & Finfish panel
  dat.combined <- dat.base%>%
    dplyr::filter(fg %in% c("Shellfish", "Finfish"))%>%
    dplyr::mutate(facet_group = "Shellfish & Finfish")

  # Build facet order and combine
  facet_levels <- names(colours)
  facet_levels[facet_levels == "Finfish"] <- "Shellfish & Finfish"

  dat.sum <- dplyr::bind_rows(dat.base, dat.combined)%>%
    dplyr::mutate(facet_group = factor(facet_group, levels = facet_levels))%>%
    dplyr::filter(facet_group != "Finfish")

  # Identify year groups for consecutive vs single years
  dat.sum <- dat.sum%>%
    dplyr::arrange(facet_group, fg, year)%>%
    dplyr::group_by(facet_group, fg)%>%
    dplyr::mutate(
      has_data = !is.na(value),
      year_group = cumsum(
        has_data & (is.na(dplyr::lag(has_data, default = FALSE)) |
                    !dplyr::lag(has_data, default = FALSE))
      )
    )%>%
    dplyr::ungroup()

  # Separate into ribbons (multiple years) and single-year points
  dat.ribbon <- dat.sum%>%
    dplyr::filter(has_data)%>%
    dplyr::group_by(facet_group, fg, year_group)%>%
    dplyr::filter(dplyr::n() > 1)%>%
    dplyr::ungroup()

  dat.single <- dat.sum%>%
    dplyr::filter(has_data)%>%
    dplyr::group_by(facet_group, fg, year_group)%>%
    dplyr::filter(dplyr::n() == 1)%>%
    dplyr::ungroup()

  # In-panel legend labels for Shellfish & Finfish facet
  legend_labels <- data.frame(
    facet_group = factor("Shellfish & Finfish", levels = levels(dat.sum$facet_group)),
    fg = factor(c("Shellfish", "Finfish"), levels = names(colours)),
    label = c("Shellfish", "Finfish")
  )

  # Create the plot
  p <- ggplot2::ggplot(dat.sum, ggplot2::aes(x = year, y = value))+
    # Confidence interval ribbons (not in combined panel)
    ggplot2::geom_ribbon(
      data = dplyr::filter(dat.ribbon, facet_group != "Shellfish & Finfish"),
      ggplot2::aes(ymin = low, ymax = high,
                   fill = fg,
                   group = interaction(fg, year_group)),
      alpha = 0.25
    )+
    # Confidence interval error bars for single years
    ggplot2::geom_linerange(
      data = dplyr::filter(dat.single, facet_group != "Shellfish & Finfish"),
      ggplot2::aes(ymin = low, ymax = high, color = fg),
      alpha = 0.25,
      linewidth = 2
    )+
    # Connect points with lines
    ggplot2::geom_line(ggplot2::aes(color = fg), alpha = 0.6, linewidth = 0.8)+
    ggplot2::geom_point(ggplot2::aes(color = fg), size = 1.6, alpha = 0.8)+
    # In-panel legend
    ggplot2::geom_text(
      data = legend_labels,
      ggplot2::aes(x = -Inf, y = Inf, label = label, color = fg),
      hjust = -0.1,
      vjust = rep(c(1.5, 3), length.out = nrow(legend_labels)),
      size = 3,
      fontface = "bold",
      inherit.aes = FALSE,
      show.legend = FALSE
    )+
    # Facets
    ggplot2::facet_wrap(~ facet_group, scales = "free_y", ncol = 3)+
    # Scales and labels
    ggplot2::scale_x_continuous(
      breaks = seq(min(dat.sum$year, na.rm = TRUE),
                   max(dat.sum$year, na.rm = TRUE), by = 2)
    )+
    ggplot2::scale_y_continuous(
      limits = c(0, NA),
      expand = ggplot2::expansion(mult = c(0, 0.08))
    )+
    ggplot2::scale_color_manual(values = colours, drop = FALSE)+
    ggplot2::scale_fill_manual(values = colours, drop = FALSE)+
    ggplot2::labs(
      y = "RV Biomass \n(thousand tonnes)",
      x = NULL
    )+
    ggplot2::ggtitle(
      paste0(
        gsub("_", " ", series_filter[1]),
        " - All Functional Groups (Campelen only)"
      )
    )+
    ggplot2::theme(
      legend.position = "none",
      axis.text.x = ggplot2::element_text(
        angle = 90,
        vjust = 0.5,
        hjust = 1
      )
    )

  p
}
