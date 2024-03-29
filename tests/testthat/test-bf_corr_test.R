# bayes factor (correlation test) --------------------------------------

test_that(
  desc = "bayes factor (correlation test) - without NAs",
  code = {
    skip_if(getRversion() < "3.6")
    skip_on_cran()

    # extracting results from where this function is implemented
    set.seed(123)
    df <-
      bf_corr_test(
        data = iris,
        y = Sepal.Length,
        x = "Sepal.Width"
      )

    # check bayes factor values
    expect_equal(df$bf10, 0.3445379, tolerance = 0.001)
    expect_equal(df$log_e_bf10, -1.065551, tolerance = 0.001)

    set.seed(123)
    subtitle1 <-
      bf_corr_test(
        data = iris,
        y = Sepal.Length,
        x = Sepal.Width,
        output = "expression",
        top.text = "huh"
      )

    expect_identical(
      subtitle1,
      ggplot2::expr(
        atop(displaystyle("huh"), expr = paste(
          "log"["e"] * "(BF"["01"] * ") = " * "1.07" * ", ",
          widehat(italic(rho))["median"]^"posterior" * " = " * "-0.12" * ", ",
          "CI"["95%"]^"HDI" * " [" * "-0.28" * ", " * "0.04" * "], ",
          italic("r")["Cauchy"]^"JZS" * " = " * "1.41"
        ))
      )
    )
  }
)

test_that(
  desc = "bayes factor (correlation test) - with NAs",
  code = {
    skip_if(getRversion() < "3.6")
    skip_on_cran()

    # extracting results from where this function is implemented
    set.seed(123)
    df <-
      bf_corr_test(
        data = ggplot2::msleep,
        y = names(ggplot2::msleep)[10],
        x = "sleep_rem"
      )

    # check bayes factor values
    expect_equal(df$bf10, 0.6539296, tolerance = 0.001)
    expect_equal(df$log_e_bf10, -0.4247555, tolerance = 0.001)

    set.seed(123)
    subtitle1 <-
      bf_corr_test(
        data = ggplot2::msleep,
        y = brainwt,
        x = sleep_rem,
        output = "subtitle",
        bf.prior = 0.8,
        centrality = "mean",
        conf.level = 0.99,
        k = 3
      )

    expect_identical(
      subtitle1,
      ggplot2::expr(
        paste(
          "log"["e"] * "(BF"["01"] * ") = " * "0.487" * ", ",
          widehat(italic(rho))["mean"]^"posterior" * " = " * "-0.208" * ", ",
          "CI"["99%"]^"HDI" * " [" * "-0.535" * ", " * "0.153" * "], ",
          italic("r")["Cauchy"]^"JZS" * " = " * "1.250"
        )
      )
    )
  }
)
