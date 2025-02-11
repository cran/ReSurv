## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(ReSurv)
#  library(reticulate)
#  use_virtualenv("pyresurv")
#  library(ggplot2)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(devtools)
#  devtools::install_github("edhofman/resurv")
#  library(ReSurv)
#  packageVersion("ReSurv")
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  ReSurv::install_pyresurv()

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(ReSurv)
#  reticulate::use_virtualenv("pyresurv")
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  envname <- "./venv"
#  ReSurv::install_pyresurv(envname = envname)
#  pysparklyr::install_pyspark(envname = envname)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data <- data_generator(random_seed = 7,
#                               scenario = "alpha",
#                               time_unit = 1 / 360,
#                               years = 4,
#                               period_exposure = 200)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  str(input_data)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  individual_data <- IndividualDataPP(data = input_data,
#                                      categorical_features = "claim_type",
#                                      continuous_features = "AP",
#                                      accident_period = "AP",
#                                      calendar_period = "RP",
#                                      input_time_granularity = "days",
#                                      output_time_granularity = "quarters",
#                                      years = 4)
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  resurv_cv_xgboost <- ReSurvCV(IndividualDataPP = individual_data,
#                                model = "XGB",
#                                hparameters_grid = list(booster = "gbtree",
#                                                        eta = c(.001),
#                                                        max_depth = c(3),
#                                                        subsample = c(1),
#                                                        alpha = c(0),
#                                                        lambda = c(0),
#                                                        min_child_weight = c(.5)),
#                                print_every_n = 1L,
#                                nrounds = 1,
#                                verbose = FALSE,
#                                verbose.cv = TRUE,
#                                early_stopping_rounds = 1,
#                                folds = 5,
#                                parallel = TRUE,
#                                ncores = 2,
#                                random_seed = 1)
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  resurv_cv_nn <- ReSurvCV(IndividualDataPP = individual_data,
#                           model = "NN",
#                           hparameters_grid = list(num_layers = c(1, 2),
#                                                   num_nodes = c(2, 4),
#                                                   optim = "Adam",
#                                                   activation = "ReLU",
#                                                   lr = .5,
#                                                   xi = .5,
#                                                   eps = .5,
#                                                   tie = "Efron",
#                                                   batch_size = as.integer(5000),
#                                                   early_stopping = "TRUE",
#                                                   patience = 20),
#                           epochs = as.integer(300),
#                           num_workers = 0,
#                           verbose = FALSE,
#                           verbose.cv = TRUE,
#                           folds = 3,
#                           parallel = FALSE,
#                           random_seed = as.integer(Sys.time()))

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  bounds <- list(eta = c(0, 1),
#                 max_depth = c(1L, 25L),
#                 min_child_weight = c(0, 50),
#                 subsample = c(0.51, 1),
#                 lambda = c(0, 15),
#                 alpha = c(0, 15))
#  
#  
#  obj_func <- function(eta,
#                       max_depth,
#                       min_child_weight,
#                       subsample,
#                       lambda,
#                       alpha) {
#  
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
#    lst <- list(Score = -xgbcv$out.cv.best.oos$test.lkh,
#                train.lkh = xgbcv$out.cv.best.oos$train.lkh)
#  
#    return(lst)
#  }
#  
#  
#  
#  bayes_out <- bayesOpt(FUN = obj_func,
#                        bounds = bounds,
#                        initPoints = 50,
#                        iters.n = 1000,
#                        iters.k = 50,
#                        otherHalting = list(timeLimit = 18000))
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  bounds <- list(num_layers = c(2L, 10L),
#                 num_nodes = c(2L, 10L),
#                 optim = c(1L, 2L),
#                 activation = c(1L, 2L),
#                 lr = c(0.005, 0.5),
#                 xi = c(0, 0.5),
#                 eps = c(0, 0.5))
#  
#  
#  obj_func <- function(num_layers,
#                       num_nodes,
#                       optim,
#                       activation,
#                       lr,
#                       xi,
#                       eps) {
#  
#    optim <- switch(optim,
#                    "Adam",
#                    "SGD")
#  
#    activation <- switch(activation, "LeakyReLU", "SELU")
#    batch_size <- as.integer(5000L)
#    number_layers <- as.integer(num_layers)
#    num_nodes <- as.integer(num_nodes)
#  
#    deepsurv_cv <- ReSurvCV(IndividualData = individual_data,
#                            model = "NN",
#                            hparameters_grid = list(num_layers = number_layers,
#                                                    num_nodes = num_nodes,
#                                                    optim = optim,
#                                                    activation = activation,
#                                                    lr = lr,
#                                                    xi = xi,
#                                                    eps = eps,
#                                                    tie = "Efron",
#                                                    batch_size = batch_size,
#                                                    early_stopping = "TRUE",
#                                                    patience  = 20),
#                            epochs = as.integer(300),
#                            num_workers = 0,
#                            verbose = FALSE,
#                            verbose.cv = TRUE,
#                            folds = 3,
#                            parallel = FALSE,
#                            random_seed = as.integer(Sys.time()))
#  
#  
#    lst <- list(Score = -deepsurv_cv$out.cv.best.oos$test.lkh,
#                train.lkh = deepsurv_cv$out.cv.best.oos$train.lkh)
#  
#    return(lst)
#  }
#  
#  bayes_out <- bayesOpt(FUN = obj_func,
#                        bounds = bounds,
#                        initPoints = 50,
#                        iters.n = 1000,
#                        iters.k = 50,
#                        otherHalting = list(timeLimit = 18000))
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  resurv_fit_cox <- ReSurv(individual_data,
#                       hazard_model = "COX")
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  hparameters_xgb <- list(
#    params = list(
#      booster = "gbtree",
#      eta = 0.9611239,
#      subsample = 0.62851,
#      alpha = 5.836211,
#      lambda = 15,
#      min_child_weight = 29.18158,
#      max_depth = 1
#    ),
#    print_every_n = 0,
#    nrounds = 3000,
#    verbose = FALSE,
#    early_stopping_rounds = 500
#  )
#  
#  
#  resurv_fit_xgb <- ReSurv(individual_data,
#                           hazard_model = "XGB",
#                           hparameters = hparameters_xgb)
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  hparameters_nn = list(num_layers= 2,
#              early_stopping= TRUE,
#              patience=350,
#              verbose=FALSE,
#              network_structure=NULL,
#              num_nodes= 10,
#              activation ="LeakyReLU",
#              optim ="SGD",
#              lr =0.02226655,
#              xi=0.4678993,
#              epsilon= 0,
#              batch_size= 5000L,
#              epochs= 5500L,
#              num_workers= 0,
#              tie="Efron" )
#  
#  
#  resurv_fit_nn <- ReSurv(individual_data,
#                       hazard_model = "NN",
#                       hparameters = hparameters_nn)
#  
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  resurv_fit_predict_q <- predict(resurv_fit_cox)
#  
#  individual_data_y <- IndividualDataPP(input_data,
#                                        id = "claim_number",
#                                        continuous_features = "AP_i",
#                                        categorical_features = "claim_type",
#                                        accident_period = "AP",
#                                        calendar_period = "RP",
#                                        input_time_granularity = "days",
#                                        output_time_granularity = "years",
#                                        years = 4,
#                                        continuous_features_spline = NULL,
#                                        calendar_period_extrapolation = FALSE)
#  
#  resurv_fit_predict_y <- predict(resurv_fit_cox,
#                                  newdata = individual_data_y,
#                                  grouping_method = "probability")
#  
#  individual_data_m <- IndividualDataPP(input_data,
#                                        id = "claim_number",
#                                        continuous_features = "AP_i",
#                                        categorical_features = "claim_type",
#                                        accident_period = "AP",
#                                        calendar_period = "RP",
#                                        input_time_granularity = "days",
#                                        output_time_granularity = "months",
#                                        years = 4,
#                                        continuous_features_spline = NULL,
#                                        calendar_period_extrapolation = FALSE)
#  
#  resurv_fit_predict_m <- predict(resurv_fit_cox,
#                                  newdata = individual_data_m,
#                                  grouping_method = "probability")
#  
#  
#  
#  model_s <- summary(resurv_fit_predict_y)
#  print(model_s)
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  resurv_predict_xgb <- predict(resurv_fit_xgb)
#  resurv_predict_nn <- predict(resurv_fit_nn)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  resurv_fit_predict_q$long_triangle_format_out$output_granularity %>%
#      filter(AP_o==15 & claim_type == 1) %>%
#      filter(row_number()==1) %>%
#      select(group_o)
#  
#  plot(resurv_fit_predict_q,
#           granularity = "output",
#           title_par = "COX: Accident Quarter 15 Claim Type 1",
#           group_code = 30)
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  crps <- survival_crps(resurv_fit_cox)
#  m_crps <- mean(crps$crps)
#  m_crps
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  resurv_fit_predict_q$long_triangle_format_out$output_granularity %>%
#      filter(AP_o==15 & claim_type == 1) %>%
#      filter(row_number()==1) %>%
#      select(group_o)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  plot(resurv_fit_predict_q,
#           granularity = "output",
#           title_par = "COX: Accident Quarter 15 Claim Type 1",
#           group_code = 30)
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  p1 <- input_data %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = RT - AT, color = claim_type)) +
#    stat_ecdf(size = 1) +
#    labs(title = "", x = "Notification delay (in days)", y = "ECDF") +
#    xlim(0.01, 1500) +
#    scale_color_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    scale_linetype_manual(values = c(1, 3),
#                          labels = c("Claim type 0", "Claim type 1")) +
#    guides(
#      color = guide_legend(
#        title = "Claim type",
#        override.aes = list(
#          color = c("royalblue", "#a71429"),
#          linewidth = 2
#        )
#      ),
#      linetype = guide_legend(
#        title = "Claim type",
#        override.aes = list(linetype = c(1, 3), linewidth = 0.7)
#      )
#    ) +
#    theme_bw() +
#    theme(
#      axis.text = element_text(size = 20),
#      axis.title.y = element_text(size = 20),
#      axis.title.x  = element_text(size = 20),
#      legend.text = element_text(size = 20)
#    )
#  p1
#  
#  
#  p2 <- input_data %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = claim_type, fill = claim_type)) +
#    geom_bar() +
#    scale_fill_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    guides(fill = guide_legend(title = "Claim type")) +
#    theme_bw() +
#    labs(title = "", x = "Claim Type", y = "") +
#    theme(
#      axis.text = element_text(size = 20),
#      axis.title.y = element_text(size = 20),
#      axis.title.x  = element_text(size = 20),
#      legend.text = element_text(size = 20)
#    )
#  p2
#  
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  clmodel <- resurv_fit_cox$IndividualDataPP$training.data %>%
#    mutate(DP_o = 16 -
#             DP_rev_o + 1) %>%
#    group_by(AP_o, DP_o) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(AP_o) %>%
#    arrange(DP_o) %>%
#    mutate(I_cum = cumsum(I), I_cum_lag = lag(I_cum, default = 0)) %>%
#    ungroup() %>%
#    group_by(DP_o) %>%
#    reframe(df_o = sum(I_cum * (
#      AP_o <= max(resurv_fit_cox$IndividualDataPP$training.data$AP_o) - DP_o +
#        1
#    )) /
#      sum(I_cum_lag * (
#        AP_o <= max(resurv_fit_cox$IndividualDataPP$training.data$AP_o) - DP_o +
#          1
#      )),
#    I = sum(I * (
#      AP_o <= max(resurv_fit_cox$IndividualDataPP$training.data$AP_o) - DP_o
#    ))) %>%
#    mutate(DP_o_join = DP_o - 1) %>%
#    as.data.frame()
#  
#  
#  clmodel %>%
#    filter(DP_o > 1) %>%
#    ggplot(aes(x = DP_o, y = df_o)) +
#    geom_line(linewidth = 2.5,
#              color = "#454555") +
#    labs(title = "Chain ladder",
#         x = "Development quarter",
#         y = "Development factor") +
#    ylim(1, 3. + .01) +
#    theme_bw(base_size = rel(5)) +
#    theme(plot.title = element_text(size = 20))
#  
#  ##
#  
#  clmodel_months <- individual_data_m$training.data %>%
#    mutate(DP_o = 48 -
#             DP_rev_o + 1) %>%
#    group_by(AP_o, DP_o) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(AP_o) %>%
#    arrange(DP_o) %>%
#    mutate(I_cum = cumsum(I), I_cum_lag = lag(I_cum, default = 0)) %>%
#    ungroup() %>%
#    group_by(DP_o) %>%
#    reframe(df_o = sum(I_cum * (
#      AP_o <= max(individual_data_m$training.data$AP_o) - DP_o + 1
#    )) /
#      sum(I_cum_lag * (
#        AP_o <= max(individual_data_m$training.data$AP_o) - DP_o + 1
#      )),
#    I = sum(I * (
#      AP_o <= max(individual_data_m$training.data$AP_o) - DP_o
#    ))) %>%
#    mutate(DP_o_join = DP_o - 1) %>%
#    as.data.frame()
#  
#  ticks_at <- seq(1, 48, 4)
#  labels_as <- as.character(ticks_at)
#  
#  clmodel_months %>%
#    filter(DP_o > 1) %>%
#    ggplot(aes(x = DP_o,
#               y = df_o)) +
#    geom_line(linewidth = 2.5,
#              color = "#454555") +
#    labs(title = "Chain ladder",
#         x = "Development month",
#         y = "Development factor") +
#    ylim(1, 2.5 + .01) +
#    scale_x_continuous(breaks = ticks_at, labels = labels_as) +
#    theme_bw(base_size = rel(5)) +
#    theme(plot.title = element_text(size = 20))
#  
#  
#  ##
#  
#  clmodel_years <- individual_data_y$training.data %>%
#    mutate(DP_o = 4 -
#             DP_rev_o + 1) %>%
#    group_by(AP_o, DP_o) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(AP_o) %>%
#    arrange(DP_o) %>%
#    mutate(I_cum = cumsum(I), I_cum_lag = lag(I_cum, default = 0)) %>%
#    ungroup() %>%
#    group_by(DP_o) %>%
#    reframe(df_o = sum(I_cum * (
#      AP_o <= max(individual_data_m$training.data$AP_o) - DP_o + 1
#    )) /
#      sum(I_cum_lag * (
#        AP_o <= max(individual_data_m$training.data$AP_o) - DP_o + 1
#      )),
#    I = sum(I * (
#      AP_o <= max(individual_data_m$training.data$AP_o) - DP_o
#    ))) %>%
#    mutate(DP_o_join = DP_o - 1) %>%
#    as.data.frame()
#  
#  ticks_at <- seq(1, 4, 1)
#  labels_as <- as.character(ticks_at)
#  
#  clmodel_years %>%
#    filter(DP_o > 1) %>%
#    ggplot(aes(x = DP_o,
#               y = df_o)) +
#    geom_line(linewidth = 2.5,
#              color = "#454555") +
#    labs(title = "Chain ladder",
#         x = "Development year",
#         y = "Development factor") +
#    ylim(1, 2.5 + .01) +
#    scale_x_continuous(breaks = ticks_at, labels = labels_as) +
#    theme_bw(base_size = rel(5)) +
#    theme(plot.title = element_text(size = 20))
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  ct <- 0
#  ap <- 12
#  
#  resurv_fit_predict_q$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  plot(
#    resurv_fit_predict_q,
#    granularity = "output",
#    title_par = "COX: Accident Quarter 12 Claim Type 0",
#    group_code = 23
#  )
#  
#  
#  ct <- 0
#  ap <- 36
#  
#  resurv_fit_predict_m$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  plot(
#    resurv_fit_predict_m,
#    granularity = "output",
#    color_par = "#a71429",
#    title_par = "COX: Accident Month 36 Claim Type 0",
#    group_code = 71
#  )
#  
#  
#  
#  ct <- 1
#  ap <- 7
#  
#  resurv_fit_predict_m$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  plot(
#    resurv_fit_predict_m,
#    granularity = "output",
#    color_par = "#a71429",
#    title_par = "COX: Accident Month 7 Claim Type 1",
#    group_code = 14
#  )
#  
#  
#  ct <- 0
#  ap <- 2
#  
#  resurv_fit_predict_y$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  plot(
#    resurv_fit_predict_y,
#    granularity = "output",
#    color_par = "#FF6A7A",
#    title_par = "COX: Accident Year 2 Claim Type 0",
#    group_code = 3
#  )
#  
#  
#  ct <- 1
#  ap <- 3
#  
#  resurv_fit_predict_y$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  
#  plot(
#    resurv_fit_predict_y,
#    granularity = "output",
#    color_par = "#FF6A7A",
#    title_par = "COX: Accident Year 3 Claim Type 1",
#    group_code = 6
#  )

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  
#  conversion_factor <- individual_data$conversion_factor
#  
#  max_dp_i <- 1440
#  
#  true_output <- resurv_fit_cox$IndividualDataPP$full.data %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(
#                DP_i * conversion_factor +
#                  ((AP_i - 1) %% (
#                    1 / conversion_factor
#                  )) * conversion_factor) + 1,
#      AP_o = ceiling(AP_i * conversion_factor),
#      TR_o = AP_o - 1
#    ) %>%
#    filter(DP_rev_o <= TR_o) %>%
#    group_by(claim_type, AP_o, DP_rev_o) %>%
#    mutate(claim_type = as.character(claim_type)) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    filter(DP_rev_o > 0)
#  
#  out_list <- resurv_fit_predict_q$long_triangle_format_out
#  out <- out_list$output_granularity
#  
#  #Total output
#  score_total <- out[, c("claim_type", "AP_o", "DP_o", "expected_counts")] %>%
#    mutate(DP_rev_o = 16 - DP_o + 1) %>%
#    inner_join(true_output, by = c("claim_type", "AP_o", "DP_rev_o")) %>%
#    mutate(ave = I - expected_counts, abs_ave = abs(ave)) %>%
#    # from here it is reformulated for the are tot
#    ungroup() %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave = abs(sum(ave)), I = sum(I))
#  
#  are_tot <- sum(score_total$abs_ave) / sum(score_total$I)
#  
#  
#  dfs_output <- out %>%
#    mutate(DP_rev_o = 16 - DP_o + 1) %>%
#    select(AP_o, claim_type, DP_rev_o, f_o) %>%
#    mutate(DP_rev_o = DP_rev_o) %>%
#    distinct()
#  
#  #Cashflow on output scale.Etc quarterly cashflow development
#  score_diagonal <- resurv_fit_cox$IndividualDataPP$full.data  %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(
#                DP_i * conversion_factor +
#                  ((AP_i - 1) %% (
#                    1 / conversion_factor
#                  )) * conversion_factor) + 1,
#      AP_o = ceiling(AP_i * conversion_factor)
#    ) %>%
#    group_by(claim_type, AP_o, DP_rev_o) %>%
#    mutate(claim_type = as.character(claim_type)) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(claim_type, AP_o) %>%
#    arrange(desc(DP_rev_o)) %>%
#    mutate(I_cum = cumsum(I)) %>%
#    mutate(I_cum_lag = lag(I_cum, default = 0)) %>%
#    left_join(dfs_output, by = c("AP_o", "claim_type", "DP_rev_o")) %>%
#    mutate(I_cum_hat =  I_cum_lag * f_o,
#           RP_o = max(DP_rev_o) - DP_rev_o + AP_o) %>%
#    inner_join(true_output[, c("AP_o", "DP_rev_o")] %>%  distinct()
#               , by = c("AP_o", "DP_rev_o")) %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave2_diag = abs(sum(I_cum_hat) - sum(I_cum)), I = sum(I))
#  
#  are_cal_q <- sum(score_diagonal$abs_ave2_diag) / sum(score_diagonal$I)
#  
#  
#  # scoring XGB ----
#  
#  out_xgb <- resurv_predict_xgb$long_triangle_format_out$output_granularity
#  
#  score_total_xgb <- out_xgb[, c("claim_type",
#                                 "AP_o",
#                                 "DP_o",
#                                 "expected_counts")] %>%
#    mutate(DP_rev_o = 16 - DP_o + 1) %>%
#    inner_join(true_output, by = c("claim_type", "AP_o", "DP_rev_o")) %>%
#    mutate(ave = I - expected_counts, abs_ave = abs(ave)) %>%
#    # from here it is reformulated for the are tot
#    ungroup() %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave = abs(sum(ave)), I = sum(I))
#  
#  are_tot_xgb <- sum(score_total_xgb$abs_ave) / sum(score_total$I)
#  
#  
#  dfs_output_xgb <- out_xgb %>%
#    mutate(DP_rev_o = 16 - DP_o + 1) %>%
#    select(AP_o, claim_type, DP_rev_o, f_o) %>%
#    mutate(DP_rev_o = DP_rev_o) %>%
#    distinct()
#  
#  #Cashflow on output scale.Etc quarterly cashflow development
#  score_diagonal_xgb <- resurv_fit_cox$IndividualDataPP$full.data  %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(
#                DP_i * conversion_factor +
#                  ((AP_i - 1) %% (
#                    1 / conversion_factor
#                  )) * conversion_factor) + 1,
#      AP_o = ceiling(AP_i * conversion_factor)
#    ) %>%
#    group_by(claim_type, AP_o, DP_rev_o) %>%
#    mutate(claim_type = as.character(claim_type)) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(claim_type, AP_o) %>%
#    arrange(desc(DP_rev_o)) %>%
#    mutate(I_cum = cumsum(I)) %>%
#    mutate(I_cum_lag = lag(I_cum, default = 0)) %>%
#    left_join(dfs_output_xgb, by = c("AP_o", "claim_type", "DP_rev_o")) %>%
#    mutate(I_cum_hat =  I_cum_lag * f_o,
#           RP_o = max(DP_rev_o) - DP_rev_o + AP_o) %>%
#    inner_join(true_output[, c("AP_o", "DP_rev_o")] %>%  distinct()
#               , by = c("AP_o", "DP_rev_o")) %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave2_diag = abs(sum(I_cum_hat) - sum(I_cum)), I = sum(I))
#  
#  are_cal_q_xgb <- sum(score_diagonal_xgb$abs_ave2_diag) / sum(score_diagonal$I)
#  
#  # scoring NN ----
#  
#  out_nn <- resurv_predict_nn$long_triangle_format_out$output_granularity
#  
#  score_total_nn <- out_nn[, c("claim_type",
#                               "AP_o",
#                               "DP_o",
#                               "expected_counts")] %>%
#    mutate(DP_rev_o = 16 - DP_o + 1) %>%
#    inner_join(true_output, by = c("claim_type", "AP_o", "DP_rev_o")) %>%
#    mutate(ave = I - expected_counts, abs_ave = abs(ave)) %>%
#    # from here it is reformulated for the are tot
#    ungroup() %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave = abs(sum(ave)), I = sum(I))
#  
#  are_tot_nn <- sum(score_total_nn$abs_ave) / sum(score_total$I)
#  
#  
#  dfs_output_nn <- out_nn %>%
#    mutate(DP_rev_o = 16 - DP_o + 1) %>%
#    select(AP_o, claim_type, DP_rev_o, f_o) %>%
#    mutate(DP_rev_o = DP_rev_o) %>%
#    distinct()
#  
#  #Cashflow on output scale.Etc quarterly cashflow development
#  score_diagonal_nn <- resurv_fit_cox$IndividualDataPP$full.data  %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(
#                DP_i * conversion_factor +
#                  ((AP_i - 1) %% (
#                    1 / conversion_factor
#                  )) * conversion_factor) + 1,
#      AP_o = ceiling(AP_i * conversion_factor)
#    ) %>%
#    group_by(claim_type, AP_o, DP_rev_o) %>%
#    mutate(claim_type = as.character(claim_type)) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(claim_type, AP_o) %>%
#    arrange(desc(DP_rev_o)) %>%
#    mutate(I_cum = cumsum(I)) %>%
#    mutate(I_cum_lag = lag(I_cum, default = 0)) %>%
#    left_join(dfs_output_nn, by = c("AP_o", "claim_type", "DP_rev_o")) %>%
#    mutate(I_cum_hat =  I_cum_lag * f_o,
#           RP_o = max(DP_rev_o) - DP_rev_o + AP_o) %>%
#    inner_join(true_output[, c("AP_o", "DP_rev_o")] %>%  distinct()
#               , by = c("AP_o", "DP_rev_o")) %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave2_diag = abs(sum(I_cum_hat) - sum(I_cum)), I = sum(I))
#  
#  are_cal_q_nn <- sum(score_diagonal_nn$abs_ave2_diag) / sum(score_diagonal$I)
#  
#  # Scoring Chain-Ladder ----
#  
#  true_output_cl <- individual_data$full.data %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(
#                DP_i * conversion_factor +
#                  ((AP_i - 1) %% (
#                    1 / conversion_factor
#                  )) * conversion_factor) + 1,
#      AP_o = ceiling(AP_i * conversion_factor)
#    ) %>%
#    filter(DP_rev_o <= TR_o) %>%
#    mutate(DP_o = max(individual_data$training.data$DP_rev_o) - DP_rev_o + 1) %>%
#    group_by(AP_o, DP_o, DP_rev_o) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    filter(DP_rev_o > 0)
#  latest_observed <- individual_data$training.data %>%
#    filter(DP_rev_o >= TR_o) %>%
#    mutate(DP_o = max(individual_data$training.data$DP_rev_o) - DP_rev_o + 1) %>%
#    group_by(AP_o) %>%
#    mutate(DP_max = max(DP_o)) %>%
#    group_by(AP_o, DP_max) %>%
#    summarize(I = sum(I), .groups = "drop")
#  
#  clmodel <- individual_data$training.data %>%
#    mutate(DP_o = max(individual_data$training.data$DP_rev_o) - DP_rev_o + 1) %>%
#    group_by(AP_o, DP_o) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(AP_o) %>%
#    arrange(DP_o) %>%
#    mutate(I_cum = cumsum(I), I_cum_lag = lag(I_cum, default = 0)) %>%
#    ungroup() %>%
#    group_by(DP_o) %>%
#    reframe(df = sum(I_cum * (
#      AP_o <= max(individual_data$training.data$AP_o) - DP_o + 1
#    )) /
#      sum(I_cum_lag * (
#        AP_o <= max(individual_data$training.data$AP_o) - DP_o + 1
#      )), I = sum(I * (
#      AP_o <= max(individual_data$training.data$AP_o) - DP_o
#    ))) %>%
#    mutate(DP_o_join = DP_o) %>%
#    mutate(DP_rev_o = max(DP_o) - DP_o + 1)
#  
#  predictions <- expand.grid(AP_o = latest_observed$AP_o,
#                             DP_o = clmodel$DP_o_join) %>%
#    left_join(clmodel[, c("DP_o_join", "df")], by = c("DP_o" = "DP_o_join")) %>%
#    left_join(latest_observed, by = "AP_o") %>%
#    rowwise() %>%
#    filter(DP_o > DP_max) %>%
#    ungroup() %>%
#    group_by(AP_o) %>%
#    arrange(DP_o) %>%
#    mutate(df_cum = cumprod(df)) %>%
#    mutate(I_expected = I * df_cum - I * lag(df_cum, default = 1)) %>%
#    select(DP_o, AP_o, I_expected)
#  
#  conversion_factor <- individual_data$conversion_factor
#  max_dp_i <- 1440
#  score_total <- predictions  %>%
#    inner_join(true_output_cl, by = c("AP_o", "DP_o")) %>%
#    mutate(ave = I - I_expected, abs_ave = abs(ave)) %>%
#    # from here it is reformulated for the are tot
#    ungroup() %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave = abs(sum(ave)), I = sum(I))
#  
#  are_tot <- sum(score_total$abs_ave) / sum(score_total$I)
#  
#  score_diagonal <- individual_data$full.data  %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(
#                DP_i * conversion_factor +
#                  ((AP_i - 1) %% (
#                    1 / conversion_factor
#                  )) * conversion_factor) + 1,
#      AP_o = ceiling(AP_i * conversion_factor)
#    ) %>%
#    group_by(claim_type, AP_o, DP_rev_o) %>%
#    mutate(claim_type = as.character(claim_type)) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(claim_type, AP_o) %>%
#    arrange(desc(DP_rev_o)) %>%
#    mutate(I_cum = cumsum(I)) %>%
#    mutate(I_cum_lag = lag(I_cum, default = 0)) %>%
#    mutate(DP_o = max(individual_data$training.data$DP_rev_o) - DP_rev_o + 1) %>%
#    left_join(CL[, c("DP_o", "df")], by = c("DP_o")) %>%
#    mutate(I_cum_hat =  I_cum_lag * df,
#           RP_o = max(DP_rev_o) - DP_rev_o + AP_o) %>%
#    inner_join(true_output_cl[, c("AP_o", "DP_rev_o")] %>%  distinct()
#               , by = c("AP_o", "DP_rev_o")) %>%
#    group_by(AP_o, DP_rev_o) %>%
#    reframe(abs_ave2_diag = abs(sum(I_cum_hat) - sum(I_cum)), I = sum(I))
#  
#  are_cal_q <- sum(score_diagonal$abs_ave2_diag) / sum(score_diagonal$I)
#  

