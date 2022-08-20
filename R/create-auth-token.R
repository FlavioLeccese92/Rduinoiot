#' Create Auth Token for Arduino IoT Cloud API
#'
#' Obtain an authorization token using your personal client_id and client_secret
#' from Arduino site page https://cloud.arduino.cc/home/api-keys
#'
#' Official documentation: \href{https://www.arduino.cc/reference/en/iot/api/#api-_}{API Summary}
#'
#' @param client_id Your client id (default is the environmental variable ARDUINO_API_CLIENT_ID)
#' @param client_secret Your client secret (default is the environmental variable ARDUINO_API_CLIENT_SECRET)
#' @param ... Additional parameters needed for the body of the POST request:
#'  * `token_url` (default: 'https://api2.arduino.cc/iot/v1/clients/token')
#'  * `grant_type` (default: 'client_credentials')
#'  * `audience` (default: 'https://api2.arduino.cc/iot')
#'  * `content_type` (default: 'application/x-www-form-urlencoded')
#' @md
#' @return A token valid for Arduino IoT Cloud API (stored on .Rprofile)
#'
#' @examples
#'
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'V8CpJ82mOtpsBgnGqeVGvRpSw9SOXcNo')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'OSo32AvUyJCe15UO90kXxrDQtsf1DpsFJ5CYI3xT9TaHe1SvIu8BwBteGl0pAdL5')
#'
#' create_auth_token()
#'
#' @export
create_auth_token <- function(client_id = Sys.getenv("ARDUINO_API_CLIENT_ID"),
                              client_secret = Sys.getenv("ARDUINO_API_CLIENT_SECRET"),
                               ...){
  if(client_id == ""){stop("client_id not defined as system variable")}
  if(client_secret == ""){stop("client_secret not defined as system variable")}

  add_args = list(...)
  if('token_url' %in% names(add_args)){
    token_url <- add_args$token_url
  }else{token_url <- 'https://api2.arduino.cc/iot/v1/clients/token'}

  if('grant_type' %in% names(add_args)){
    grant_type <- add_args$grant_type
  }else{grant_type <- 'client_credentials'}

  if('audience' %in% names(add_args)){
    audience <- add_args$audience
  }else{audience <- 'https://api2.arduino.cc/iot'}

  if('content_type' %in% names(add_args)){
    content_type <- add_args$content_type
  }else{content_type <- 'application/x-www-form-urlencoded'}

  res <- httr::POST(url = token_url,
              body = list('grant_type' = grant_type,
                          'client_id' = client_id,
                          'client_secret' = client_secret,
                          'audience' = audience),
              httr::add_headers('content-type' = content_type),
              encode = 'form')

  if(res$status_code == 200){
    token <- as.character(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))["access_token"])
    message("Authorization succeeded")
  }else{
    stop(paste0("API error: ", res$status_code))
  }
  options(ARDUINO_API_TOKEN = token)
  invisible(token)
}

