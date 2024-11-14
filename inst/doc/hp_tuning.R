## ----eval=FALSE, include=TRUE-------------------------------------------------
#  knitr::opts_chunk$set(echo = TRUE)
#  
#  library(ReSurv)
#  library(reticulate)
#  use_virtualenv("pyresurv")
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data_0 <- data_generator(
#    random_seed = 1964,
#    scenario = 0,
#    time_unit = 1 / 360,
#    years = 4,
#    period_exposure = 200
#  )

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  individual_data <- IndividualDataPP(
#    data = input_data_0,
#    id = NULL,
#    categorical_features = "claim_type",
#    continuous_features = "AP",
#    accident_period = "AP",
#    calendar_period = "RP",
#    input_time_granularity = "days",
#    output_time_granularity = "quarters",
#    years = 4
#  )

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  resurv_cv_xgboost <- ReSurvCV(
#    IndividualDataPP = individual_data,
#    model = "XGB",
#    hparameters_grid = list(
#      booster = "gbtree",
#      eta = c(.001, .01, .2, .3),
#      max_depth = c(3, 6, 8),
#      subsample = c(1),
#      alpha = c(0, .2, 1),
#      lambda = c(0, .2, 1),
#      min_child_weight = c(.5, 1)
#    ),
#    print_every_n = 1L,
#    nrounds = 500,
#    verbose = FALSE,
#    verbose.cv = TRUE,
#    early_stopping_rounds = 100,
#    folds = 5,
#    parallel = T,
#    ncores = 2,
#    random_seed = 1
#  )
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  bounds <- list(
#    num_layers = c(2L, 10L),
#    num_nodes = c(2L, 10L),
#    optim = c(1L, 2L),
#    activation = c(1L, 2L),
#    lr = c(.005, 0.5),
#    xi = c(0, 0.5),
#    eps = c(0, 0.5)
#  )
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(ParBayesianOptimization)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  obj_func <- function(num_layers,
#                       num_nodes,
#                       optim,
#                       activation,
#                       lr,
#                       xi,
#                       eps) {
#    optim = switch(optim, "Adam", "SGD")
#    activation = switch(activation, "LeakyReLU", "SELU")
#    batch_size = as.integer(5000)
#    number_layers = as.integer(num_layers)
#    num_nodes = as.integer(num_nodes)
#  
#    deepsurv_cv <- ReSurvCV(
#      IndividualDataPP = individual_data,
#      model = "NN",
#      hparameters_grid = list(
#        num_layers = num_layers,
#        num_nodes = num_nodes,
#        optim = optim,
#        activation = activation,
#        lr = lr,
#        xi = xi,
#        eps = eps,
#        tie = "Efron",
#        batch_size = batch_size,
#        early_stopping = 'TRUE',
#        patience  = 20
#      ),
#      epochs = as.integer(300),
#      num_workers = 0,
#      verbose = FALSE,
#      verbose.cv = TRUE,
#      folds = 3,
#      parallel = FALSE,
#      random_seed = as.integer(Sys.time())
#    )
#  
#  
#    lst <- list(
#      Score = -deepsurv_cv$out.cv.best.oos$test.lkh,
#  
#      train.lkh = deepsurv_cv$out.cv.best.oos$train.lkh
#    )
#  
#    return(lst)
#  }
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  bayes_out <- bayesOpt(
#    FUN = obj_func,
#    bounds = bounds,
#    initPoints = 50,
#    iters.n = 1000,
#    iters.k = 50,
#    otherHalting = list(timeLimit = 18000)
#    )
#  
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  bounds <- list(
#    eta = c(0, 1),
#    max_depth = c(1L, 25L),
#    min_child_weight = c(0, 50),
#    subsample = c(0.51, 1),
#    lambda = c(0, 15),
#    alpha = c(0, 15)
#  )
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  obj_func <- function(eta,
#                       max_depth,
#                       min_child_weight,
#                       subsample,
#                       lambda,
#                       alpha) {
#    xgbcv <- ReSurvCV(
#      IndividualDataPP = individual_data,
#      model = "XGB",
#      hparameters_grid = list(
#        booster = "gbtree",
#        eta = eta,
#        max_depth = max_depth,
#        subsample = subsample,
#        alpha = lambda,
#        lambda = alpha,
#        min_child_weight = min_child_weight
#      ),
#      print_every_n = 1L,
#      nrounds = 500,
#      verbose = FALSE,
#      verbose.cv = TRUE,
#      early_stopping_rounds = 30,
#      folds = 3,
#      parallel = FALSE,
#      random_seed = as.integer(Sys.time())
#    )
#  
#    lst <- list(
#      Score = -xgbcv$out.cv.best.oos$test.lkh,
#      train.lkh = xgbcv$out.cv.best.oos$train.lkh
#    )
#  
#    return(lst)
#  }
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  library(DoParallel)
#  
#  cl <- makeCluster(parallel::detectCores())
#  registerDoParallel(cl)
#  
#  clusterEvalQ(cl, {
#    library("ReSurv")
#  })
#  
#  bayes_out <- bayesOpt(
#    FUN = obj_func
#    ,
#    bounds = bounds
#    ,
#    initPoints = length(bounds) + 20
#    ,
#    iters.n = 1000
#    ,
#    iters.k = 50
#    ,
#    otherHalting = list(timeLimit = 18000)
#    ,
#    parallel = TRUE
#  )
#  

