#' Data start Properties (of devices) API methods
#'
#' @description
#'
#' `r lifecycle::badge('experimental')`
#'
#' Get device properties values in a range of time
#' (note: this API method is bugged and waiting to be fixed by Arduino team.
#' Here for completeness and future developments but would not suggest using it)
#'
#' Official documentation:
#'  [devicesV2Timeseries](<https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2Timeseries>)
#'
#' @param device_id The id of the device
#' @param property_id The id of the property
#' @param start A `Posixct` or `Date` object. The time at which to start selecting properties.
#' @param limit The number of properties to select
#' @param store_token Where your token is stored. If `option` it will be retrieved from the .Rprofile (not cross-session and default),
#' if `envir` it will be retrieved from environmental variables list (cross-session).
#' @param token A valid token created with `create_auth_token` or manually.
#' It not `NULL` it has higher priority then `store_token`
#' @param silent Whether to hide or show API method success messages (default `FALSE`)
#' @return A tibble showing of time and value for property of given device
#' @examples
#' \dontrun{
#' # Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' # Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#'
#' create_auth_token()
#'
#' device_id = "fa7ee291-8dc8-4713-92c7-9027969e4aa1"
#' property_id = "d1134fe1-6519-49f1-afd8-7fe9e891e778"
#'
#' devices_properties_timeseries(device_id = device_id, property_id = property_id,
#'  start = "2022-08-20", limit = 10)
#' }
#' @name devices_properties_timeseries
#' @rdname devices_properties_timeseries
#' @export
devices_properties_timeseries <- function(device_id, property_id,
                                          start = NULL, limit = NULL,
                                          store_token = "option",
                                          token = NULL,
                                          silent = FALSE){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(missing(property_id)){cli::cli_alert_danger("missing property_id"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/properties/%s", device_id, property_id)
  still_valid_token = FALSE

  if(!missing(start)){
    if(!methods::is(start, "POSIXct") && !methods::is(start, "Date")){
      start = tryCatch({as.Date(start)}, error = function(e){
        cli::cli_alert_danger("{.field to} not in a valid POSIXct or Date format")})
      start = strftime(format(start, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")
      }else{start = strftime(format(start, tz = "UTC", usetz = TRUE), "%Y-%m-%dT%H:%M:%OSZ")}
  }

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('start' = start, 'limit' = limit)
    res = httr::GET(url = url, query = query, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$values)
      if(nrow(res)>0){
        res$time = as.POSIXct(res$time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
      }
    else if(res$status_code == 404){
      still_valid_token = TRUE; cli::cli_alert_danger("API error: Not found");}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
  return(res)
}
