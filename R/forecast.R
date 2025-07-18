
#' @title Forecasting using Structural Vector Autoregression
#'
#' @description Samples from the joint predictive density of all of the dependent 
#' variables for models from packages \pkg{bsvars}, \pkg{bsvarSIGNs} or 
#' \pkg{bvarPANELs} at forecast horizons from 1 to \code{horizon} specified as 
#' an argument of the function.
#' 
#' @param posterior posterior estimation outcome
#' obtained by running the \code{estimate} function.
#' @param horizon a positive integer, specifying the forecasting horizon.
#' @param exogenous_forecast forecasted values of the exogenous variables.
#' @param conditional_forecast forecasted values for selected variables.
#' 
#' @return A list of class \code{Forecasts} containing the
#' draws from the predictive density and for heteroskedastic models the draws 
#' from the predictive density of structural shocks conditional standard 
#' deviations and data. The output elements include:
#' 
#' \describe{
#'  \item{forecasts}{an \code{NxTxS} array with the draws from predictive density}
#'  \item{forecasts_sigma}{provided only for heteroskedastic models, an \code{NxTxS} array with the draws 
#'  from the predictive density of structural shocks conditional standard deviations}
#'  \item{Y}{an \eqn{NxT} matrix with the data on dependent variables}
#' }
#'
#' @author Tomasz Woźniak \email{wozniak.tom@pm.me}
#' 
#' @examples
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' set.seed(123)
#' specification  = specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 10)
#' 
#' # sample from predictive density 1 year ahead
#' predictive     = forecast(posterior, 4)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar$new(p = 1) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(horizon = 4) -> predictive
#' 
#' # conditional forecasting using a model with exogenous variables
#' ############################################################
#' data(us_fiscal_ex_forecasts)      # upload exogenous variables future values
#' data(us_fiscal_cond_forecasts)    # upload a matrix with projected ttr
#' 
#' #' set.seed(123)
#' specification  = specify_bsvar$new(us_fiscal_lsuw, p = 1, exogenous = us_fiscal_ex)
#' burn_in        = estimate(specification, 5)
#' posterior      = estimate(burn_in, 10)
#' 
#' # forecast 2 years ahead
#' predictive     = forecast(
#'                     posterior, 
#'                     horizon = 8,
#'                     exogenous_forecast = us_fiscal_ex_forecasts,
#'                     conditional_forecast = us_fiscal_cond_forecasts
#'                   )
#' summary(predictive)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar$new(p = 1, exogenous = us_fiscal_ex) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(
#'     horizon = 8,
#'     exogenous_forecast = us_fiscal_ex_forecasts,
#'     conditional_forecast = us_fiscal_cond_forecasts
#'   ) |> plot()
#'   
#' @export
forecast <- function(
    posterior, 
    horizon = 1, 
    exogenous_forecast,
    conditional_forecast
) {
  stopifnot("Argument horizon must be a positive integer number." = horizon > 0 & horizon %% 1 == 0)
  UseMethod("forecast", posterior)
}



