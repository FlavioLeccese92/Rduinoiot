#' Properties (of devices) API methods
#'
#' List properties associated to a given device
#'
#' Official documentation: \href{https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2-devicesV2GetProperties}{devicesV2GetProperties}
#'
#' @param device_id The id of the device
#' @param show_deleted If `TRUE`, shows the soft deleted properties. Default to `FALSE`
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default \code{getOption('ARDUINO_API_TOKEN')})
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
                                    token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){stop("missing device_id", call. = FALSE)}
  if(!is.logical(show_deleted)){stop("show_deleted must be TRUE or FALSE", call. = FALSE)}

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/properties?show_deleted=%s", device_id, show_deleted)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      message("Method succeeded")}
    else if(res$status_code == 401){
      message("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail)))}
  }
  return(res)
}
