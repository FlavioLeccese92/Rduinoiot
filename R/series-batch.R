#' Batch queries API methods
#'
#' @description
#'
#' `r lifecycle::badge('experimental')`
#'
#' Returns the batch of time-series data or last data point for a property of given thing
#' (note: this API method is bugged and waiting to be fixed by Arduino team.
#' Here for completeness and future developements but would not suggest using it)
#'
#' Official documentation:
#'  * [seriesV2BatchQuery](https://www.arduino.cc/reference/en/iot/api/#api-SeriesV2-seriesV2BatchQuery)
#'  * [seriesV2BatchQueryRaw](https://www.arduino.cc/reference/en/iot/api/#api-SeriesV2-seriesV2BatchQueryRaw)
#'  * [seriesV2BatchQueryRawLastValue](https://www.arduino.cc/reference/en/iot/api/#api-SeriesV2-seriesV2BatchQueryRawLastValue)
#' @md
#'
#' @param from A `Posixct` or `Date` object.
#' Get data with a timestamp >= to this value
#' @param to A `Posixct` or `Date` object.
#' Get data with a timestamp < to this value
#' @param interval (numeric) Resolutions in seconds (seems not to affect results)
#' @param Q The query. (Not clear what this means but allows to chose amongs properties by filling in,
#' for instance, `property.fbf34284-91f0-42be-bbf6-dd46cfb3f1e0`)
#' @param SeriesLimit Maximum number of values (seems not to affect results)
#' @param thing_id The id of the thing
#' @param property_id The id of the property
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default getOption('ARDUINO_API_TOKEN'))
#' @return A tibble showing of time and value for properties
#' @examples
#' \dontrun{
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#'
#' create_auth_token()
#'
#' ### series_batch_query ###
#' series_batch_query(from = "2022-08-15", to = "2022-08-22",
#' Q = "property.fbf34284-91f0-42be-bbf6-dd46cfb3f1e0")
#'
#' ### series_batch_query_raw ###
#' series_batch_query_raw(from = "2022-08-15", to = "2022-08-22",
#' Q = "property.fbf34284-91f0-42be-bbf6-dd46cfb3f1e0")
#'
#' ### series_batch_last_value ###
#' thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
#' property_id = "fbf34284-91f0-42be-bbf6-dd46cfb3f1e0"
#'
#' series_batch_last_value(thing_id = thing_id, property_id = property_id)
#' }
#' @name series_batch
#' @rdname series_batch
#' @export
series_batch_query <- function(from, to, interval = NULL, Q, SeriesLimit = NULL,
                               token = getOption('ARDUINO_API_TOKEN')){

  if(missing(from)){cli::cli_alert_danger("missing from"); stop()}
  if(missing(to)){cli::cli_alert_danger("missing to"); stop()}
  if(missing(Q)){cli::cli_alert_danger("missing Q"); stop()}

  if(!missing(from)){
    if(!methods::is(from, "POSIXct") && !methods::is(from, "Date")){
      from = tryCatch({as.Date(from)}, error = function(e){
        cli::cli_alert_danger("{.field to} not in a valid POSIXct or Date format")})
      from = strftime(format(from, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
    }else{from = strftime(format(from, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(!missing(to)){
    if(!methods::is(to, "POSIXct") && !methods::is(to, "Date")){
      to = tryCatch({as.Date(to)}, error = function(e){
        cli::cli_alert_danger("{.field from} not in a valid POSIXct or Date format")})
      to = strftime(format(to, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
    }else{to = strftime(format(to, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  url = "https://api2.arduino.cc/iot/v2/series/batch_query"
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list("requests" = data.frame('from' = from, 'to' = to, 'Q' = Q),
                "resp_version" = 1)
    body$requests$interval = interval
    body$requests$SeriesLimit = SeriesLimit
    res = httr::POST(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res_raw = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      res = tibble::tibble(time = unlist(res_raw$responses$times),
                           values = unlist(res_raw$responses$values))
      if(nrow(res)>0){
        res$time = as.POSIXct(res$time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else if(res$status_code == 404){
      still_valid_token = TRUE; cli::cli_alert_danger("API error: Not found");}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
#' @name series_batch
#' @export
series_batch_query_raw <- function(from, to, interval = NULL, Q, SeriesLimit = NULL,
                                   token = getOption('ARDUINO_API_TOKEN')){

  if(missing(from)){cli::cli_alert_danger("missing from"); stop()}
  if(missing(to)){cli::cli_alert_danger("missing to"); stop()}
  if(missing(Q)){cli::cli_alert_danger("missing Q"); stop()}

  if(!missing(from)){
    if(!methods::is(from, "POSIXct") && !methods::is(from, "Date")){
      from = tryCatch({as.Date(from)}, error = function(e){
        cli::cli_alert_danger("{.field to} not in a valid POSIXct or Date format")})
      from = strftime(format(from, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
    }else{from = strftime(format(from, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(!missing(to)){
    if(!methods::is(to, "POSIXct") && !methods::is(to, "Date")){
      to = tryCatch({as.Date(to)}, error = function(e){
        cli::cli_alert_danger("{.field from} not in a valid POSIXct or Date format")})
      to = strftime(format(to, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
    }else{to = strftime(format(to, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  url = "https://api2.arduino.cc/iot/v2/series/batch_query_raw"
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list("requests" = data.frame('from' = from, 'to' = to, 'Q' = Q),
                "resp_version" = 1)
    body$requests$interval = interval
    body$requests$SeriesLimit = SeriesLimit
    res = httr::POST(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res_raw = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      res = tibble::tibble(time = unlist(res_raw$responses$times),
                           values = unlist(res_raw$responses$values))
      if(nrow(res)>0){
        res$time = as.POSIXct(res$time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else if(res$status_code == 404){
      still_valid_token = TRUE; cli::cli_alert_danger("API error: Not found");}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
#' @name series_batch
#' @export
series_batch_last_value <- function(thing_id, property_id,
                                    token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(missing(property_id)){cli::cli_alert_danger("missing property_id"); stop()}


  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  url = "https://api2.arduino.cc/iot/v2/series/batch_query_raw/lastvalue"
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list("requests" = data.frame('thing_id' = thing_id, 'property_id' = property_id))
    res = httr::POST(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res_raw = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      res = tibble::tibble(time = unlist(res_raw$responses$times),
                           values = unlist(res_raw$responses$values))
      if(nrow(res)>0){
        res$time = as.POSIXct(res$time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else if(res$status_code == 404){
      still_valid_token = TRUE; cli::cli_alert_danger("API error: Not found");}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