#' @inherit forecast
#' @method forecast PosteriorBSVAR
#' @param posterior posterior estimation outcome - an object of class 
#' \code{PosteriorBSVAR} obtained by running the \code{estimate} function.
#' @param exogenous_forecast a matrix of dimension \code{horizon x d} containing 
#' forecasted values of the exogenous variables. 
#' @param conditional_forecast a \code{horizon x N} matrix with forecasted values 
#' for selected variables. It should only contain \code{numeric} or \code{NA} 
#' values. The entries with \code{NA} values correspond to the values that are 
#' forecasted conditionally on the realisations provided as \code{numeric} values.
#' 
#' @return A list of class \code{Forecasts} containing the
#' draws from the predictive density and data. The output list includes element:
#' 
#' \describe{
#'  \item{forecasts}{an \code{NxTxS} array with the draws from predictive density}
#'  \item{Y}{an \eqn{NxT} matrix with the data on dependent variables}
#' }
#' 
#' @examples
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' set.seed(123)
#' specification  = specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 10)
#' 
#' # sample from predictive density 1 year ahead
#' predictive     = forecast(posterior, 4)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar$new(p = 1) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(horizon = 4) -> predictive
#' 
#' # conditional forecasting using a model with exogenous variables
#' ############################################################
#' data(us_fiscal_ex_forecasts)      # upload exogenous variables future values
#' data(us_fiscal_cond_forecasts)    # upload a matrix with projected ttr
#' 
#' #' set.seed(123)
#' specification  = specify_bsvar$new(us_fiscal_lsuw, p = 1, exogenous = us_fiscal_ex)
#' burn_in        = estimate(specification, 5)
#' posterior      = estimate(burn_in, 10)
#' 
#' # forecast 2 years ahead
#' predictive     = forecast(
#'                     posterior, 
#'                     horizon = 8,
#'                     exogenous_forecast = us_fiscal_ex_forecasts,
#'                     conditional_forecast = us_fiscal_cond_forecasts
#'                   )
#' summary(predictive)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar$new(p = 1, exogenous = us_fiscal_ex) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(
#'     horizon = 8,
#'     exogenous_forecast = us_fiscal_ex_forecasts,
#'     conditional_forecast = us_fiscal_cond_forecasts
#'   ) |> plot()
#' 
#' @export
forecast.PosteriorBSVAR = function(
    posterior, 
    horizon = 1, 
    exogenous_forecast = NULL,
    conditional_forecast = NULL
) {
  
  posterior_B     = posterior$posterior$B
  posterior_A     = posterior$posterior$A
  T               = ncol(posterior$last_draw$data_matrices$X)
  X_T             = posterior$last_draw$data_matrices$X[,T]
  Y               = posterior$last_draw$data_matrices$Y
  
  N               = nrow(posterior_B)
  K               = length(X_T)
  d               = K - N * posterior$last_draw$p - 1
  S               = dim(posterior_B)[3]
  
  # prepare forecasting with exogenous variables
  if (d == 0 ) {
    exogenous_forecast = matrix(NA, horizon, 1)
  } else {
    stopifnot("Forecasted values of exogenous variables are missing." = (d > 0) & !is.null(exogenous_forecast))
    stopifnot("The matrix of exogenous_forecast does not have a correct number of columns." = ncol(exogenous_forecast) == d)
    stopifnot("Provide exogenous_forecast for all forecast periods specified by argument horizon." = nrow(exogenous_forecast) == horizon)
    stopifnot("Argument exogenous has to be a matrix." = is.matrix(exogenous_forecast) & is.numeric(exogenous_forecast))
    stopifnot("Argument exogenous cannot include missing values." = sum(is.na(exogenous_forecast)) == 0 )
  }
  
  # prepare forecasting with conditional forecasts
  if ( is.null(conditional_forecast) ) {
    # this will not be used for forecasting, but needs to be provided
    conditional_forecast = matrix(NA, horizon, N)
  } else {
    stopifnot("Argument conditional_forecast must be a matrix with numeric values."
              = is.matrix(conditional_forecast) & is.numeric(conditional_forecast)
    )
    stopifnot("Argument conditional_forecast must have the number of rows equal to 
              the value of argument horizon."
              = nrow(conditional_forecast) == horizon
    )
    stopifnot("Argument conditional_forecast must have the number of columns 
              equal to the number of columns in the used data."
              = ncol(conditional_forecast) == N
    )
  }
  
  # forecast volatility
  forecast_sigma2   = array(1, c(N, horizon, S))
  
  # perform forecasting
  for_y       = .Call(`_bsvars_forecast_bsvars`, 
                      posterior_B,
                      posterior_A,
                      forecast_sigma2,    # (N, horizon, S)
                      X_T,
                      exogenous_forecast,
                      conditional_forecast,
                      horizon
                ) # END .Call
  
  SS                  = dim(for_y$forecasts)[3]
  forecast_covariance = array(NA, c(N, N, horizon, SS))
  for (s in 1:SS) forecast_covariance[,,,s] = for_y$forecast_cov[s,][[1]]
  
  fore                = for_y
  fore$forecast_covariance = forecast_covariance
  fore$forecasts_sigma = forecast_sigma2
  fore$Y          = Y
  class(fore)     = "Forecasts"
  
  return(fore)
} # END forecast.PosteriorBSVAR







