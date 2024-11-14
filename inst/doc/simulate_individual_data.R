## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(ReSurv)
library(ggplot2)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  # Input data
#  
#  input_data_0 <- data_generator(
#    random_seed = 1964,
#    scenario = "alpha",
#    time_unit = 1 / 360,
#    years = 4,
#    period_exposure = 200
#  )
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data_0 %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = RT - AT, color = claim_type)) +
#    stat_ecdf(size = 1) +
#    labs(title = "Empirical distribution of simulated notification delays", x =
#           "Notification delay (in days)", y = "Cumulative Density") +
#    xlim(0, 1500) +
#    scale_color_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    scale_linetype_manual(values = c(1, 3),
#                          labels = c("Claim type 0", "Claim type 1")) +
#    guides(
#      color = guide_legend(title = "Claim type", override.aes = list(
#        color = c("royalblue", "#a71429"), size = 2
#      )),
#      linetype = guide_legend(
#        title = "Claim type",
#        override.aes = list(linetype = c(1, 3), size = 0.7)
#      )
#    ) +
#    theme_bw()

## ----include=TRUE, eval =FALSE------------------------------------------------
#  
#  input_data_1 <- data_generator(
#    random_seed = 1964,
#    scenario = 1,
#    time_unit = 1 / 360,
#    years = 4,
#    period_exposure  = 200
#  )
#  

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data_1 %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = RT - AT, color = claim_type)) +
#    stat_ecdf(size = 1) +
#    labs(title = "Empirical distribution of simulated notification delays", x =
#           "Notification delay (in days)", y = "Cumulative Density") +
#    xlim(0, 1500) +
#    scale_color_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    scale_linetype_manual(values = c(1, 3),
#                          labels = c("Claim type 0", "Claim type 1")) +
#    guides(
#      color = guide_legend(title = "Claim type", override.aes = list(
#        color = c("royalblue", "#a71429"), size = 2
#      )),
#      linetype = guide_legend(
#        title = "Claim type",
#        override.aes = list(linetype = c(1, 3), size = 0.7)
#      )
#    ) +
#    theme_bw()

## -----------------------------------------------------------------------------
# Input data

input_data_2 <- data_generator(
  random_seed = 1964,
  scenario = 2,
  time_unit = 1 / 360,
  years = 4,
  period_exposure = 200
)


## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data_2 %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = RT - AT, color = claim_type)) +
#    stat_ecdf(size = 1) +
#    labs(title = "Empirical distribution of simulated notification delays", x =
#           "Notification delay (in days)", y = "Cumulative Density") +
#    xlim(0, 1500) +
#    scale_color_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    scale_linetype_manual(values = c(1, 3),
#                          labels = c("Claim type 0", "Claim type 1")) +
#    guides(
#      color = guide_legend(title = "Claim type", override.aes = list(
#        color = c("royalblue", "#a71429"), size = 2
#      )),
#      linetype = guide_legend(
#        title = "Claim type",
#        override.aes = list(linetype = c(1, 3), size = 0.7)
#      )
#    ) +
#    theme_bw()

## -----------------------------------------------------------------------------

input_data_3 <- data_generator(
  random_seed = 1964,
  scenario = 3,
  time_unit = 1 / 360,
  years = 4,
  period_exposure = 200
)


## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data_3 %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = RT - AT, color = claim_type)) +
#    stat_ecdf(size = 1) +
#    labs(title = "Empirical distribution of simulated notification delays", x =
#           "Notification delay (in days)", y = "Cumulative Density") +
#    xlim(0, 1500) +
#    scale_color_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    scale_linetype_manual(values = c(1, 3),
#                          labels = c("Claim type 0", "Claim type 1")) +
#    guides(
#      color = guide_legend(title = "Claim type", override.aes = list(
#        color = c("royalblue", "#a71429"), size = 2
#      )),
#      linetype = guide_legend(
#        title = "Claim type",
#        override.aes = list(linetype = c(1, 3), size = 0.7)
#      )
#    ) +
#    theme_bw()

## -----------------------------------------------------------------------------
# Input data

input_data_4 <- data_generator(
  random_seed = 1964,
  scenario = 4,
  time_unit = 1 / 360,
  years = 4,
  period_exposure = 200
)


## ----eval=FALSE, include=TRUE-------------------------------------------------
#  input_data_4 %>%
#    as.data.frame() %>%
#    mutate(claim_type = as.factor(claim_type)) %>%
#    ggplot(aes(x = RT - AT, color = claim_type)) +
#    stat_ecdf(size = 1) +
#    labs(title = "Empirical distribution of simulated notification delays", x =
#           "Notification delay (in days)", y = "Cumulative Density") +
#    xlim(0, 1500) +
#    scale_color_manual(
#      values = c("royalblue", "#a71429"),
#      labels = c("Claim type 0", "Claim type 1")
#    ) +
#    scale_linetype_manual(values = c(1, 3),
#                          labels = c("Claim type 0", "Claim type 1")) +
#    guides(
#      color = guide_legend(title = "Claim type", override.aes = list(
#        color = c("royalblue", "#a71429"), size = 2
#      )),
#      linetype = guide_legend(
#        title = "Claim type",
#        override.aes = list(linetype = c(1, 3), size = 0.7)
#      )
#    ) +
#    theme_bw()
#  

