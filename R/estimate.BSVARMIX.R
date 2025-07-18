
#' @title Bayesian estimation of a Structural Vector Autoregression with shocks following 
#' a finite mixture of normal components via Gibbs sampler
#'
#' @description Estimates the SVAR with non-normal residuals following a finite \code{M} mixture of normal distributions proposed by Woźniak & Droumaguet (2022).
#' Implements the Gibbs sampler proposed by Waggoner & Zha (2003)
#' for the structural matrix \eqn{B} and the equation-by-equation sampler by Chan, Koop, & Yu (2024)
#' for the autoregressive slope parameters \eqn{A}. Additionally, the parameter matrices \eqn{A} and \eqn{B}
#' follow a Minnesota prior and generalised-normal prior distributions respectively with the matrix-specific
#' overall shrinkage parameters estimated thanks to a hierarchical prior distribution. The finite mixture of normals
#' model is estimated using the prior distributions and algorithms proposed by Woźniak & Droumaguet (2024),
#' Lütkepohl & Woźniak (2020), and Song & Woźniak (2021). See section \bold{Details} for the model equations.
#' 
#' @details 
#' The heteroskedastic SVAR model is given by the reduced form equation:
#' \deqn{Y = AX + E}
#' where \eqn{Y} is an \code{NxT} matrix of dependent variables, \eqn{X} is a \code{KxT} matrix of explanatory variables, 
#' \eqn{E} is an \code{NxT} matrix of reduced form error terms, and \eqn{A} is an \code{NxK} matrix of autoregressive slope coefficients and parameters on deterministic terms in \eqn{X}.
#' 
#' The structural equation is given by
#' \deqn{BE = U}
#' where \eqn{U} is an \code{NxT} matrix of structural form error terms, and
#' \eqn{B} is an \code{NxN} matrix of contemporaneous relationships.
#' 
#' Finally, the structural shocks, \eqn{U}, are temporally and contemporaneously independent and finite-mixture of normals distributed with zero mean.
#' The conditional variance of the \code{n}th shock at time \code{t} is given by:
#' \deqn{Var_{t-1}[u_{n.t}] = s^2_{n.s_t}}
#' where \eqn{s_t} is a the regime indicator of 
#' the regime-specific conditional variances of structural shocks \eqn{s^2_{n.s_t}}. 
#' In this model, the variances of each of the structural shocks sum to \code{M}.
#' 
#' The regime indicator \eqn{s_t} is either such that:
#' \itemize{
#'   \item the regime probabilities are non-zero which requires all regimes to have 
#'   a positive number occurrences over the sample period, or
#'   \item sparse with potentially many regimes with zero occurrences over the sample period
#'   and in which the number of regimes is estimated.
#' }
#' These model selection also with this respect is made using function \code{\link{specify_bsvar_mix}}.
#' 
#' @param specification an object of class BSVARMIX generated using the \code{specify_bsvar_mix$new()} function.
#' @param S a positive integer, the number of posterior draws to be generated
#' @param thin a positive integer, specifying the frequency of MCMC output thinning
#' @param show_progress a logical value, if \code{TRUE} the estimation progress bar is visible
#' 
#' @return An object of class PosteriorBSVARMIX containing the Bayesian estimation output and containing two elements:
#' 
#'  \code{posterior} a list with a collection of \code{S} draws from the posterior distribution generated via Gibbs sampler containing:
#'  \describe{
#'  \item{A}{an \code{NxKxS} array with the posterior draws for matrix \eqn{A}}
#'  \item{B}{an \code{NxNxS} array with the posterior draws for matrix \eqn{B}}
#'  \item{hyper}{a \code{5xS} matrix with the posterior draws for the hyper-parameters of the hierarchical prior distribution}
#'  \item{sigma2}{an \code{NxMxS} array with the posterior draws for the structural shocks conditional variances}
#'  \item{PR_TR}{an \code{MxMxS} array with the posterior draws for the transition matrix.}
#'  \item{xi}{an \code{MxTxS} array with the posterior draws for the regime allocation matrix.}
#'  \item{pi_0}{an \code{MxS} matrix with the posterior draws for the ergodic probabilities}
#'  \item{sigma}{an \code{NxTxS} array with the posterior draws for the structural shocks conditional standard deviations' series over the sample period}
#' }
#' 
#' \code{last_draw} an object of class BSVARMIX with the last draw of the current MCMC run as the starting value to be passed to the continuation of the MCMC estimation using \code{estimate()}.
#'
#' @seealso \code{\link{specify_bsvar_mix}}, \code{\link{specify_posterior_bsvar_mix}}, \code{\link{normalise_posterior}}
#'
#' @author Tomasz Woźniak \email{wozniak.tom@pm.me}
#' 
#' @references 
#' 
#' Chan, J.C.C., Koop, G, and Yu, X. (2024) Large Order-Invariant Bayesian VARs with Stochastic Volatility. \emph{Journal of Business & Economic Statistics}, \bold{42}, \doi{10.1080/07350015.2023.2252039}.
#' 
#' Lütkepohl, H., and Woźniak, T., (2020) Bayesian Inference for Structural Vector Autoregressions Identified by Markov-Switching Heteroskedasticity. \emph{Journal of Economic Dynamics and Control} \bold{113}, 103862, \doi{10.1016/j.jedc.2020.103862}.
#' 
#' Song, Y., and Woźniak, T., (2021) Markov Switching. \emph{Oxford Research Encyclopedia of Economics and Finance}, Oxford University Press, \doi{10.1093/acrefore/9780190625979.013.174}.
#' 
#' Waggoner, D.F., and Zha, T., (2003) A Gibbs sampler for structural vector autoregressions. \emph{Journal of Economic Dynamics and Control}, \bold{28}, 349--366, \doi{10.1016/S0165-1889(02)00168-9}.
#' 
#' Woźniak, T., and Droumaguet, M., (2024) Bayesian Assessment of Identifying Restrictions for Heteroskedastic Structural VARs
#' 
#' @method estimate BSVARMIX
#' 
#' @examples
#' # simple workflow
#' ############################################################
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' specification  = specify_bsvar_mix$new(us_fiscal_lsuw, p = 1, M = 2)
#' set.seed(123)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 5)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 10, thin = 2)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_mix$new(p = 1, M = 2) |>
#'   estimate(S = 5) |> 
#'   estimate(S = 10, thin = 2) |> 
#'   compute_impulse_responses(horizon = 4) -> irf
#'   
#' @export
estimate.BSVARMIX <- function(specification, S, thin = 1, show_progress = TRUE) {
  
  # get the inputs to estimation
  prior               = specification$prior$get_prior()
  starting_values     = specification$starting_values$get_starting_values()
  VB                  = specification$identification$VB
  VA                  = specification$identification$VA
  data_matrices       = specification$data_matrices$get_data_matrices()
  finiteM             = specification$finiteM
  if (finiteM) {
    model             = "finiteMIX"
  } else {
    model             = "sparseMIX"
  }
  
  # estimation
  qqq                 = .Call(`_bsvars_bsvar_msh_cpp`, S, data_matrices$Y, data_matrices$X, prior, VB, VA, starting_values, thin, finiteM, FALSE, model, show_progress, FALSE)
  
  specification$starting_values$set_starting_values(qqq$last_draw)
  output              = specify_posterior_bsvar_mix$new(specification, qqq$posterior)
  
  # normalise output
  BB                  = qqq$last_draw$B
  BB                  = diag(sign(diag(BB))) %*% BB
  normalise_posterior(output, BB)
  
  return(output)
}





