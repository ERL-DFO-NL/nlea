# ---- helper: small long-format dataset ---------------------------------
make_test_data <- function() {
  grid <- expand.grid(
    name     = c("2J3K_Fall", "2J3K_Spring"),
    fg       = c("Benthivore", "Piscivore", "Planktivore"),
    variable = c("bmass", "sca.bmass"),
    yr       = 2000:2005,
    stringsAsFactors = FALSE
  )
  grid$gear   <- "Campelen"
  grid$value  <- seq_len(nrow(grid)) / 10
  grid$ci2.5  <- grid$value * 0.8
  grid$ci97.5 <- grid$value * 1.2
  grid
}

has_geom <- function(p, geom_class) {
  any(vapply(p$layers, function(l) inherits(l$geom, geom_class), logical(1)))
}

# ---- return value -------------------------------------------------------
test_that("returns a ggplot object with default arguments", {
  p <- plot_series(make_test_data())
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

# ---- filtering ----------------------------------------------------------
test_that("defaults filter to 2J3K_Fall and sca.bmass", {
  p <- plot_series(make_test_data())
  expect_true(all(p$data$name == "2J3K_Fall"))
  expect_true(all(p$data$variable == "sca.bmass"))
})

test_that("series and variable arguments change the data plotted", {
  p <- plot_series(make_test_data(), series = "2J3K_Spring", variable = "bmass")
  expect_true(all(p$data$name == "2J3K_Spring"))
  expect_true(all(p$data$variable == "bmass"))
})

test_that("series_col allows the series to live in a different column", {
  d <- make_test_data()
  d$survey <- d$name
  d$name   <- NULL
  p <- plot_series(d, series_col = "survey")
  expect_true(all(p$data$survey == "2J3K_Fall"))
})

# ---- layers and facets --------------------------------------------------
test_that("plot has a line and a ribbon when CIs are present", {
  p <- plot_series(make_test_data())
  expect_true(has_geom(p, "GeomLine"))
  expect_true(has_geom(p, "GeomRibbon"))
})

test_that("ribbon is omitted when all CIs are NA", {
  d <- make_test_data()
  d$ci2.5  <- NA_real_
  d$ci97.5 <- NA_real_
  p <- plot_series(d)
  expect_true(has_geom(p, "GeomLine"))
  expect_false(has_geom(p, "GeomRibbon"))
  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("ribbon is drawn when only some variables have CIs", {
  d <- make_test_data()
  d[d$variable == "sca.bmass", c("ci2.5", "ci97.5")] <- NA_real_
  expect_false(has_geom(plot_series(d, variable = "sca.bmass"), "GeomRibbon"))
  expect_true(has_geom(plot_series(d, variable = "bmass"), "GeomRibbon"))
})

test_that("plot is faceted with one panel per fg", {
  d <- make_test_data()
  p <- plot_series(d)
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(p$facet, "FacetWrap")
  expect_equal(nrow(built$layout$layout), length(unique(d$fg)))
})

# ---- error handling -----------------------------------------------------
test_that("errors informatively when required columns are missing", {
  d <- make_test_data()
  d$ci97.5 <- NULL
  expect_error(plot_series(d), "missing column")
  expect_error(plot_series(d), "ci97.5")
})

test_that("errors when series_col does not exist", {
  expect_error(plot_series(make_test_data(), series_col = "nope"), "nope")
})

test_that("errors and lists available options when nothing matches", {
  d <- make_test_data()
  expect_error(plot_series(d, series = "not_a_series"), "No rows found")
  expect_error(plot_series(d, series = "not_a_series"), "2J3K_Fall")
  expect_error(plot_series(d, variable = "not_a_variable"), "sca.bmass")
})