#' @inherit forecast
#' @method forecast PosteriorBSVARMSH
#' @param posterior posterior estimation outcome - an object of class 
#' \code{PosteriorBSVARMSH} obtained by running the \code{estimate} function.
#' @param exogenous_forecast a matrix of dimension \code{horizon x d} containing 
#' forecasted values of the exogenous variables.
#' @param conditional_forecast a \code{horizon x N} matrix with forecasted values 
#' for selected variables. It should only contain \code{numeric} or \code{NA} 
#' values. The entries with \code{NA} values correspond to the values that are 
#' forecasted conditionally on the realisations provided as \code{numeric} values.
#' 
#' @examples
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' set.seed(123)
#' specification  = specify_bsvar_msh$new(us_fiscal_lsuw, p = 1, M = 2)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 10)
#' 
#' # sample from predictive density 1 year ahead
#' predictive     = forecast(posterior, 4)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_msh$new(p = 1, M = 2) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(horizon = 4) -> predictive
#'   
#' # conditional forecasting using a model with exogenous variables
#' ############################################################
#' data(us_fiscal_ex_forecasts)      # upload exogenous variables future values
#' data(us_fiscal_cond_forecasts)    # upload a matrix with projected ttr
#' 
#' #' set.seed(123)
#' specification  = specify_bsvar_msh$new(us_fiscal_lsuw, M = 2, exogenous = us_fiscal_ex)
#' burn_in        = estimate(specification, 5)
#' posterior      = estimate(burn_in, 10)
#' 
#' # forecast 2 years ahead
#' predictive     = forecast(
#'                     posterior, 
#'                     horizon = 8,
#'                     exogenous_forecast = us_fiscal_ex_forecasts,
#'                     conditional_forecast = us_fiscal_cond_forecasts
#'                   )
#' summary(predictive)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_msh$new(M = 2, exogenous = us_fiscal_ex) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(
#'     horizon = 8,
#'     exogenous_forecast = us_fiscal_ex_forecasts,
#'     conditional_forecast = us_fiscal_cond_forecasts
#'   ) |> plot()
#'   
#' @export
forecast.PosteriorBSVARMSH = function(
    posterior, 
    horizon = 1, 
    exogenous_forecast = NULL,
    conditional_forecast = NULL
) {
  
  posterior_B       = posterior$posterior$B
  posterior_A       = posterior$posterior$A
  posterior_sigma2  = posterior$posterior$sigma2
  posterior_PR_TR   = posterior$posterior$PR_TR
  T                 = ncol(posterior$last_draw$data_matrices$X)
  X_T               = posterior$last_draw$data_matrices$X[,T]
  Y                 = posterior$last_draw$data_matrices$Y
  S_T               = posterior$posterior$xi[,T,]
  
  N               = nrow(posterior_B)
  K               = length(X_T)
  d               = K - N * posterior$last_draw$p - 1
  S               = dim(posterior_B)[3]
  
  # prepare forecasting with exogenous variables
  if (d == 0 ) {
    exogenous_forecast = matrix(NA, horizon, 1)
  } else {
    stopifnot("Forecasted values of exogenous variables are missing." = (d > 0) & !is.null(exogenous_forecast))
    stopifnot("The matrix of exogenous_forecast does not have a correct number of columns." = ncol(exogenous_forecast) == d)
    stopifnot("Provide exogenous_forecast for all forecast periods specified by argument horizon." = nrow(exogenous_forecast) == horizon)
    stopifnot("Argument exogenous has to be a matrix." = is.matrix(exogenous_forecast) & is.numeric(exogenous_forecast))
    stopifnot("Argument exogenous cannot include missing values." = sum(is.na(exogenous_forecast)) == 0 )
  }
  
  # prepare forecasting with conditional forecasts
  if ( is.null(conditional_forecast) ) {
    # this will not be used for forecasting, but needs to be provided
    conditional_forecast = matrix(NA, horizon, N)
  } else {
    stopifnot("Argument conditional_forecast must be a matrix with numeric values."
              = is.matrix(conditional_forecast) & is.numeric(conditional_forecast)
    )
    stopifnot("Argument conditional_forecast must have the number of rows equal to 
              the value of argument horizon."
              = nrow(conditional_forecast) == horizon
    )
    stopifnot("Argument conditional_forecast must have the number of columns 
              equal to the number of columns in the used data."
              = ncol(conditional_forecast) == N
    )
  }
  
  # forecast volatility
  forecast_sigma2   = .Call(`_bsvars_forecast_sigma2_msh`, 
                            posterior_sigma2,
                            posterior_PR_TR,
                            S_T,
                            horizon
                      )  # END .Call
  
  # perform forecasting
  for_y       = .Call(`_bsvars_forecast_bsvars`, 
                      posterior_B,
                      posterior_A,
                      forecast_sigma2,    # (N, horizon, S)
                      X_T,
                      exogenous_forecast,
                      conditional_forecast,
                      horizon
                  ) # END .Call
  
  SS                  = dim(for_y$forecasts)[3]
  forecast_covariance = array(NA, c(N, N, horizon, SS))
  for (s in 1:SS) forecast_covariance[,,,s] = for_y$forecast_cov[s,][[1]]
  
  fore                = for_y
  fore$forecast_covariance = forecast_covariance
  fore$forecasts_sigma  = forecast_sigma2
  fore$Y                = Y
  class(fore)           = "Forecasts"
  
  return(fore)
} # END forecast.PosteriorBSVARMSH



