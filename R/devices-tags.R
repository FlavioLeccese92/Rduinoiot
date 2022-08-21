#' Tags (of devices) API methods
#'
#' Upsert (create/update), List and Delete tags associated to a given device
#'
#' Official documentation:
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2Tags-devicesV2TagsUpsert}{devicesV2TagsUpsert}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2Tags-devicesV2TagsList}{devicesV2TagsList}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-DevicesV2Tags-devicesV2TagsDelete}{devicesV2TagsDelete}
#' @md
#'
#' @param device_id The id of the device
#' @param key The key of the tag (no spaces allowed)
#' @param value The value of the tag (no spaces allowed)
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default \code{getOption('ARDUINO_API_TOKEN')})
#' @return A tibble showing the keys and values for given device
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

  if(missing(device_id)){stop("missing device_id", call. = FALSE)}
  if(missing(key)){stop("missing key", call. = FALSE)}
  key = as.character(key)
  if(missing(value)){stop("missing value", call. = FALSE)}
  value = as.character(value)
  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/tags", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('key' = key,
                'value' = value)
    res = httr::PUT(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      still_valid_token = TRUE
      message("Method succeeded")}
    else if(res$status_code == 401){
      message("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail, "\n")))}
  }
}
#' @name devices_tags
#' @export
devices_tags_list <- function(device_id,
                             token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){stop("missing device_id", call. = FALSE)}
  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/tags", device_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$tags)
      message("Method succeeded")}
    else if(res$status_code == 401){
      message("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail, "\n")))}
  }
  return(res)
}

#' @name devices_tags
#' @export
devices_tags_delete <- function(device_id,
                               key,
                               token = getOption('ARDUINO_API_TOKEN')){

  if(missing(device_id)){stop("missing device_id", call. = FALSE)}
  if(missing(key)){stop("missing key", call. = FALSE)}
  key = as.character(key)
  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/devices/%s/tags/%s", device_id, key)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::DELETE(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE
      message("Method succeeded")}
    else if(res$status_code == 401){
      message("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail, "\n")))}
  }
}
