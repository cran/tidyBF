# bayes factor extractor works --------------------------

test_that(
  desc = "bayes factor (correlation)",
  code = {
    skip_if(getRversion() < "3.6")
    skip_on_cran()

    # creating a dataframe
    set.seed(123)
    df <- suppressMessages(bf_extractor(
      BayesFactor::correlationBF(
        x = ggplot2::msleep$brainwt,
        y = ggplot2::msleep$sleep_total
      )
    ))

    # check bayes factor values
    expect_equal(df$bf10[[1]], 8.990505, tolerance = 0.001)
    expect_equal(df$log_e_bf10[[1]], 2.196169, tolerance = 0.001)

    if (utils::packageVersion("BayesFactor") >= package_version("0.9.12-4.3")) {
      library(tidyBF)
      suppressPackageStartupMessages(library(BayesFactor))
      data(puzzles)

      # model
      set.seed(123)
      result <-
        anovaBF(
          RT ~ shape * color + ID,
          data = puzzles,
          whichRandom = "ID",
          whichModels = "top",
          progress = FALSE
        )

      # extract details
      df2 <- bf_extractor(result)

      expect_type(df2, "list")
      expect_identical(class(df2), c("tbl_df", "tbl", "data.frame"))
      expect_equal(df2$bf10[[1]], 2.647962, tolerance = 0.001)
    }
  }
)
