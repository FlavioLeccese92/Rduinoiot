#' Create Auth Token for Arduino IoT Cloud API
#'
#' @description
#'
#' Obtain an authorization token using your personal client_id and client_secret.
#'
#' Official documentation: [API Summary](<https://www.arduino.cc/reference/en/iot/api/#api/>)
#'
#' @param client_id Your client id (default is the environmental variable `ARDUINO_API_CLIENT_ID`)
#' @param client_secret Your client secret (default is the environmental variable `ARDUINO_API_CLIENT_SECRET`)
#' @param ... Additional parameters needed for the body of the `POST` request:
#'  * `token_url` (default: `https://api2.arduino.cc/iot/v1/clients/token/`)
#'  * `grant_type` (default: `client_credentials`)
#'  * `audience` (default: `https://api2.arduino.cc/iot/`)
#'  * `content_type` (default: `application/x-www-form-urlencoded`)
#' @param store_token Where your token is stored. If `option` it will be saved into the .Rprofile (not cross-session),
#' if `envir` it will be saved as an environmental variable.
#' @param return_token If `TRUE` returns the token value as output of the function.
#' @param silent Whether to hide or show API method success messages (default `FALSE`)
#' @md
#' @return A token valid for Arduino IoT Cloud API. It can  retrievable by `getOption('ARDUINO_API_TOKEN')` (if `store_content` = "option")
#' or by `Sys.getenv("ARDUINO_API_TOKEN")` (if `store_token` = "envir")
#'
#' @examples
#' \dontrun{
#' # Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' # Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#'
#' create_auth_token()
#' }
#' @export
create_auth_token <- function(client_id = Sys.getenv("ARDUINO_API_CLIENT_ID"),
                              client_secret = Sys.getenv("ARDUINO_API_CLIENT_SECRET"),
                              store_token = "option",
                              return_token = FALSE,
                              silent = FALSE,
                               ...){
  if(client_id == ""){cli::cli_alert_danger("client_id not defined as system variable"); stop()}
  if(client_secret == ""){cli::cli_alert_danger("client_secret not defined as system variable"); stop()}
  if(!is.logical(return_token)){cli::cli_alert_danger("return_token must be TRUE or FALSE"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

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
    if(!silent){cli::cli_alert_success("Method succeeded")}
  }else{
    cli::cli_alert_danger(paste0("API error: ", res$status_code)); stop()
  }
  if(store_token == "option"){
    options(ARDUINO_API_TOKEN = token)}else{
      Sys.setenv(ARDUINO_API_TOKEN = token)
    }
  if(return_token){return(invisible(token))}
}
