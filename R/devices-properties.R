#' Properties (of devices) API methods
#'
#' List properties associated to a given device
#'
#' Official documentation: [devicesV2GetProperties](<https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2GetProperties>)
#'
#' @param device_id The id of the device
#' @param show_deleted If `TRUE`, shows the soft deleted properties. Default to `FALSE`
#' @param store_token Where your token is stored. If `option` it will be retrieved from the .Rprofile (not cross-session and default),
#' if `envir` it will be retrieved from environmental variables list (cross-session)
#' @param token A valid token created with `create_auth_token` or manually.
#' It not `NULL` it has higher priority then `store_token`
#' @param silent Whether to hide or show API method success messages (default `FALSE`)
#' @return A tibble showing the information about properties for given device.
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#' create_auth_token()
#'
#' device_id = "fa7ee291-8dc8-4713-92c7-9027969e4aa1"
#'
#' ### check properties list ###
#' devices_properties_list(device_id = device_id)
#' }
#' @name devices_properties
#' @rdname devices_properties
#' @export
devices_properties_list <- function(device_id,
                                    show_deleted = FALSE,
                                    store_token = "option",
                                    token = NULL,
                                    silent = FALSE){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(!is.logical(show_deleted)){cli::cli_alert_danger("show_deleted must be TRUE or FALSE"); stop()}

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
      still_valid_token = TRUE; if(!is.logical(silent)){cli::cli_alert_success("Method succeeded")}}
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
