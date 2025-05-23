#' @import jaspBase

# `options[["test"]]` contains information for dispatching in the generic analysis
# "OSZT"        = One samples z-test
# "ISZT"        = Independent samples z-test
# "OSTT"        = One samples t-test
# "ISTT"        = Independent samples t-test
# TODO: "correlation" = correlation
# "regression"  = regression
# "ANOVA"       = ANOVA
# TODO: "binomial"    = binomial t-test
# TODO: "AB"          = A/B test
# "Chi2"        = Chi2 test

bffAnalysis <- function(jaspResults, dataset, options, test) {

  # load data and fit Bayes factor function
  if (.bffReady(options))
    .bffFitBFF(jaspResults, dataset, options)

  # default summary table
  .bffSummaryTable(jaspResults, dataset, options)

  # compute Bayes factor at specified omega
  if (options[["bayesFactorWithPriorMode"]]) {
    if (.bffReady(options))
      .bffFitBFFOmega(jaspResults, dataset, options)
    .bffBayesFactorOmegaTable(jaspResults, dataset, options)
  }

  # Bayes factor function plot
  if (options[["plotBayesFactorFunction"]])
    .bffBayesFactorFunctionPlot(jaspResults, dataset, options)

  # # prior and posterior plot
  # if (FALSE && options[["plotPriorAndPosterior"]])
  #   .bffPriorAndPosteriorPlot(jaspResults, dataset, options)
}


