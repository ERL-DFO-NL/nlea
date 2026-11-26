#' Plot a time series of an index by functional group
#'
#' Plots year against a chosen variable for one series, faceted by functional
#' group, with a ribbon showing the 95% confidence interval.
#'
#' @param data A long-format data frame with columns `yr`, `fg`, `variable`,
#'   `value`, `ci2.5`, `ci97.5`, plus the column named in `series_col`.
#' @param series Series to plot. Default `"2J3K_Fall"`.
#' @param variable Variable to plot. Default `"bmass"`.
#' @param series_col Name of the column in `data` that holds the series.
#'   Default `"name"`.
#' @param scales Facet scales, passed to [ggplot2::facet_wrap()].
#'   Default `"free_y"`.
#' @param ncol Number of facet columns. Default `NULL` (automatic).
#'
#' @return A ggplot object.
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' plot_series(FG_long)
#' plot_series(FG_long, series = "2J3K_Spring", variable = "bmass")
#' }
plot_series <- function(data,
                        series     = "2J3K_Fall",
                        variable   = "bmass",
                        series_col = "name",
                        scales     = "free_y",
                        ncol       = NULL) {

  needed  <- c(series_col, "yr", "fg", "variable", "value", "ci2.5", "ci97.5")
  missing <- setdiff(needed, names(data))
  if (length(missing) > 0) {
    stop("`data` is missing column(s): ", paste(missing, collapse = ", "),
         call. = FALSE)
  }

  df <- data[data[[series_col]] %in% series & data[["variable"]] %in% variable, ]

  if (nrow(df) == 0) {
    stop("No rows found for series = '", series, "' and variable = '", variable,
         "'.\nAvailable series: ",
         paste(unique(data[[series_col]]), collapse = ", "),
         "\nAvailable variables: ",
         paste(unique(data[["variable"]]), collapse = ", "),
         call. = FALSE)
  }

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[["yr"]], y = .data[["value"]]))

  # only draw the ribbon if there are CIs for this variable
  if (any(!is.na(df[["ci2.5"]]) & !is.na(df[["ci97.5"]]))) {
    p <- p + ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data[["ci2.5"]], ymax = .data[["ci97.5"]]),
      alpha = 0.3
    )
  }

  p +
    ggplot2::geom_line() +
    ggplot2::facet_wrap(ggplot2::vars(.data[["fg"]]), scales = scales, ncol = ncol) +
    ggplot2::labs(
      x     = "Year",
      y     = variable,
      title = paste(series, "-", variable)
    ) +
    ggplot2::theme_bw()
}