#' @inherit forecast
#' @method forecast PosteriorBSVARMIX
#' @param posterior posterior estimation outcome - an object of class 
#' \code{PosteriorBSVARMIX} obtained by running the \code{estimate} function.
#' @param exogenous_forecast a matrix of dimension \code{horizon x d} containing 
#' forecasted values of the exogenous variables.
#' @param conditional_forecast a \code{horizon x N} matrix with forecasted values 
#' for selected variables. It should only contain \code{numeric} or \code{NA} 
#' values. The entries with \code{NA} values correspond to the values that are 
#' forecasted conditionally on the realisations provided as \code{numeric} values.
#' 
#' @examples
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' set.seed(123)
#' specification  = specify_bsvar_mix$new(us_fiscal_lsuw, p = 1, M = 2)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 10)
#' 
#' # sample from predictive density 1 year ahead
#' predictive     = forecast(posterior, 4)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_mix$new(p = 1, M = 2) |>
#'   estimate(S = 5) |>
#'   estimate(S = 10) |>  
#'   forecast(horizon = 4) -> predictive
#'   
#' # conditional forecasting using a model with exogenous variables
#' ############################################################
#' data(us_fiscal_ex_forecasts)      # upload exogenous variables future values
#' data(us_fiscal_cond_forecasts)    # upload a matrix with projected ttr
#' 
#' #' set.seed(123)
#' specification  = specify_bsvar_mix$new(us_fiscal_lsuw, M = 2, exogenous = us_fiscal_ex)
#' burn_in        = estimate(specification, 5)
#' posterior      = estimate(burn_in, 10)
#' 
#' # forecast 2 years ahead
#' predictive     = forecast(
#'                     posterior, 
#'                     horizon = 8,
#'                     exogenous_forecast = us_fiscal_ex_forecasts,
#'                     conditional_forecast = us_fiscal_cond_forecasts
#'                   )
#' summary(predictive)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_mix$new(M = 2, exogenous = us_fiscal_ex) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(
#'     horizon = 8,
#'     exogenous_forecast = us_fiscal_ex_forecasts,
#'     conditional_forecast = us_fiscal_cond_forecasts
#'   ) |> plot()
#'  
#' @export
forecast.PosteriorBSVARMIX = function(
    posterior, 
    horizon = 1, 
    exogenous_forecast = NULL,
    conditional_forecast = NULL
) {
  
  posterior_B       = posterior$posterior$B
  posterior_A       = posterior$posterior$A
  posterior_sigma2  = posterior$posterior$sigma2
  posterior_PR_TR   = posterior$posterior$PR_TR
  T                 = ncol(posterior$last_draw$data_matrices$X)
  X_T               = posterior$last_draw$data_matrices$X[,T]
  Y                 = posterior$last_draw$data_matrices$Y
  S_T               = posterior$posterior$xi[,T,]
  
  N               = nrow(posterior_B)
  K               = length(X_T)
  d               = K - N * posterior$last_draw$p - 1
  S               = dim(posterior_B)[3]
  
  # prepare forecasting with exogenous variables
  if (d == 0 ) {
    exogenous_forecast = matrix(NA, horizon, 1)
  } else {
    stopifnot("Forecasted values of exogenous variables are missing." = (d > 0) & !is.null(exogenous_forecast))
    stopifnot("The matrix of exogenous_forecast does not have a correct number of columns." = ncol(exogenous_forecast) == d)
    stopifnot("Provide exogenous_forecast for all forecast periods specified by argument horizon." = nrow(exogenous_forecast) == horizon)
    stopifnot("Argument exogenous has to be a matrix." = is.matrix(exogenous_forecast) & is.numeric(exogenous_forecast))
    stopifnot("Argument exogenous cannot include missing values." = sum(is.na(exogenous_forecast)) == 0 )
  }
  
  # prepare forecasting with conditional forecasts
  if ( is.null(conditional_forecast) ) {
    # this will not be used for forecasting, but needs to be provided
    conditional_forecast = matrix(NA, horizon, N)
  } else {
    stopifnot("Argument conditional_forecast must be a matrix with numeric values."
              = is.matrix(conditional_forecast) & is.numeric(conditional_forecast)
    )
    stopifnot("Argument conditional_forecast must have the number of rows equal to 
              the value of argument horizon."
              = nrow(conditional_forecast) == horizon
    )
    stopifnot("Argument conditional_forecast must have the number of columns 
              equal to the number of columns in the used data."
              = ncol(conditional_forecast) == N
    )
  }
  
  # forecast volatility
  forecast_sigma2   = .Call(`_bsvars_forecast_sigma2_msh`, 
                            posterior_sigma2,
                            posterior_PR_TR,
                            S_T,
                            horizon
  ) # END .Call
  
  # perform forecasting
  for_y       = .Call(`_bsvars_forecast_bsvars`, 
                      posterior_B,
                      posterior_A,
                      forecast_sigma2,    # (N, horizon, S)
                      X_T,
                      exogenous_forecast,
                      conditional_forecast,
                      horizon
  ) # END .Call
  
  SS                  = dim(for_y$forecasts)[3]
  forecast_covariance = array(NA, c(N, N, horizon, SS))
  for (s in 1:SS) forecast_covariance[,,,s] = for_y$forecast_cov[s,][[1]]
  
  fore                = for_y
  fore$forecast_covariance = forecast_covariance
  fore$forecasts_sigma  = forecast_sigma2
  fore$Y                = Y
  class(fore)           = "Forecasts"
  
  return(fore)
} # END forecast.PosteriorBSVARMIX