.bffGetDependencies          <- function(options) {

  dependenciesGlobal <- c("alternativeHypothesis", "priorDispersionR")
  dependenciesTest   <- switch(
    options[["test"]],
    "OSZT"        = c("zStatistic", "sampleSize"),
    "OSTT"        = c("tStatistic", "sampleSize"),
    "ISZT"        = c("zStatistic", "sampleSizeGroup1", "sampleSizeGroup2"),
    "ISTT"        = c("tStatistic", "sampleSizeGroup1", "sampleSizeGroup2"),
    # "correlation" = c("tStatistic", "sampleSize"),
    "regression"  = c("tStatistic", "sampleSize", "predictors"),
    "ANOVA"       = c("fStatistic", "sampleSize", "degreesOfFreedom1", "degreesOfFreedom2"),
    #"binomial"    = c("zStatistic", "sampleSize"),
    #"AB"          = c("chiqsrStatistic", "degreesOfFreedom"),
    "Chi2"        = c("chi2Statistic", "sampleSize", "degreesOfFreedom")
  )

  return(c(dependenciesGlobal, dependenciesTest))
}
.bffGetR                     <- function(options, singleStudy = FALSE) {
  # not used till switching to multi-results settings
  if (options[["priorR"]] == "automatic" && singleStudy)
    return(1)
  else if (options[["priorR"]] == "automatic" && !singleStudy)
    return(NULL)
  else
    return(options[["priorRManualValue"]])
}
.bffGetAlternativeHypothesis <- function(options) {

  return(switch(
    options[["alternativeHypothesis"]],
    "equal"    = "two.sided",
    "greater"  = "greater",
    "less"     = "less"
  ))
}
.bffFitBFFFunction           <- function(dataset, options, fixedOmega = FALSE) {

  if (options[["test"]] == "OSZT")
    fit <- try(BFF::z_test_BFF(
      z_stat      = options[["zStatistic"]],
      one_sample  = TRUE,
      alternative = .bffGetAlternativeHypothesis(options),
      n           = options[["sampleSize"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  else if (options[["test"]] == "OSTT")
    fit <- try(BFF::t_test_BFF(
      t_stat      = options[["tStatistic"]],
      one_sample  = TRUE,
      alternative = .bffGetAlternativeHypothesis(options),
      n           = options[["sampleSize"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  else if (options[["test"]] == "ISZT")
    fit <- try(BFF::z_test_BFF(
      z_stat      = options[["zStatistic"]],
      one_sample  = FALSE,
      alternative = .bffGetAlternativeHypothesis(options),
      n1          = options[["sampleSizeGroup1"]],
      n2          = options[["sampleSizeGroup2"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  else if (options[["test"]] == "ISTT")
    fit <- try(BFF::t_test_BFF(
      t_stat      = options[["tStatistic"]],
      one_sample  = FALSE,
      alternative = .bffGetAlternativeHypothesis(options),
      n1          = options[["sampleSizeGroup1"]],
      n2          = options[["sampleSizeGroup2"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  #else if (options[["test"]] == "correlation")
  #  fit <- try(BFF::cor_test_BFF(
  #    z_stat      = options[["tStatistic"]],
  #    alternative = .bffGetAlternativeHypothesis(options),
  #    n           = options[["sampleSize"]],
  #    r           = options[["priorDispersionR"]],
  #    omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  else if (options[["test"]] == "regression")
    fit <- try(BFF::regression_test_BFF(
      t_stat      = options[["tStatistic"]],
      alternative = .bffGetAlternativeHypothesis(options),
      n           = options[["sampleSize"]],
      k           = options[["predictors"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  else if (options[["test"]] == "ANOVA")
    fit <- try(BFF::f_test_BFF(
      f_stat      = options[["fStatistic"]],
      n           = , options[["sampleSize"]],
      df1         = options[["degreesOfFreedom1"]],
      df2         = options[["degreesOfFreedom2"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  #else if (options[["test"]] == "binomial")
  #  fit <- try(BFF::binom_test_BFF(
  #    z_stat      = options[["zStatistic"]],
  #    alternative = .bffGetAlternativeHypothesis(options),
  #    n           = options[["sampleSize"]],
  #    r           = options[["priorDispersionR"]],
  #    omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  #else if (options[["test"]] == "AB")
  #  fit <- try(BFF::chi2_test_BFF(
  #    chi2_stat   = options[["chi2Statistic"]],
  #    df          = options[["degreesOfFreedom"]],
  #    r           = options[["priorDispersionR"]],
  #    omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))
  else if (options[["test"]] == "Chi2")
    fit <- try(BFF::chi2_test_BFF(
      chi2_stat   = options[["chi2Statistic"]],
      n           = options[["sampleSize"]],
      df          = options[["degreesOfFreedom"]],
      r           = options[["priorDispersionR"]],
      omega       = if (fixedOmega) options[["bayesFactorWithPriorModeValue"]] else NULL))

  return(fit)
}
.bffFitBFF                   <- function(jaspResults, dataset, options) {

  if(!is.null(jaspResults[["fit"]]))
    return()

  fitContainer <- createJaspState()
  fitContainer$dependOn(.bffGetDependencies(options))
  jaspResults[["fit"]] <- fitContainer
  jaspResults[["fit"]]$object <- .bffFitBFFFunction(dataset, options)

  return()
}
.bffFitBFFOmega              <- function(jaspResults, dataset, options) {

  if(!is.null(jaspResults[["fitOmega"]]))
    return()

  fitOmegaContainer <- createJaspState()
  fitOmegaContainer$dependOn(c(.bffGetDependencies(options), "bayesFactorWithPriorMode", "bayesFactorWithPriorModeValue"))
  jaspResults[["fitOmega"]] <- fitOmegaContainer
  jaspResults[["fitOmega"]]$object <- .bffFitBFFFunction(dataset, options, fixedOmega = TRUE)

  return()
}
.bffReady                    <- function(options) {
  switch(
    options[["test"]],
    "OSZT"        = options[["sampleSize"]] != 0,
    "OSTT"        = options[["sampleSize"]] != 0,
    "ISZT"        = options[["sampleSizeGroup1"]] != 0  && options[["sampleSizeGroup2"]] != 0,
    "ISTT"        = options[["sampleSizeGroup1"]] != 0  && options[["sampleSizeGroup2"]] != 0,
    # "correlation" = options[["sampleSize"]] != 0,
    "regression"  = options[["sampleSize"]] != 0 && options[["predictors"]] != 0,
    "ANOVA"       = options[["sampleSize"]] != 0 && options[["degreesOfFreedom1"]] != 0 && options[["degreesOfFreedom2"]] != 0,
    # "binomial"    = options[["sampleSize"]] != 0,
    # "AB"          = options[["degreesOfFreedom"]] != 0,
    "Chi2"        = options[["sampleSize"]] != 0 && options[["degreesOfFreedom"]] != 0
  )
}
.bffReadDataset              <- function(dataset, options) {
  # not used till switching to multi-results settings
  if (!is.null(dataset))
    return(dataset)

  # load the data
  dataset <- .readDataSetToEnd(
    columns.as.numeric = switch(
      options[["test"]],
      "OSZT"        = c(options[["zStatistic"]], options[["sampleSize"]]),
      "OSTT"        = c(options[["tStatistic"]], options[["sampleSize"]]),
      "ISZT"        = c(options[["zStatistic"]], options[["sampleSizeGroup1"]] , options[["sampleSizeGroup2"]]),
      "ISTT"        = c(options[["tStatistic"]], options[["sampleSizeGroup1"]] , options[["sampleSizeGroup2"]]),
      # "correlation" = c(options[["tStatistic"]], options[["sampleSize"]]),
      "regression"  = c(options[["tStatistic"]], options[["sampleSize"]], options[["predictors"]]),
      "ANOVA"       = c(options[["fStatistic"]], options[["sampleSize"]], options[["degreesOfFreedom1"]], options[["degreesOfFreedom2"]]),
      # "binomial"    = c(options[["zStatistic"]], options[["sampleSize"]]),
      # "AB"          = c(options[["chi2Statistic"]], options[["degreesOfFreedom"]]),
      "Chi2"        = c(options[["chi2Statistic"]], options[["sampleSize"]], options[["degreesOfFreedom"]])
    )
  )

  # clean from NAs
  dataset <- na.omit(dataset)

  # check of errors
  .hasErrors(
    dataset                      = dataset,
    type                         = c("negativeValues"),
    negativeValues.target        = switch(
      options[["test"]],
      "OSZT"        = c(options[["sampleSize"]]),
      "OSTT"        = c(options[["sampleSize"]]),
      "ISZT"        = c(options[["sampleSizeGroup1"]] , options[["sampleSizeGroup2"]]),
      "ISTT"        = c(options[["sampleSizeGroup1"]] , options[["sampleSizeGroup2"]]),
      # "correlation" = c(options[["sampleSize"]]),
      "regression"  = c(options[["sampleSize"]], options[["predictors"]]),
      "ANOVA"       = c(options[["fStatistic"]], options[["sampleSize"]], options[["degreesOfFreedom1"]], options[["degreesOfFreedom2"]]),
      # "binomial"    = c(options[["sampleSize"]]),
      # "AB"          = c(options[["chi2Statistic"]], options[["degreesOfFreedom"]])
      "Chi2"        = c(options[["chi2Statistic"]], options[["sampleSize"]], options[["degreesOfFreedom"]])
    ),
    exitAnalysisIfErrors         = TRUE
  )
  .hasErrors(
    dataset                      = dataset,
    type                         = c("infinity"),
    all.target                   = switch(
      options[["test"]],
      "OSZT"        = c(options[["zStatistic"]], options[["sampleSize"]]),
      "OSTT"        = c(options[["tStatistic"]], options[["sampleSize"]]),
      "ISZT"        = c(options[["zStatistic"]], options[["sampleSizeGroup1"]] , options[["sampleSizeGroup2"]]),
      "ISTT"        = c(options[["tStatistic"]], options[["sampleSizeGroup1"]] , options[["sampleSizeGroup2"]]),
      # "correlation" = c(options[["tStatistic"]], options[["sampleSize"]]),
      "regression"  = c(options[["tStatistic"]], options[["degreesOfFreedom"]]),
      "ANOVA"       = c(options[["fStatistic"]], options[["sampleSize"]], options[["degreesOfFreedom1"]], options[["degreesOfFreedom2"]]),
      # "binomial"    = c(options[["zStatistic"]], options[["sampleSize"]]),
      # "AB"          = c(options[["chi2Statistic"]], options[["degreesOfFreedom"]]),
      "Chi2"        = c(options[["chi2Statistic"]], options[["sampleSize"]], options[["degreesOfFreedom"]])
    ),
    exitAnalysisIfErrors         = TRUE
  )

  return(dataset)
}
.bffGetBFTitle               <- function(options, maximum = TRUE, plot = FALSE) {

  if (plot && options[["bayesFactorType"]] == "BF01") {
    bfType <- "BF01"
  } else if (plot) {
    bfType <- "BF10"
  } else {
    bfType <- options[["bayesFactorType"]]
  }
  hypothesis <- options[["alternativeHypothesis"]]

  if (bfType == "BF10") {

    bfTitle <- switch(
      hypothesis,
      "equal"   = if (plot) "BF[1][0]"   else "BF\u2081\u2080",
      "greater" = if (plot) "BF['+'][0]" else "BF\u208A\u2080",
      "less"    = if (plot) "BF['-'][0]" else "BF\u208B\u2080"
    )
    if (maximum)
      bfTitle <- paste0("max(", bfTitle, ")")

  } else if (bfType == "LogBF10") {

    bfTitle <- switch(
      hypothesis,
      "equal"   = if (plot) "BF[1][0]"   else "BF\u2081\u2080",
      "greater" = if (plot) "BF['+'][0]" else "BF\u208A\u2080",
      "less"    = if (plot) "BF['-'][0]" else "BF\u208B\u2080"
    )
    if (maximum)
      bfTitle <- paste0("max[", bfTitle, "]")

    bfTitle <- paste0("Log(", bfTitle, ")")

  } else if (bfType == "BF01") {

    bfTitle <- switch(
      hypothesis,
      "equal"   = if (plot) "BF[0][1]"   else "BF\u2080\u2081",
      "greater" = if (plot) "BF[0]['+']" else "BF\u2080\u208A",
      "less"    = if (plot) "BF[0]['-']" else "BF\u2080\u208B"
    )
    if (maximum)
      bfTitle <- paste0("min(", bfTitle, ")")

  }

  return(bfTitle)
}
.bttGetBFnamePlots           <- function(options, subscriptsOnly = FALSE) {

  bfType     <- options[["bayesFactorType"]]
  hypothesis <- options[["alternativeHypothesis"]]

  if (bfType %in% c("BF10", "LogBF10")) {
    if (hypothesis == "equal") {
      bfTitle <- "BF[1][0]"
    } else if (hypothesis == "greater") {
      bfTitle <- "BF['+'][0]"
    } else {
      bfTitle <- "BF['-'][0]"
    }
  } else {
    if (hypothesis == "equal") {
      bfTitle <- "BF[0][1]"
    } else if (hypothesis == "greater") {
      bfTitle <- "BF[0]['+']"
    } else {
      bfTitle <- "BF[0]['-']"
    }
  }
  if (subscriptsOnly)
    return(substring(bfTitle, 3L))
  else
    return(bfTitle)
}
.bffSummaryTable             <- function(jaspResults, dataset, options) {

  if (!is.null(jaspResults[["summaryTable"]]))
    return()

  summaryTable <- createJaspTable(title = switch(
    options[["test"]],
    "OSZT"        = gettext("One Sample Z-Test Bayes Factor Function Summary Table"),
    "OSTT"        = gettext("One Sample T-Test Bayes Factor Function Summary Table"),
    "ISZT"        = gettext("Independent Samples Z-Test Bayes Factor Function Summary Table"),
    "ISTT"        = gettext("Independent Samples T-Test Bayes Factor Function Summary Table"),
    # "correlation" = gettext("Correlation Bayes Factor Function Summary Table"),
    "regression"  = gettext("Regression Bayes Factor Function Summary Table"),
    "ANOVA"       = gettext("ANOVA Bayes Factor Function Summary Table"),
    # "binomial"    = gettext("Binomial Test Bayes Factor Function Summary Table"),
    # "AB"          = gettext("A/B Test Bayes Factor Function Summary Table"),
    "Chi2"        = gettext("Chi² Test Bayes Factor Function Summary Table")
  ))
  summaryTable$dependOn(c(.bffGetDependencies(options), "bayesFactorType"))
  summaryTable$position <- 1
  jaspResults[["summaryTable"]] <- summaryTable

  # create empty table
  bfTitle <- .bffGetBFTitle(options)
  # summaryTable$addColumnInfo(name = "n",        title = gettext("# Estimates"), type = "integer")
  summaryTable$addColumnInfo(name = "bf",         title = bfTitle,                 type = "number")
  summaryTable$addColumnInfo(name = "priorMode",  title = gettext("Prior Mode"),   type = "number")

  if (!.bffReady(options))
    return()

  fit <- jaspResults[["fit"]]$object

  if (isTryError(fit)) {
    summaryTable$setError(fit)
    return()
  }

  summaryTable$addRows(list(
    # n       = nrow(dataset),
    bf        = .recodeBFtype(bfOld = fit[["log_bf_h1"]], newBFtype = options[["bayesFactorType"]], oldBFtype = "LogBF10"),
    priorMode = fit[["omega_h1"]]
  ))

  summaryTable$addFootnote(gettextf("Prior mode corresponds to %1$s.", .bffEffectSizeInformation(options)))

  if (options[["priorDispersionR"]] != 1)
    summaryTable$addFootnote(gettextf("The Bayes factor function was estimated with prior dispersion r = %1$.2f.", fit[["r"]]))

  return()
}
.bffBayesFactorOmegaTable    <- function(jaspResults, dataset, options) {

  if (!is.null(jaspResults[["omegaTable"]]))
    return()

  omegaTable <- createJaspTable(title = switch(
    options[["test"]],
    "OSZT"        = gettext("One Sample Z-Test Bayes Factor"),
    "OSTT"        = gettext("One Sample T-Test Bayes Factor"),
    "ISZT"        = gettext("Independent Samples Z-Test Bayes Factor"),
    "ISTT"        = gettext("Independent Samples T-Test Bayes Factor"),
    # "correlation" = gettext("Correlation Bayes Factor"),
    "regression"  = gettext("Regression Bayes Factor"),
    "ANOVA"       = gettext("ANOVA Bayes Factor"),
    # "binomial"    = gettext("Binomial Test Bayes Factor"),
    # "AB"          = gettext("A/B Test Bayes Factor"),
    "Chi2"        = gettext("Chi² Test Bayes Factor")
  ))
  omegaTable$dependOn(c(
    .bffGetDependencies(options),
    "bayesFactorType", "bayesFactorWithPriorMode", "bayesFactorWithPriorModeValue"))
  omegaTable$position <- 2
  jaspResults[["omegaTable"]] <- omegaTable

  # create empty table
  bfTitle <- .bffGetBFTitle(options, maximum = FALSE)
  # omegaTable$addColumnInfo(name = "n",        title = gettext("# Estimates"), type = "integer")
  omegaTable$addColumnInfo(name = "bf",         title = bfTitle,                  type = "number")
  omegaTable$addColumnInfo(name = "priorMode",  title = gettext("Prior Mode"),    type = "number")

  if (!.bffReady(options))
    return()

  fit <- jaspResults[["fitOmega"]]$object

  if (isTryError(fit)) {
    omegaTable$setError(fit)
    return()
  }

  omegaTable$addRows(list(
    # n       = nrow(dataset),
    bf        = .recodeBFtype(bfOld = fit[["log_bf_h1"]], newBFtype = options[["bayesFactorType"]], oldBFtype = "LogBF10"),
    priorMode = options[["bayesFactorWithPriorModeValue"]]
  ))

  omegaTable$addFootnote(gettextf("Prior mode corresponds to %1$s.", .bffEffectSizeInformation(options)))

  if (options[["priorDispersionR"]] != 1)
    omegaTable$addFootnote(gettextf("The Bayes factor function was estimated with prior dispersion r = %1$.2f.", fit[["r"]]))

  return()
}
.bffBayesFactorFunctionPlot  <- function(jaspResults, dataset, options) {

  if (!is.null(jaspResults[["bayesFactorFunctionPlot"]]))
    return()

  bayesFactorFunctionPlot <- createJaspPlot(title = switch(
    options[["test"]],
    "OSZT"        = gettext("One Sample Z-Test Bayes Factor Function"),
    "OSTT"        = gettext("One Sample T-Test Bayes Factor Function"),
    "ISZT"        = gettext("Independent Samples Z-Test Bayes Factor Function"),
    "ISTT"        = gettext("Independent Samples T-Test Bayes Factor Function"),
    # "correlation" = gettext("Correlation Bayes Factor Function"),
    "regression"  = gettext("Regression Bayes Factor Function"),
    "ANOVA"       = gettext("ANOVA Bayes Factor Function"),
    # "binomial"    = gettext("Binomial Test Bayes Factor Function"),
    # "AB"          = gettext("A/B Test Bayes Factor Function"),
    "Chi2"        = gettext("Chi² Test Bayes Factor Function")
  ), width = 530, height = 400)
  bayesFactorFunctionPlot$dependOn(c(
    .bffGetDependencies(options),
    "plotBayesFactorFunction", "plotBayesFactorFunctionAdditionalInfo",
    "bayesFactorType",
    "bayesFactorWithPriorMode", "bayesFactorWithPriorModeValue"))
  bayesFactorFunctionPlot$position <- 3
  jaspResults[["bayesFactorFunctionPlot"]] <- bayesFactorFunctionPlot

  # create empty plot
  if (!.bffReady(options))
    return()

  fit <- jaspResults[["fit"]]$object

  if (isTryError(fit)) {
    bayesFactorFunctionPlot$setError(fit)
    return()
  }

  if (options[["bayesFactorWithPriorMode"]])
    fitOmega <- jaspResults[["fitOmega"]]$object


  dfLines <- data.frame(
    x = fit$BFF$omega,
    y = fit$BFF$log_bf
  )

  maxBF10  <- exp(max(fit$BFF$log_bf))
  if (options[["bayesFactorWithPriorMode"]])
    BF10user <- exp(fitOmega$log_bf_h1)

  if (options[["bayesFactorType"]] == "BF01") {
    dfLines$y <- -dfLines$y
    maxBF10   <- 1 / maxBF10
    if (options[["bayesFactorWithPriorMode"]])
      BF10user  <- 1 / BF10user
  } else {
    # make sure that logBF10 is not used
    options[["bayesFactorType"]] <- "BF10"
  }

  BFsubscript  <- .bffGetBFTitle(options, maximum = FALSE, plot = TRUE)
  BFsubscript1 <- .bffGetBFTitle(options, maximum = TRUE,  plot = TRUE)

  label1 <- c(
    gettextf("BFF"),
    if (options[["bayesFactorWithPriorMode"]])
      gettext("user prior")
  )

  # some failsafes to parse translations as expressions
  label1  <- paste0("\"", label1, "\"")
  label1  <- paste0("paste(", label1, ", ':')")

  BFandSubscript <- BFsubscript
  BFandSubscript <- gsub(pattern = "\\s+", "~", BFandSubscript)
  label2 <- c(
    gettextf("%1$s==%2$s~\"(at mode %3$s)\"", BFsubscript1,  format(maxBF10,  digits = 4), format(fit$BFF$omega[which.max(fit$BFF$log_bf)], digits = 4)),
    if (options[["bayesFactorWithPriorMode"]])
      gettextf("%1$s==%2$s~\"(at mode %3$s)\"",  BFsubscript, format(BF10user,  digits = 4), format(options[["bayesFactorWithPriorModeValue"]], digits = 4))
  )

  if (options[["plotBayesFactorFunctionAdditionalInfo"]]) {
    dfPoints <- data.frame(
      x = c(
        fit$BFF$omega[which.max(fit$BFF$log_bf)],
        if (options[["bayesFactorWithPriorMode"]]) options[["bayesFactorWithPriorModeValue"]]
      ),
      y = log(
        c(maxBF10,
        if (options[["bayesFactorWithPriorMode"]]) BF10user)
      ),
      g      = label1,
      label1 = jaspGraphs::parseThis(label1),
      label2 = jaspGraphs::parseThis(label2),
      stringsAsFactors = FALSE
    )
  } else {
    dfPoints <- NULL
  }

  if(any(is.infinite(dfLines[["y"]])))
    stop(gettext("Some Bayes factors were infinite"))

  tempPlot <- jaspGraphs::PlotRobustnessSequential(
    dfLines      = dfLines,
    dfPoints     = dfPoints,
    pointLegend  = options[["plotBayesFactorFunctionAdditionalInfo"]],
    xName        = gettextf("Prior mode (%1$s)", .bffEffectSizeInformation(options)),
    hypothesis   = ifelse(options[["alternativeHypothesis"]] == "less", "smaller", options[["alternativeHypothesis"]]),
    bfType       = options[["bayesFactorType"]],
    pointColors  = c("grey", if (options[["bayesFactorWithPriorMode"]]) "black")
  )

  if (isTryError(tempPlot)) {
    bayesFactorFunctionPlot$setError(tempPlot)
    return()
  }

  bayesFactorFunctionPlot$plotObject <- tempPlot

  return()
}
.bffPriorAndPosteriorPlot    <- function(jaspResults, dataset, options) {

  if (!is.null(jaspResults[["priorAndPosteriorPlot"]]))
    return()

  priorAndPosteriorPlot <- createJaspPlot(title = gettext("Prior and Posterior Plot"))
  priorAndPosteriorPlot$dependOn(c(
    .bffGetDependencies(options),
    "plotPriorAndPosterior", "plotBayesFactorFunctionAdditionalInfo"))
  priorAndPosteriorPlot$position <- 4
  jaspResults[["priorAndPosteriorPlot"]] <- priorAndPosteriorPlot

  # create empty table
  if (!.bffReady(options))
    return()

  fit <- jaspResults[["fit"]]$object

  if (isTryError(fit)) {
    priorAndPosteriorPlot$setError(fit)
    return()
  }

  tempPlot <- try(BFF::posterior_plot(fit, prior = TRUE))

  if (isTryError(tempPlot)) {
    priorAndPosteriorPlot$setError(tempPlot)
    return()
  }

  priorAndPosteriorPlot$plotObject <- tempPlot + jaspGraphs::themeJaspRaw() + jaspGraphs::geom_rangeframe()

  return()
}
.bffEffectSizeInformation    <- function(options) {
  # BFF:::.test_effect_size_name
  switch (options[["test"]],
    "OSZT"        = gettextf("Cohen's d"),
    "OSTT"        = gettextf("Cohen's d"),
    "ISZT"        = gettextf("Cohen's d"),
    "ISTT"        = gettextf("Cohen's d"),
    # "correlation" = gettextf(),
    "regression"  = gettextf("Cohen's d"),
    "ANOVA"       = gettextf("Cohen's f"),
    # "binomial"    = gettextf(),
    # "AB"          = gettextf(),
    "Chi2"        = gettextf("Cohen's w")
  )
}
