#' @title Extract Bayes Factors from `BayesFactor` model object.
#' @name bf_extractor
#'
#' @param bf.object An object from `BayesFactor` package.
#' @param conf.level Confidence/Credible Interval (CI) level. Default to `0.95`
#'   (`95%`).
#' @param centrality The point-estimates (centrality indices) to compute.
#'   Character (vector) or list with one or more of these options: `"median"`,
#'   `"mean"`, `"MAP"` or `"all"`.
#' @param conf.method The type of index used for Credible Interval. Can be
#'   `"hdi"` (default), `"eti"`, or `"si"` (see `si()`, `hdi()`, `eti()`
#'   functions from `bayestestR` package).
#' @param k Number of digits after decimal point (should be an integer)
#'   (Default: `k = 2L`).
#' @param top.text Text to display on top of the Bayes Factor message. This is
#'   mostly relevant in the context of `ggstatsplot` functions.
#' @param output If `"expression"`, will return expression with statistical
#'   details, while `"dataframe"` will return a dataframe containing the
#'   results.
#' @param ... Additional arguments passed to
#'   [parameters::model_parameters.BFBayesFactor()].
#'
#' @importFrom dplyr mutate filter rename rename_with matches
#' @importFrom insight standardize_names
#' @importFrom performance r2_bayes
#' @importFrom tidyr fill
#' @importFrom parameters model_parameters
#' @importFrom effectsize effectsize
#'
#' @note *Important*: don't enter `1/bf.object` to extract results for null
#'   hypothesis; doing so will return wrong results.
#'
#' @examples
#' \donttest{
#' # setup
#' library(tidyBF)
#' set.seed(123)
#'
#' # creating a `BayesFactor` object
#' bf_obj <-
#'   BayesFactor::anovaBF(
#'     formula = Sepal.Length ~ Species,
#'     data = iris,
#'     progress = FALSE
#'   )
#'
#' # extracting Bayes Factors in a dataframe
#' bf_extractor(bf_obj)
#' }
#' @export

# function body
bf_extractor <- function(bf.object,
                         conf.method = "hdi",
                         centrality = "median",
                         conf.level = 0.95,
                         k = 2L,
                         top.text = NULL,
                         output = "dataframe",
                         ...) {
  # basic parameters dataframe
  df <-
    suppressMessages(parameters::model_parameters(
      model = bf.object,
      ci = conf.level,
      ci_method = conf.method,
      centrality = centrality,
      verbose = FALSE,
      include_studies = FALSE,
      ...
    )) %>%
    insight::standardize_names(data = ., style = "broom") %>%
    dplyr::rename("bf10" = "bayes.factor") %>%
    tidyr::fill(data = ., dplyr::matches("^prior|^bf"), .direction = "updown") %>%
    dplyr::mutate(log_e_bf10 = log(bf10))

  # ------------------------ ANOVA designs ------------------------------

  if ("method" %in% names(df)) {
    if (df$method[[1]] == "Bayes factors for linear models") {
      # dataframe with posterior estimates for R-squared
      df_r2 <-
        performance::r2_bayes(bf.object, average = TRUE, ci = conf.level) %>%
        as_tibble(.) %>%
        insight::standardize_names(data = ., style = "broom") %>%
        dplyr::rename_with(.fn = ~ paste0("r2.", .x), .cols = dplyr::matches("^conf|^comp"))

      # for within-subjects design, retain only marginal component
      if ("r2.component" %in% names(df_r2)) df_r2 %<>% dplyr::filter(r2.component == "conditional")

      # combine everything
      df %<>% dplyr::bind_cols(., df_r2)

      # for expression
      c(centrality, conf.method) %<-% c("median", "hdi")
    }

    # ------------------------ contingency tabs ------------------------------

    if (df$method[[1]] == "Bayesian contingency table analysis") {
      df %<>% dplyr::filter(grepl("cramer", term, TRUE))
    }
  }

  # Bayes Factor expression
  bf_expr_01 <-
    bf_expr_template(
      top.text = top.text,
      estimate.df = df,
      centrality = centrality,
      conf.level = conf.level,
      conf.method = conf.method,
      k = k
    )

  # return the text results or the dataframe with results
  switch(output,
    "dataframe" = as_tibble(df),
    bf_expr_01
  )
}