#' @inherit forecast
#' @method forecast PosteriorBSVARSV
#' @param posterior posterior estimation outcome - an object of class 
#' \code{PosteriorBSVARSV} obtained by running the \code{estimate} function.
#' @param exogenous_forecast a matrix of dimension \code{horizon x d} containing 
#' forecasted values of the exogenous variables.
#' @param conditional_forecast a \code{horizon x N} matrix with forecasted values 
#' for selected variables. It should only contain \code{numeric} or \code{NA} 
#' values. The entries with \code{NA} values correspond to the values that are 
#' forecasted conditionally on the realisations provided as \code{numeric} values.
#' 
#' @examples
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' set.seed(123)
#' specification  = specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 5)
#' 
#' # sample from predictive density 1 year ahead
#' predictive     = forecast(posterior, 2)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_sv$new(p = 1) |>
#'   estimate(S = 5) |>
#'   estimate(S = 5) |>  
#'   forecast(horizon = 2) -> predictive
#'   
#' # conditional forecasting using a model with exogenous variables
#' ############################################################
#' data(us_fiscal_ex_forecasts)      # upload exogenous variables future values
#' data(us_fiscal_cond_forecasts)    # upload a matrix with projected ttr
#' 
#' #' set.seed(123)
#' specification  = specify_bsvar_sv$new(us_fiscal_lsuw, exogenous = us_fiscal_ex)
#' burn_in        = estimate(specification, 5)
#' posterior      = estimate(burn_in, 10)
#' 
#' # forecast 2 years ahead
#' predictive     = forecast(
#'                     posterior, 
#'                     horizon = 8,
#'                     exogenous_forecast = us_fiscal_ex_forecasts,
#'                     conditional_forecast = us_fiscal_cond_forecasts
#'                   )
#' summary(predictive)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_sv$new(exogenous = us_fiscal_ex) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(
#'     horizon = 8,
#'     exogenous_forecast = us_fiscal_ex_forecasts,
#'     conditional_forecast = us_fiscal_cond_forecasts
#'   ) |> plot()
#'
#' @export
forecast.PosteriorBSVARSV = function(
    posterior, 
    horizon = 1, 
    exogenous_forecast = NULL,
    conditional_forecast = NULL
) {
  
  posterior_B       = posterior$posterior$B
  posterior_A       = posterior$posterior$A
  posterior_rho     = posterior$posterior$rho
  posterior_omega   = posterior$posterior$omega
  
  T                 = ncol(posterior$last_draw$data_matrices$X)
  X_T               = posterior$last_draw$data_matrices$X[,T]
  Y                 = posterior$last_draw$data_matrices$Y
  posterior_h_T     = posterior$posterior$h[,T,]
  centred_sv        = posterior$last_draw$centred_sv
  
  N               = nrow(posterior_B)
  K               = length(X_T)
  d               = K - N * posterior$last_draw$p - 1
  S               = dim(posterior_B)[3]
  
  # prepare forecasting with exogenous variables
  if (d == 0 ) {
    exogenous_forecast = matrix(NA, horizon, 1)
  } else {
    stopifnot("Forecasted values of exogenous variables are missing." = (d > 0) & !is.null(exogenous_forecast))
    stopifnot("The matrix of exogenous_forecast does not have a correct number of columns." = ncol(exogenous_forecast) == d)
    stopifnot("Provide exogenous_forecast for all forecast periods specified by argument horizon." = nrow(exogenous_forecast) == horizon)
    stopifnot("Argument exogenous has to be a matrix." = is.matrix(exogenous_forecast) & is.numeric(exogenous_forecast))
    stopifnot("Argument exogenous cannot include missing values." = sum(is.na(exogenous_forecast)) == 0 )
  }
  
  # prepare forecasting with conditional forecasts
  if ( is.null(conditional_forecast) ) {
    # this will not be used for forecasting, but needs to be provided
    conditional_forecast = matrix(NA, horizon, N)
  } else {
    stopifnot("Argument conditional_forecast must be a matrix with numeric values."
              = is.matrix(conditional_forecast) & is.numeric(conditional_forecast)
    )
    stopifnot("Argument conditional_forecast must have the number of rows equal to 
              the value of argument horizon."
              = nrow(conditional_forecast) == horizon
    )
    stopifnot("Argument conditional_forecast must have the number of columns 
              equal to the number of columns in the used data."
              = ncol(conditional_forecast) == N
    )
  }
  
  # forecast volatility
  forecast_sigma2   = .Call(`_bsvars_forecast_sigma2_sv`, 
                            posterior_h_T,
                            posterior_rho,
                            posterior_omega,
                            horizon,
                            centred_sv
                      ) # END .Call
                            
  # perform forecasting
  for_y       = .Call(`_bsvars_forecast_bsvars`, 
                      posterior_B,
                      posterior_A,
                      forecast_sigma2,    # (N, horizon, S)
                      X_T,
                      exogenous_forecast,
                      conditional_forecast,
                      horizon
                ) # END .Call
  
  SS                  = dim(for_y$forecasts)[3]
  forecast_covariance = array(NA, c(N, N, horizon, SS))
  for (s in 1:SS) forecast_covariance[,,,s] = for_y$forecast_cov[s,][[1]]
  
  fore                = for_y
  fore$forecast_covariance = forecast_covariance
  fore$forecasts_sigma  = forecast_sigma2
  fore$Y                = Y
  class(fore)           = "Forecasts"
  
  return(fore)
} # END forecast.PosteriorBSVARSV





