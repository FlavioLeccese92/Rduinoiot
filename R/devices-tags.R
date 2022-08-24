#' Tags (of devices) API methods
#'
#' @description
#'
#' Upsert (create/update), List and Delete tags associated to a given device
#'
#' Official documentation:
#'  * [devicesV2TagsUpsert](https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2Tags-devicesV2TagsUpsert)
#'  * [devicesV2TagsList](https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2Tags-devicesV2TagsList)
#'  * [devicesV2TagsDelete](https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2Tags-devicesV2TagsDelete)
#' @md
#'
#' @param device_id The id of the device
#' @param key The key of the tag (no spaces allowed)
#' @param value The value of the tag (no spaces allowed)
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default `getOption('ARDUINO_API_TOKEN')`)
#' @return A tibble showing information about chosen tag or list of tags for given device
#' @examples
#' \dontrun{
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#' create_auth_token()
#'
#' device_id = "fa7ee291-8dc8-4713-92c7-9027969e4aa1"
#' ### create/modify tag ###
#' devices_tags_upsert(device_id = device_id, key = "1", value = "test")
#'
#' ### check tags list ###
#' devices_tags_list(device_id = device_id)
#'
#' ### delete tag ###
#' devices_tags_delete(device_id = device_id, key = "1")
#' }
#' @name devices_tags
#' @rdname devices_tags
#' @export
devices_tags_upsert <- function(device_id,
                                key, value,
                                token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(missing(key)){cli::cli_alert_danger("missing key"); stop()}
  key = as.character(key)
  if(missing(value)){cli::cli_alert_danger("missing value"); stop()}
  value = as.character(value)
  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/tags", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('key' = key,
                'value' = value)
    res = httr::PUT(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      res = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      cli::cli_text(paste0("Created/Updated tag with
      {.field key} = {.val ", res$key,"} and {.field value} = {.val ", res$value,"}"))}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
#' @name devices_tags
#' @export
devices_tags_list <- function(device_id,
                             token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/tags", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$tags)
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

#' @name devices_tags
#' @export
devices_tags_delete <- function(device_id,
                               key,
                               token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){cli::cli_alert_danger("missing device_id"); stop()}
  if(missing(key)){cli::cli_alert_danger("missing key"); stop()}
  key = as.character(key)
  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/tags/%s", device_id, key)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::DELETE(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      cli::cli_text(paste0("Deleted tag with {.field key} = {.val ", key,"}"))}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
