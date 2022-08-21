#' Tags (of things) API methods
#'
#' Upsert (create/update), List and Delete tags associated to a given thing
#'
#' Official documentation:
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2Tags-thingsV2TagsUpsert}{thingsV2TagsUpsert}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2Tags-thingsV2TagsList}{thingsV2TagsList}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2Tags-thingsV2TagsDelete}{thingsV2TagsDelete}
#' @md
#'
#' @param thing_id The id of the thing
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
#' thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
#'
#' ### create/modify tag ###
#' things_tags_upsert(thing_id = thing_id, key = "1", value = "test")
#'
#' ### check tags list ###
#' things_tags_list(thing_id = thing_id)
#'
#' ### delete tag ###
#' things_tags_delete(thing_id = thing_id, key = "1")
#' }
#' @name things_tags
#' @rdname things_tags
#' @export
things_tags_upsert <- function(thing_id,
                               key, value,
                               token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){stop("missing thing_id", call. = FALSE)}
  if(missing(key)){stop("missing key", call. = FALSE)}
  key = as.character(key)
  if(missing(value)){stop("missing value", call. = FALSE)}
  value = as.character(value)
  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/tags", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('key' = key, 'value' = value)
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
#' @name things_tags
#' @export
things_tags_list <- function(thing_id,
                             token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){stop("missing thing_id", call. = FALSE)}
  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/tags", thing_id)
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

#' @name things_tags
#' @export
things_tags_delete <- function(thing_id,
                               key,
                               token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){stop("missing thing_id", call. = FALSE)}
  if(missing(key)){stop("missing key", call. = FALSE)}
  key = as.character(key)
  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/tags/%s", thing_id, key)
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