#' @inherit forecast
#' @method forecast PosteriorBSVART
#' @param posterior posterior estimation outcome - an object of class 
#' \code{PosteriorBSVART} obtained by running the \code{estimate} function.
#' @param exogenous_forecast a matrix of dimension \code{horizon x d} containing 
#' forecasted values of the exogenous variables. 
#' @param conditional_forecast a \code{horizon x N} matrix with forecasted values 
#' for selected variables. It should only contain \code{numeric} or \code{NA} 
#' values. The entries with \code{NA} values correspond to the values that are 
#' forecasted conditionally on the realisations provided as \code{numeric} values.
#' 
#' @return A list of class \code{Forecasts} containing the
#' draws from the predictive density and data. The output list includes element:
#' 
#' \describe{
#'  \item{forecasts}{an \code{NxTxS} array with the draws from predictive density}
#'  \item{Y}{an \eqn{NxT} matrix with the data on dependent variables}
#' }
#' 
#' @examples
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' set.seed(123)
#' specification  = specify_bsvar_t$new(us_fiscal_lsuw, p = 1)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 10)
#' 
#' # sample from predictive density 1 year ahead
#' predictive     = forecast(posterior, 4)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_t$new(p = 1) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(horizon = 4) -> predictive
#' 
#' # conditional forecasting using a model with exogenous variables
#' ############################################################
#' data(us_fiscal_ex_forecasts)      # upload exogenous variables future values
#' data(us_fiscal_cond_forecasts)    # upload a matrix with projected ttr
#' 
#' #' set.seed(123)
#' specification  = specify_bsvar_t$new(us_fiscal_lsuw, exogenous = us_fiscal_ex)
#' burn_in        = estimate(specification, 5)
#' posterior      = estimate(burn_in, 10)
#' 
#' # forecast 2 years ahead
#' predictive     = forecast(
#'                     posterior, 
#'                     horizon = 8,
#'                     exogenous_forecast = us_fiscal_ex_forecasts,
#'                     conditional_forecast = us_fiscal_cond_forecasts
#'                   )
#' summary(predictive)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_t$new(exogenous = us_fiscal_ex) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10) |> 
#'   forecast(
#'     horizon = 8,
#'     exogenous_forecast = us_fiscal_ex_forecasts,
#'     conditional_forecast = us_fiscal_cond_forecasts
#'   ) |> plot()
#'   
#' @export
forecast.PosteriorBSVART = function(
    posterior, 
    horizon = 1, 
    exogenous_forecast = NULL,
    conditional_forecast = NULL
) {
  
  posterior_B     = posterior$posterior$B
  posterior_A     = posterior$posterior$A
  posterior_df    = posterior$posterior$df
  T               = ncol(posterior$last_draw$data_matrices$X)
  X_T             = posterior$last_draw$data_matrices$X[,T]
  Y               = posterior$last_draw$data_matrices$Y
  
  N               = nrow(posterior_B)
  K               = length(X_T)
  d               = K - N * posterior$last_draw$p - 1
  S               = dim(posterior_B)[3]
  
  # prepare forecasting with exogenous variables
  if (d == 0 ) {
    exogenous_forecast = matrix(NA, horizon, 1)
  } else {
    stopifnot("Forecasted values of exogenous variables are missing." = (d > 0) & !is.null(exogenous_forecast))
    stopifnot("The matrix of exogenous_forecast does not have a correct number of columns." = ncol(exogenous_forecast) == d)
    stopifnot("Provide exogenous_forecast for all forecast periods specified by argument horizon." = nrow(exogenous_forecast) == horizon)
    stopifnot("Argument exogenous has to be a matrix." = is.matrix(exogenous_forecast) & is.numeric(exogenous_forecast))
    stopifnot("Argument exogenous cannot include missing values." = sum(is.na(exogenous_forecast)) == 0 )
  }
  
  # prepare forecasting with conditional forecasts
  if ( is.null(conditional_forecast) ) {
    # this will not be used for forecasting, but needs to be provided
    conditional_forecast = matrix(NA, horizon, N)
  } else {
    stopifnot("Argument conditional_forecast must be a matrix with numeric values."
              = is.matrix(conditional_forecast) & is.numeric(conditional_forecast)
    )
    stopifnot("Argument conditional_forecast must have the number of rows equal to 
              the value of argument horizon."
              = nrow(conditional_forecast) == horizon
    )
    stopifnot("Argument conditional_forecast must have the number of columns 
              equal to the number of columns in the used data."
              = ncol(conditional_forecast) == N
    )
  }
  
  # forecast volatility
  forecast_sigma2 = .Call(`_bsvars_forecast_lambda_t`, 
                              posterior_df,
                              horizon
                        ) # END .Call
  
  # perform forecasting
  for_y       = .Call(`_bsvars_forecast_bsvars`, 
                      posterior_B,
                      posterior_A,
                      forecast_sigma2,    # (N, horizon, S)
                      X_T,
                      exogenous_forecast,
                      conditional_forecast,
                      horizon
                ) # END .Call
  
  SS                  = dim(for_y$forecasts)[3]
  forecast_covariance = array(NA, c(N, N, horizon, SS))
  for (s in 1:SS) forecast_covariance[,,,s] = for_y$forecast_cov[s,][[1]]
  
  fore                = for_y
  fore$forecast_covariance = forecast_covariance
  fore$forecasts_sigma  = forecast_sigma2
  fore$Y                = Y
  class(fore)           = "Forecasts"
  
  return(fore)
} # END forecast.PosteriorBSVART