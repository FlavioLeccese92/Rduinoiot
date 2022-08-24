#' Data from Properties (of things) API methods
#'
#' Get numerical property's historic data binned on a specified time interval
#' (note: the total number of data points should NOT be greater than 1000 otherwise the result will be truncated)
#'
#' Official documentation:
#'  \href{https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Timeseries}{propertiesV2Timeseries}
#'
#' @param thing_id The id of the thing
#' @param property_id The id of the property
#' @param from A `Posixct` or `Date` object.
#' Get data with a timestamp >= to this value (default: 2 weeks ago, min: 1842-01-01, max: 2242-01-01)
#' @param to A `Posixct` or `Date` object.
#' Get data with a timestamp < to this value (default: now, min: 1842-01-01, max: 2242-01-01)
#' @param interval (numeric) Binning interval in seconds
#' (defaut: the smallest possible value compatibly with the limit of 1000 data points in the response)
#' @param desc (logic) Whether data's ordering (by time) should be descending. Default TO `FALSE`
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default getOption('ARDUINO_API_TOKEN'))
#' @return A tibble showing of time and value for property of given device
#' @examples
#' \dontrun{
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#' create_auth_token()
#'
#' thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
#' property_id = "d1134fe1-6519-49f1-afd8-7fe9e891e778"
#'
#' things_properties_timeseries(thing_id = thing_id, property_id = property_id,
#' desc = FALSE, interval = 60, from = "2022-08-20")
#' }
#' @name things_properties_timeseries
#' @rdname things_properties_timeseries
#' @export
things_properties_timeseries <- function(thing_id, property_id,
                                         from = NULL, to = NULL, interval = NULL, desc = NULL,
                                         token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(missing(property_id)){cli::cli_alert_danger("missing property_id"); stop()}

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s/timeseries", thing_id, property_id)
  still_valid_token = FALSE

  if(!missing(from)){
    if(!is(from, "POSIXct") && !is(from, "Date")){
      from = tryCatch({as.Date(from)}, error = function(e){
        cli::cli_alert_danger("{.field to} not in a valid POSIXct or Date format")})
      from = strftime(format(from, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
    }else{from = strftime(format(from, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  if(!missing(to)){
    if(!is(to, "POSIXct") && !is(to, "Date")){
      to = tryCatch({as.Date(to)}, error = function(e){
        cli::cli_alert_danger("{.field from} not in a valid POSIXct or Date format")})
      to = strftime(format(to, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
    }else{to = strftime(format(to, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('desc' = desc,
                'from' = from,
                'interval' = interval,
                'to' = to)
    res = httr::GET(url = url, query = query, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$data)
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
