#' Devices API methods
#'
#' @description
#'
#' List and show devices, events, properties associated to the user
#'
#' Official documentation:
#'  * [devicesV2List](<https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2List>)
#'  * [thingsV2Show](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2Show>)
#'  * [devicesV2GetEvents](<https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2GetEvents>)
#' @md
#' @param serial serial number of the device you  may want to filter from the list (not device_id)
#' @param tags tags you  may want to filter from the list
#' @param device_id The id of the device (The arn of the associated device)
#' @param limit The number of events to select
#' @param start A `Posixct` or `Date` object. Time at which to start selecting events
#' @param show_deleted If `TRUE`, shows the soft deleted properties. Default to `FALSE`
#' @param store_token Where your token is stored. If `option` it will be retrieved from the .Rprofile (not cross-session and default),
#' if `envir` it will be retrieved from environmental variables list (cross-session)
#' @param token A valid token created with `create_auth_token` or manually.
#' It not `NULL` it has higher priority then `store_token`
#' @param silent Whether to hide or show API method success messages (default `FALSE`)
#' @return A tibble showing extensive information about devices (and related things) associated to the user
#' @examples
#' \dontrun{
#' library(dplyr)
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#'
#' create_auth_token()
#'
#' ### check properties list ###
#' d_list = devices_list()
#' device_id = d_list %>% slice(1) %>% pull(id)
#'
#' devices_show(device_id = device_id)
#'
#' ### get device events ###
#' devices_get_events(device_id = device_id)
#'
#' ### get device properties ###
#' devices_get_properties(device_id = device_id)
#'
#' }
#' @name devices
#' @rdname devices
#' @export
devices_list <- function(serial = NULL, tags = NULL,
                         store_token = "option",
                         token = NULL,
                         silent = FALSE
                         ){

  ### attention: if TRUE returns 401 -> meaning of the parameter not clear ###
  across_user_ids = FALSE

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = "https://api2.arduino.cc/iot/v2/devices"
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('across_user_ids' = across_user_ids,
                 'serial' = serial,
                 'tags' = tags)
    res = httr::GET(url = url, query = query, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$last_activity_at = as.POSIXct(res$last_activity_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
      }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
#' @name devices
#' @export
#'
devices_show <- function(device_id,
                         store_token = "option",
                         token = NULL,
                         silent = FALSE){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      res_raw = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      res = tibble::as_tibble(res_raw[setdiff(names(res_raw), c("events", "thing"))])
      res$events = list(tibble::as_tibble(res_raw["events"]))
      res$thing = list(tibble::as_tibble(t(unlist(res_raw["thing"]))))
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
#' @name devices
#' @export
#'
devices_get_events <- function(device_id,
                               limit = NULL, start = NULL,
                               store_token = "option",
                               token = NULL,
                               silent = FALSE){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(!is.null(start)){
    if(!methods::is(start, "POSIXct") && !methods::is(start, "Date")){
      start = tryCatch({as.Date(start)}, error = function(e){
        cli::cli_alert_danger("{.field to} not in a valid POSIXct or Date format")})
      start = strftime(format(start, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
    else{start = strftime(format(start, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/events", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('limit' = limit, 'start' = start)
    res = httr::GET(url = url, query = query, httr::add_headers(header))
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$events$updated_at = as.POSIXct(res$events$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
#' @name devices
#' @export
#'
devices_get_properties <- function(device_id,
                                   show_deleted = FALSE,
                                   store_token = "option",
                                   token = NULL,
                                   silent = FALSE){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/properties", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('show_deleted' = show_deleted)
    res = httr::GET(url = url, query = query, httr::add_headers(header))
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$properties$created_at = as.POSIXct(res$properties$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$properties$updated_at = as.POSIXct(res$properties$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
