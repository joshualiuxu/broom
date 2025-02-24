#' @templateVar class plm
#' @template title_desc_tidy
#'
#' @param x A `plm` objected returned by [plm::plm()].
#' @template param_confint
#' @template param_unused_dots
#'
#' @evalRd return_tidy(regression = TRUE)
#'
#' @examplesIf rlang::is_installed("plm")
#' 
#' # load libraries for models and data
#' library(plm)
#'
#' # load data
#' data("Produc", package = "plm")
#'
#' # fit model
#' zz <- plm(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp,
#'   data = Produc, index = c("state", "year")
#' )
#'
#' # summarize model fit with tidiers
#' summary(zz)
#'
#' tidy(zz)
#' tidy(zz, conf.int = TRUE)
#' tidy(zz, conf.int = TRUE, conf.level = 0.9)
#'
#' augment(zz)
#' glance(zz)
#' 
#' @aliases plm_tidiers
#' @export
#' @seealso [tidy()], [plm::plm()], [tidy.lm()]
#' @family plm tidiers
tidy.plm <- function(x, conf.int = FALSE, conf.level = 0.95, ...) {
  check_ellipses("exponentiate", "tidy", "plm", ...)
  
  s <- summary(x)

  ret <- as_tibble(s$coefficients, rownames = "term")
  colnames(ret) <- c("term", "estimate", "std.error", "statistic", "p.value")

  if (conf.int) {
    ci <- broom_confint_terms(x, level = conf.level)
    ret <- dplyr::left_join(ret, ci, by = "term")
  }

  ret
}

# summary(plm) creates an object with class
#
# "summary.plm" "plm" "panelmodel"
#
# and we want to avoid these because they *aren't* plm objects

#' @export
tidy.summary.plm <- tidy.default


#' @templateVar class plm
#' @template title_desc_augment
#'
#' @inherit tidy.plm params examples
#' @template param_data
#'
#' @evalRd return_augment()
#'
#' @export
#' @seealso [augment()], [plm::plm()]
#' @family plm tidiers
augment.plm <- function(x, data = model.frame(x), ...) {
  # Random effects and fixed effect (within model) have individual intercepts,
  # thus we cannot take the ususal procedure for augment().
  # Also, there is currently no predict() method for plm objects.
  augment_columns(x, data, ...)
}


#' @templateVar class plm
#' @template title_desc_glance
#'
#' @inherit tidy.plm params examples
#'
#' @evalRd return_glance(
#'   "r.squared",
#'   "adj.r.squared",
#'   statistic = "F-statistic",
#'   "p.value",
#'   "deviance",
#'   "df.residual",
#'   "nobs"
#' )
#'
#' @export
#' @seealso [glance()], [plm::plm()]
#' @family plm tidiers
glance.plm <- function(x, ...) {
  s <- summary(x)
  as_glance_tibble(
    r.squared = unname(s$r.squared["rsq"]),
    adj.r.squared = unname(s$r.squared["adjrsq"]),
    statistic = unname(s$fstatistic$statistic),
    p.value = unname(s$fstatistic$p.value),
    deviance = unname(stats::deviance(x)),
    df.residual = stats::df.residual(x),
    nobs = stats::nobs(x),
    na_types = "rrrrrii"
  )
}