#' @inherit estimate.BSVARMIX
#' 
#' @method estimate PosteriorBSVARMIX
#' 
#' @param specification an object of class PosteriorBSVARMIX generated using the \code{estimate.BSVAR()} function.
#' This setup facilitates the continuation of the MCMC sampling starting from the last draw of the previous run.
#' 
#' @examples
#' # simple workflow
#' ############################################################
#' # upload data
#' data(us_fiscal_lsuw)
#' 
#' # specify the model and set seed
#' specification  = specify_bsvar_mix$new(us_fiscal_lsuw, p = 1, M = 2)
#' set.seed(123)
#' 
#' # run the burn-in
#' burn_in        = estimate(specification, 10)
#' 
#' # estimate the model
#' posterior      = estimate(burn_in, 20, thin = 2)
#' 
#' # workflow with the pipe |>
#' ############################################################
#' set.seed(123)
#' us_fiscal_lsuw |>
#'   specify_bsvar_mix$new(p = 1, M = 2) |>
#'   estimate(S = 10) |> 
#'   estimate(S = 20, thin = 2) |> 
#'   compute_impulse_responses(horizon = 4) -> irf
#'   
#' @export
estimate.PosteriorBSVARMIX <- function(specification, S, thin = 1, show_progress = TRUE) {
  
  # get the inputs to estimation
  prior               = specification$last_draw$prior$get_prior()
  starting_values     = specification$last_draw$starting_values$get_starting_values()
  VB                  = specification$last_draw$identification$VB
  VA                  = specification$last_draw$identification$VA
  data_matrices       = specification$last_draw$data_matrices$get_data_matrices()
  finiteM             = specification$last_draw$finiteM
  if (finiteM) {
    model             = "finiteMIX"
  } else {
    model             = "sparseMIX"
  }
  
  # estimation
  qqq                 = .Call(`_bsvars_bsvar_msh_cpp`, S, data_matrices$Y, data_matrices$X, prior, VB, VA, starting_values, thin, finiteM, FALSE, model, show_progress, FALSE)
  
  specification$last_draw$starting_values$set_starting_values(qqq$last_draw)
  output              = specify_posterior_bsvar_mix$new(specification$last_draw, qqq$posterior)
  
  # normalise output
  BB                  = qqq$last_draw$B
  BB                  = diag(sign(diag(BB))) %*% BB
  normalise_posterior(output, BB)
  
  return(output)
}
