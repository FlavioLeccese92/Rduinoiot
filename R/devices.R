#' Devices API methods
#'
#' List and show devices, events, properties associated to the user
#'
#' Official documentation:
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2List}{devicesV2List}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2Show}{thingsV2Show}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2GetEvents}{devicesV2GetEvents}
#' @md
#' @param serial serial number of the device you  may want to filter from the list (not device_id)
#' @param tags tags you  may want to filter from the list
#' @param device_id The id of the device (The arn of the associated device)
#' @param limit The number of events to select
#' @param start A `Posixct` or `Date` object. Time at which to start selecting events
#' @param show_deleted If `TRUE`, shows the soft deleted properties. Default to `FALSE`
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default \code{getOption('ARDUINO_API_TOKEN')})
#' @return A tibble showing extensive information about devices (and related things) associated to the user
#' @examples
#' \dontrun{
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#'
#' create_auth_token()
#'
#' d_list = devices_list()
#' }
#' @name devices
#' @rdname devices
#' @export
devices_list <- function(serial = NULL, tags = NULL,
                         token = getOption('ARDUINO_API_TOKEN')
                         ){

  ### attention: if TRUE returns 401 -> meaning of the parameter not clear ###
  across_user_ids = FALSE

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

  url = "https://api2.arduino.cc/iot/v2/devices/"
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
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
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
                         token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

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
      if(nrow(res)>0){
        res$device$created_at = as.POSIXct(res$device$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$device$last_activity_at = as.POSIXct(res$device$last_activity_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
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
                               token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(!is.null(start)){
    if(!is(start, "POSIXct") && !is(start, "Date")){
      start = tryCatch({as.Date(start)}, error = function(e){
        cli::cli_alert_danger("{.field to} not in a valid POSIXct or Date format")})
      start = strftime(format(start, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
    else{start = strftime(format(start, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

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
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
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
                                   token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

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
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
