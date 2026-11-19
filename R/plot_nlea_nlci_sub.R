##' Plot NLCI sub-indices together in a heatmap style plot.
##'
##' Takes the nlci_sub tibble containing standardised annual sub-indices for the
##' Newfoundland and Labrador Composite Index and plots a heatmap style plot.
##' To display square tiles for each data point, manually adjust your figure
##' dimensions when saving. Adapted from pacea::plot_indices().
##'
##' @param dat tibble of class `nlea_nlci_sub` containing columns `year`, `variable`,
##'   and `value`. Typically the built-in `nlci_sub` dataset.
##' @param years numeric vector of the years to show, default is the range that
##'   encompasses all the indices. If some years of an index are not plotted (but
##'   were used to create the standardised index), then the mean of the values
##'   shown in the plot for that index will obviously not be 0.
##' @param xlab x-axis label, default is "Year".
##' @param ylab y-axis label, default is "Index".
##' @param main title of the plot. Default describes it as an ecosystem summary plot.
##' @param return_results logical; if TRUE returns a list with plot and results
##'   tibble, otherwise returns just the plot.
##' @param scale_limits numeric vector of length 2 specifying the colour scale limits.
##'   Default uses the maximum absolute value in the data.
##' @param angle_year_labels logical, whether to put the year labels at 45
##'   degrees, which is needed to avoid overlapping when there are many years.
##' @param gap_after character vector (or NULL, the default) of variable names
##'   to add a gap after in the plot. For example,
##'   `gap_after = "air_temp"` will add a gap after the air_temp variable.
##'   Multiple variables can be specified: `gap_after = c("var1", "var2")`.
##' @param gap_size numeric value controlling the size of the gaps in cm
##'   (default 0.2, roughly 1/5 of the box height).
##' @param heatmap_colours numeric vector of colours to use for the heatmap.
##'   Default is `pals::ocean.balance(20)[2:19]`, which provides 18 colours.
##' @param flip character vector (or NULL, the default) of variable names for which
##'   to reverse the colour scale. When a negative value of a variable is thought
##'   to have a positive effect, the colours are reversed so that red is 'good'.
##'   An asterisk is added to the variable label in the figure to identify this.
##'   The numeric values shown in the figure are those of the original variable.
##' @param text_size numeric; size of text displayed in heatmap boxes (default: 3.5)
##' @param digits numeric number of decimal places to show for text values
##' @return a ggplot object (when `return_results = FALSE`) or a list with `plot` and `results`
##' (when `return_results = TRUE`)
##' @export
##' @author Andrew Edwards, Andrea Hilborn, Hannah Munro, and Chelsey Malayny
##' @examples
##' \dontrun{
##' plot_nlea_nlci_sub(nlci_sub)
##' plot_nlea_nlci_sub(nlci_sub,
##'                    flip = c("wint_nao", "air_temp"))
##' }
plot.nlea_nlci_sub <- function(dat,
                               years = NULL,
                               main = NULL,
                               xlab = "Year",
                               ylab = "Index",
                               return_results = FALSE,
                               scale_limits = NULL,
                               angle_year_labels = TRUE,
                               gap_after = NULL,
                               gap_size = 0.2,
                               heatmap_colours = pals::ocean.balance(20)[2:19],
                               flip = NULL,
                               text_size = 3.5,
                               digits = 1){

  # Prepare data: dat already contains year, variable, value columns
  combined_indices <- dat %>%
    dplyr::mutate(variable = factor(variable))

  if(is.null(main)){
    main = paste0("NLCI subindices")
  }

  if(is.null(years)){
    years <- seq(min(combined_indices$year,
                     na.rm = TRUE),
                 max(combined_indices$year,
                     na.rm = TRUE))
  }

  plot_data <- combined_indices %>%
    dplyr::filter(year %in% years,
                  !is.na(value))

  # Create legend label
  legend_label <- "Standardised anomaly for each variable"

  if(is.null(scale_limits)){
    max_abs <- max(abs(plot_data$value),
                   na.rm = TRUE)
    scale_limits <- c(-max_abs,
                      max_abs)
  }

  # Add label column for text display
  plot_data <- plot_data %>%
    dplyr::mutate(label = format(round(value, digits),
                                 nsmall = digits))

  # Flip sign of values (so red is 'good' but the shown 'label' number is still
  # the value of the original variable) and add asterisk for 'flipped' variables
  if(!is.null(flip)){
    if(!all(flip %in% combined_indices$variable)){
      stop("flip needs to contain only variable names from the data")
    }

    plot_data <- plot_data %>%
      dplyr::mutate(value = dplyr::if_else(variable %in% flip,
                                           -value,
                                           value),
                    variable = dplyr::if_else(variable %in% flip,
                                              paste0(variable, "*"),
                                              variable))
  }

  # Recreate variable factor levels to preserve order after adding flip symbols
  if(!is.null(flip)){
    new_levels <- plot_data %>%
      dplyr::distinct(variable) %>%
      dplyr::arrange(variable) %>%
      dplyr::pull(variable)

    plot_data <- plot_data %>%
      dplyr::mutate(variable = factor(variable,
                                      levels = new_levels))
  }

  # Create grouping for gaps if gap_after is specified
  if(!is.null(gap_after)){
    if(!all(gap_after %in% combined_indices$variable)){
      stop("gap_after needs to be one of your variables")
    }
    # Get unique variables and assign gap groups
    var_groups <- plot_data %>%
      dplyr::distinct(variable) %>%
      dplyr::mutate(
        gap_group = 1 + cumsum(dplyr::lag(variable %in% gap_after,
                                          default = FALSE))
      )

    plot_data_with_groups <- plot_data %>%
      dplyr::left_join(var_groups,
                       by = "variable")
  } else {
    plot_data_with_groups <- plot_data %>%
      dplyr::mutate(gap_group = 1)
  }

  # Colour scale
  color_scale <- ggplot2::scale_fill_gradientn(colours = heatmap_colours,
                                               limits = scale_limits,
                                               name = legend_label)

  indices_plot <-
    plot_data_with_groups %>%
    ggplot2::ggplot(ggplot2::aes(x = year,
                                  y = variable)) +
    ggplot2::geom_tile(ggplot2::aes(fill = value),
                       colour = "black") +
    color_scale +
    ggplot2::scale_x_continuous(expand = c(0, 0),
                                name = xlab,
                                breaks = years) +
    ggplot2::scale_y_discrete(expand = c(0, 0),
                              name = ylab,
                              limits = rev) +
    {
      if(!is.null(gap_after)){
        ggplot2::facet_grid(gap_group ~ .,
                            scales = "free_y",
                            space = "free_y")
      } else {
        NULL
      }
    } +
    ggplot2::theme(legend.position = "bottom",
                   strip.background = ggplot2::element_blank(),
                   strip.text = ggplot2::element_text(face = "bold",
                                                      size = 12),
                   strip.text.y = ggplot2::element_blank(),
                   panel.spacing.y = grid::unit(if(!is.null(gap_after)) gap_size else 0.1,
                                                if(!is.null(gap_after)) "cm" else "lines"),
                   panel.background = ggplot2::element_rect(fill = "white",
                                                            colour = NA),
                   panel.grid = ggplot2::element_blank()) +
    {
      if(!is.null(flip)){
        ggplot2::theme(axis.ticks.y = ggplot2::element_blank())
      } else {
        ggplot2::theme()
      }
    } +
    {
      if(angle_year_labels){
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45,
                                                           hjust = 1,
                                                           vjust = 1))
      } else {
        ggplot2::theme()
      }
    } +
    ggplot2::geom_text(ggplot2::aes(label = label),
                       size = text_size) +
    ggplot2::guides(fill = ggplot2::guide_colorbar(barwidth = 15,
                                                    title.position = "top",
                                                    frame.colour = "black",
                                                    ticks.colour = "black")) +
    ggplot2::labs(title = main)
         # caption = "Ooh look at me")

  if(return_results){
    print(indices_plot)
    return(list(plot = indices_plot,
                results = plot_data))
  } else {
    return(indices_plot)
  }
}
