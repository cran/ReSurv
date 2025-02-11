## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  library(ReSurv)
#  reticulate::use_virtualenv("pyresurv")
#  library(data.table)
#  library(ggplot2)
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  input_data <- data_generator(random_seed = 7,
#                               scenario = 3,
#                               time_unit = 1 / 360,
#                               years = 4,
#                               period_exposure = 200)
#  
#  
#  individual_data <- IndividualDataPP(input_data,
#                                      id = "claim_number",
#                                      continuous_features = "AP_i",
#                                      categorical_features = "claim_type",
#                                      accident_period = "AP",
#                                      calendar_period = "RP",
#                                      input_time_granularity = "days",
#                                      output_time_granularity = "quarters",
#                                      years = 4,
#                                      continuous_features_spline = NULL,
#                                      calendar_period_extrapolation = FALSE)
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  hparameters <- list(params = list(booster = "gbtree",
#                                    eta = 0.2234094,
#                                    subsample = 0.8916594,
#                                    alpha = 12.44775,
#                                    lambda = 5.714286,
#                                    min_child_weight = 4.211996,
#                                    max_depth = 2),
#                      print_every_n = 0,
#                      nrounds = 3000,
#                      verbose = FALSE,
#                      early_stopping_rounds = 500)
#  
#  
#  resurv_fit <- ReSurv(individual_data,
#                       hazard_model = "XGB",
#                       hparameters = hparameters)

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  
#  resurv_fit_predict_q <- predict(resurv_fit,
#                                  grouping_method = "probability")
#  
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
#  resurv_fit_predict_y <- predict(resurv_fit,
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
#  resurv_fit_predict_m <- predict(resurv_fit,
#                                  newdata = individual_data_m,
#                                  grouping_method = "probability")
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  ticks_at <- seq(1, 48, 4)
#  labels_as <- as.character(ticks_at)
#  
#  
#  cl_months <- individual_data_m$training.data %>%
#    mutate(DP_o = 48 - DP_rev_o + 1) %>%
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
#  
#  cl_months %>%
#    filter(DP_o > 1) %>%
#    ggplot(aes(x = DP_o,
#               y = df_o)) +
#    geom_line(linewidth = 2.5, color = "#454555") +
#    labs(title = "Chain ladder",
#         x = "Development month",
#         y = "Development factor") +
#    ylim(1, 2.5 + .01) +
#    scale_x_continuous(breaks = ticks_at,
#                       labels = labels_as) +
#    theme_bw(base_size = rel(5)) +
#    theme(plot.title = element_text(size = 20))
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  cl_years <- resurv_fit$IndividualDataPP$training.data %>%
#    mutate(DP_o = 16 - DP_rev_o + 1) %>%
#    group_by(AP_o, DP_o) %>%
#    summarize(I = sum(I), .groups = "drop") %>%
#    group_by(AP_o) %>%
#    arrange(DP_o) %>%
#    mutate(I_cum = cumsum(I), I_cum_lag = lag(I_cum, default = 0)) %>%
#    ungroup() %>%
#    group_by(DP_o) %>%
#    reframe(df_o = sum(I_cum * (
#      AP_o <= max(resurv_fit$IndividualDataPP$training.data$AP_o) - DP_o + 1
#    )) /
#      sum(I_cum_lag * (
#        AP_o <= max(resurv_fit$IndividualDataPP$training.data$AP_o) - DP_o + 1
#      )),
#    I = sum(I * (
#      AP_o <= max(resurv_fit$IndividualDataPP$training.data$AP_o) - DP_o
#    ))) %>%
#    mutate(DP_o_join = DP_o - 1) %>%
#    as.data.frame()
#  
#  cl_years %>%
#    filter(DP_o > 1) %>%
#    ggplot(aes(x = DP_o, y = df_o)) +
#    geom_line(linewidth = 2.5, color = "#454555") +
#    labs(title = "Chain ladder",
#         x = "Development quarter",
#         y = "Development factor") +
#    ylim(1, 4 + .01) +
#    theme_bw(base_size = rel(5)) +
#    theme(plot.title = element_text(size = 20))
#  
#  ticks_at <- seq(1, 16, by = 2)
#  labels_as <- as.character(ticks_at)
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  ap <- 15
#  ct <- 1
#  resurv_fit_predict_q$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == 15 & claim_type == 1) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  
#  plot(
#    resurv_fit_predict_q,
#    granularity = "output",
#    title_par = "XGB: Accident Quarter 15 Claim Type 1",
#    x_text_par = "Development Quarter",
#    group_code = 30
#  )
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  ct <- 0
#  ap <- 15
#  
#  resurv_fit_predict_q$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  plot(
#    resurv_fit_predict_q,
#    granularity = "output",
#    title_par = "XGB: Accident Quarter 15 Claim Type 0",
#    x_text_par = "Development Quarter",
#    ylim_par = 4,
#    group_code = 29
#  )

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  ct <- 0
#  ap <- 16
#  
#  resurv_fit_predict_q$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  plot(
#    resurv_fit_predict_q,
#    granularity = "output",
#    title_par = "XGB: Accident Quarter 16 Claim Type 0",
#    x_text_par = "Development Quarter",
#    ylim_par = 4,
#    group_code = 31
#  )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
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
#    title_par = "XGB: Accident Month 7 Claim Type 1",
#    x_text_par = "Development Month",
#    color_par = "#a71429",
#    ylim_par = 10,
#    group_code = 14
#  )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  ct <- 0
#  ap <- 9
#  
#  resurv_fit_predict_m$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  
#  plot(
#    resurv_fit_predict_m,
#    granularity = "output",
#    title_par = "XGB: Accident Month 9 Claim Type 0",
#    x_text_par = "Development Month",
#    color_par = "#a71429",
#    ylim_par = 2.5,
#    group_code = 17
#  )

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  ct <- 0
#  ap <- 36
#  
#  
#  resurv_fit_predict_m$long_triangle_format_out$output_granularity %>%
#    filter(AP_o == ap & claim_type == ct) %>%
#    filter(row_number() == 1) %>%
#    select(group_o)
#  
#  
#  plot(
#    resurv_fit_predict_m,
#    granularity = "output",
#    title_par = "XGB: Accident Month 36 Claim Type 0",
#    color_par = "#a71429",
#    x_text_par = "Development Month",
#    ylim_par = 2.5,
#    group_code = 71
#  )
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  resurv_fit$is_lkh
#  
#  resurv_fit$os_lkh
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  beta <- 2 * 30
#  lambda <- 0.1
#  k <- 1
#  b <- 1440
#  alpha <- 0.5
#  beta0 <- 1.15129
#  beta1 <- 1.95601
#  
#  f_correct_s0 <- function(t, alpha, beta, lambda, k, b, beta_coef) {
#  
#    inner <- lambda * exp(beta_coef) ^ (1 / (alpha * k))
#    element_one <- -beta ^ alpha * (inner) ^ (alpha * k)
#    element_two <- (t ^ (-alpha * k) - b ^ (-alpha * k))
#    exp(element_one * element_two)
#  }
#  
#  c_correct_grouped <- c()
#  for (i in 0:(b - 1)) {
#    t <- seq(i, i + 1, by = 0.001)
#    n_t <- length(t)
#    calculation <- f_correct_s0(t, alpha, beta, lambda, k, b, beta0)
#    c_correct_grouped[i + 1] <- sum(1 - calculation) /
#      n_t
#  }
#  c_correct_grouped <- c(1, c_correct_grouped[1:(b - 1)])
#  
#  c_correct_grouped1 <- c()
#  for (i in 0:(b - 1)) {
#    t <- seq(i, i + 1, by = 0.001)
#    n_t <- length(t)
#    calculation <- f_correct_s0(t, alpha, beta, lambda, k, b, beta1)
#    c_correct_grouped1[i + 1] <- sum(1 - calculation) /
#      n_t
#  }
#  c_correct_grouped1 <- c(1, c_correct_grouped1[1:(b - 1)])
#  
#  true_curve <- data.table(
#    "DP_rev_i" = (b - 1) - seq(0, (b - 1), by = 1),
#    "S_i" = 1 - (c_correct_grouped1),
#    "model_label" = "TRUE"
#  )

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  input_data <- data_generator(
#    random_seed = 1,
#    scenario = 0,
#    time_unit = 1 / 360,
#    years = 4,
#    period_exposure = 200
#  )
#  
#  
#  individual_data <- IndividualDataPP(
#    input_data,
#    id = "claim_number",
#    continuous_features = "AP_i",
#    categorical_features = "claim_type",
#    accident_period = "AP",
#    calendar_period = "RP",
#    input_time_granularity = "days",
#    output_time_granularity = "quarters",
#    years = 4,
#    continuous_features_spline = NULL,
#    calendar_period_extrapolation = FALSE
#  )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  hparameters_xgb_01 <- list(
#    params = list(
#      booster = "gbtree",
#      eta = 0.9887265,
#      subsample = 0.7924135,
#      alpha = 10.85342,
#      lambda = 6.213317,
#      min_child_weight = 3.042204,
#      max_depth = 1
#    ),
#    print_every_n = 0,
#    nrounds = 3000,
#    verbose = FALSE,
#    early_stopping_rounds = 500
#  )
#  
#  
#  hparameters_nn_01 <- list(
#    num_layers = 2,
#    early_stopping = TRUE,
#    patience = 350,
#    verbose = FALSE,
#    network_structure = NULL,
#    num_nodes = 10,
#    activation = "SELU",
#    optim = "SGD",
#    lr = 0.2741031,
#    xi = 0.3829451,
#    epsilon = 0,
#    batch_size = as.integer(5000),
#    epochs = as.integer(5500),
#    num_workers = 0,
#    tie = "Efron"
#  )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  resurv_fit_cox_01 <- ReSurv(individual_data,
#                               hazard_model = "COX")
#  
#  resurv_fit_nn_01 <- ReSurv(individual_data,
#                               hazard_model = "NN",
#                               hparameters = hparameters_nn_01)
#  
#  resurv_fit_xgb_01 <- ReSurv(individual_data,
#                               hazard_model = "XGB",
#                               hparameters = hparameters_xgb_01)
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  hazard_frame_updated_cox <- resurv_fit_cox_01$hazard_frame
#  
#  hazard_frame_updated_nn <- resurv_fit_nn_01$hazard_frame
#  
#  hazard_frame_updated_xgb <- resurv_fit_xgb_01$hazard_frame
#  
#  
#  cond_1 <- hazard_frame_updated_cox$AP_i == 13 &
#    hazard_frame_updated_cox$claim_type == 1
#  estimated_cox <- hazard_frame_updated_cox[, c("S_i", "DP_rev_i")]
#  estimated_cox <- as.data.table(estimated_cox)[, model_label := "COX"]
#  
#  cond_2 <- hazard_frame_updated_nn$AP_i == 13 &
#    hazard_frame_updated_nn$claim_type == 1
#  estimated_nn <- hazard_frame_updated_nn[cond_2, c("S_i", "DP_rev_i")]
#  estimated_nn <- as.data.table(estimated_nn)[, model_label := "NN"]
#  
#  
#  cond_3 <- hazard_frame_updated_xgb$AP_i == 13 &
#    hazard_frame_updated_xgb$claim_type == 1
#  estimated_xgb <- hazard_frame_updated_xgb[, c("S_i", "DP_rev_i")]
#  estimated_xgb <- as.data.table(estimated_xgb)[cond3, model_label := "XGB"]
#  
#  dt <- rbind(estimated_cox, estimated_nn, estimated_xgb)
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  ggplot(data = dt, aes(x = DP_rev_i, y = S_i, color = model_label)) +
#    geom_line(linewidth = 1) +
#    facet_grid(~ model_label) +
#    annotate(
#      geom = "line",
#      x = true_curve$DP_rev_i,
#      y = true_curve$S_i,
#      lty = 2,
#      linewidth = 1
#    ) +
#    scale_x_continuous(
#      expand = c(0, 0),
#      breaks = c(0, 440, 940),
#      labels = c("1440", "1000", "500")
#    ) +
#    scale_y_continuous(expand = c(0, .001)) +
#    xlab("Development time") +
#    ylab("Survival function") +
#    scale_color_manual(name = "Model",
#                       values = c("#AAAABC", "#a71429", "#4169E1")) +
#    theme_bw() +
#    theme(
#      legend.position = "none",
#      text = element_text(size = 20),
#      axis.text.x = element_text(
#        angle = 90,
#        vjust = 0.5,
#        hjust = 1
#      )
#    )
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  my_ap = 691
#  period_function <- function(x) {
#    "
#    Add monthly seasonal effect starting from daily input.
#  
#    "
#  
#    tmp <- floor((x - 1) / 30)
#  
#    if ((tmp %% 12) %in% (c(2, 3, 4))) {
#      return(-0.3)
#    }
#    if ((tmp %% 12) %in% (c(5, 6, 7))) {
#      return(0.4)
#    }
#    if ((tmp %% 12) %in% (c(8, 9, 10))) {
#      return(-0.7)
#    }
#    if ((tmp %% 12) %in% (c(11, 0, 1))) {
#      #0 instead of 12
#      return(0.1)
#    }
#  }
#  
#  beta <- 2 * 30
#  lambda <- 0.1
#  k <- 1
#  b <- 1440
#  alpha <- 0.5
#  beta0 <- 1.15129
#  beta1 <- 1.95601 + period_function(my_ap)
#  
#  f_correct_s0 <- function(t, alpha, beta, lambda, k, b, beta_coef) {
#    element_1 <- -beta ^ alpha
#    element_2 <- lambda * exp(beta_coef) ^ (1 / (alpha * k))
#    element_ 3 <- t ^ (-alpha * k) - b ^ (-alpha * k)
#    exp(element_1 * (element_2) ^ (alpha * k) * ())
#  }
#  
#  c_correct_grouped <- c()
#  for (i in 0:(b - 1)) {
#    t <- seq(i, i + 1, by = 0.001)
#    n_t <- length(t)
#    calculation <- f_correct_s0(t, alpha, beta, lambda, k, b, beta0)
#    c_correct_grouped[i + 1] <- sum(1 - calculation) /
#      n_t
#  }
#  c_correct_grouped <- c(1, c_correct_grouped[1:(b - 1)])
#  
#  c_correct_grouped1 <- c()
#  for (i in 0:(b - 1)) {
#    t <- seq(i, i + 1, by = 0.001)
#    n_t <- length(t)
#    calculation <- f_correct_s0(t, alpha, beta, lambda, k, b, beta1)
#    c_correct_grouped1[i + 1] <- sum(1 - calculation) / n_t
#  }
#  c_correct_grouped1 <- c(1, c_correct_grouped1[1:(b - 1)])
#  
#  true_curve <- data.table(
#    "DP_rev_i" = (b - 1) - seq(0, (b - 1), by = 1),
#    "S_i" = 1 - (c_correct_grouped1),
#    "model_label" = "TRUE"
#  )

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  input_data <- data_generator(
#    random_seed = 1,
#    scenario = 3,
#    time_unit = 1 / 360,
#    years = 4,
#    period_exposure = 200
#  )
#  
#  
#  individual_data <- IndividualDataPP(
#    input_data,
#    id = "claim_number",
#    continuous_features = "AP_i",
#    categorical_features = "claim_type",
#    accident_period = "AP",
#    calendar_period = "RP",
#    input_time_granularity = "days",
#    output_time_granularity = "quarters",
#    years = 4,
#    continuous_features_spline = NULL,
#    calendar_period_extrapolation = F
#  )
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  hparameters_xgb_31 <- list(
#    params = list(
#      booster = "gbtree",
#      eta = 0.1801517,
#      subsample = 0.8768306,
#      alpha = 0.6620562,
#      lambda = 1.379897,
#      min_child_weight = 15.61339,
#      max_depth = 2
#    ),
#    print_every_n = 0,
#    nrounds = 3000,
#    verbose = FALSE,
#    early_stopping_rounds = 500
#  )
#  
#  hparameters_nn_31 <- list(
#    num_layers = 2,
#    early_stopping = TRUE,
#    patience = 350,
#    verbose = FALSE,
#    network_structure = NULL,
#    num_nodes = 2,
#    activation = "LeakyReLU",
#    optim = "Adam",
#    lr = 0.3542422,
#    xi = 0.1803953,
#    epsilon = 0,
#    batch_size = as.integer(5000),
#    epochs = as.integer(5500),
#    num_workers = 0,
#    tie = "Efron"
#  )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  resurv_fit_cox_31 <- ReSurv(individual_data, hazard_model = "COX")
#  
#  resurv_fit_nn_31 <- ReSurv(individual_data,
#                             hazard_model = "NN",
#                             hparameters = hparameters_nn_31)
#  
#  resurv_fit_xgb_31 <- ReSurv(individual_data,
#                              hazard_model = "XGB",
#                              hparameters = hparameters_xgb_31)
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  hazard_frame_updated_cox <- resurv_fit_cox_31$hazard_frame
#  
#  hazard_frame_updated_nn <- resurv_fit_nn_31$hazard_frame
#  
#  hazard_frame_updated_xgb <- resurv_fit_xgb_31$hazard_frame
#  
#  
#  
#  cond_1 <- hazard_frame_updated_cox$AP_i == my_ap &
#    hazard_frame_updated_cox$claim_type == 1
#  
#  estimated_cox <- hazard_frame_updated_cox[cond_1, c("S_i", "DP_rev_i")]
#  estimated_cox <- as.data.table(estimated_cox)[, model_label := 'COX']
#  
#  cond_2 <- hazard_frame_updated_nn$AP_i == my_ap &
#    hazard_frame_updated_nn$claim_type == 1
#  estimated_nn <- hazard_frame_updated_nn[cond_2, c("S_i", "DP_rev_i")]
#  estimated_nn <- as.data.table(estimated_nn)[, model_label := 'NN']
#  
#  cond_3 <- hazard_frame_updated_xgb$AP_i == my_ap &
#    hazard_frame_updated_xgb$claim_type == 1
#  estimated_xgb <- hazard_frame_updated_xgb[cond_3, c("S_i", "DP_rev_i")]
#  estimated_xgb <- as.data.table(estimated_xgb)[, model_label := 'XGB']
#  
#  dt <- rbind(estimated_cox, estimated_nn, estimated_xgb)
#  
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  ggplot(data = dt, aes(x = DP_rev_i, y = S_i, color = model_label)) +
#    geom_line(linewidth = 1) +
#    facet_grid( ~ model_label) +
#    annotate(
#      geom = 'line',
#      x = true_curve$DP_rev_i,
#      y = true_curve$S_i,
#      lty = 2,
#      linewidth = 1
#    ) +
#    scale_x_continuous(
#      expand = c(0, 0),
#      breaks = c(0, 440, 940),
#      labels = c("1440", "1000", "500")
#    ) +
#    scale_y_continuous(expand = c(0, .001)) +
#    xlab("Development time") +
#    ylab("Survival function") +
#    scale_color_manual(name = "Model",
#                       values = c("#AAAABC", "#a71429", "#4169E1")) +
#    theme_bw() +
#    theme(
#      legend.position = "none",
#      text = element_text(size = 20),
#      axis.text.x = element_text(
#        angle = 90,
#        vjust = 0.5,
#        hjust = 1
#      )
#    )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  seed = 1
#  scenario = 0
#  
#  input_data <- data_generator(
#    random_seed = seed,
#    scenario = scenario,
#    time_unit = 1 / 360,
#    years = 4,
#    period_exposure = 200
#  )
#  
#  individual_data <- IndividualDataPP(
#    input_data,
#    id = "claim_number",
#    continuous_features = "AP_i",
#    categorical_features = "claim_type",
#    accident_period = "AP",
#    calendar_period = "RP",
#    input_time_granularity = "days",
#    output_time_granularity = "quarters",
#    years = 4,
#    continuous_features_spline = NULL,
#    calendar_period_extrapolation = FALSE
#  )
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  start <- Sys.time()
#  
#  resurv_fit <- ReSurv(individual_data, hazard_model = "COX")
#  
#  resurv_fit_predict <- predict(resurv_fit, grouping_method = "probability")
#  
#  time <- Sys.time() - start

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  conversion_factor <- individual_data$conversion_factor
#  
#  max_dp_i <- 1440
#  
#  # Compute the continuously Ranked Probability Score (CRPS) ----
#  
#  crps_dt <- ReSurv::survival_crps(resurv_fit)
#  crps_result <- mean(crps_dt$crps)
#  
#  # Compute the ARE tot ----
#  
#  true_output <- resurv_fit$IndividualDataPP$full.data %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(DP_i * conversion_factor +
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
#  
#  out_list <- resurv_fit_predict$long_triangle_format_out
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
#  score_diagonal <- resurv_fit$IndividualDataPP$full.data  %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(DP_i * conversion_factor +
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

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  individual_data2 <- IndividualDataPP(
#    input_data,
#    id = "claim_number",
#    continuous_features = "AP_i",
#    categorical_features = "claim_type",
#    accident_period = "AP",
#    calendar_period = "RP",
#    input_time_granularity = "days",
#    output_time_granularity = "years",
#    years = 4,
#    continuous_features_spline = NULL,
#    calendar_period_extrapolation = F
#  )
#  
#  resurv_predict_yearly <- predict(resurv_fit,
#                                   newdata = individual_data2,
#                                   grouping_method = "probability")
#  
#  conversion_factor <- individual_data2$conversion_factor
#  
#  
#  max_dp_i <- 1440
#  
#  true_output <- individual_data2$full.data %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(DP_i * conversion_factor +
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
#  out_list_yearly <- resurv_predict_yearly$long_triangle_format_out
#  out_yearly <- out_list_yearly$output_granularity
#  
#  dfs_output <- out_yearly %>%
#    mutate(DP_rev_o = 4 - DP_o + 1) %>%
#    select(AP_o, claim_type, DP_rev_o, f_o) %>%
#    mutate(DP_rev_o = DP_rev_o) %>%
#    distinct()
#  
#  score_diagonal_yearly <- individual_data2$full.data  %>%
#    mutate(
#      DP_rev_o = floor(max_dp_i * conversion_factor) -
#        ceiling(DP_i * conversion_factor +
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
#  are_cal_y = sum(score_diagonal_yearly$abs_ave2_diag) /
#    sum(score_diagonal_yearly$I)
#  

