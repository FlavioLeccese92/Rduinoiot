#' Tags (of things) API methods
#'
#' @description
#'
#' Upsert (create/update), List and Delete tags associated to a given thing
#'
#' Official documentation:
#'  * [thingsV2TagsUpsert](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2Tags-thingsV2TagsUpsert>)
#'  * [thingsV2TagsList](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2Tags-thingsV2TagsList>)
#'  * [thingsV2TagsDelete](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2Tags-thingsV2TagsDelete>)
#' @md
#'
#' @param thing_id The id of the thing
#' @param key The key of the tag (no spaces allowed)
#' @param value The value of the tag (no spaces allowed)
#' @param store_token Where your token is stored. If `option` it will be retrieved from the .Rprofile (not cross-session and default),
#' if `envir` it will be retrieved from environmental variables list (cross-session).
#' @param token A valid token created with `create_auth_token` or manually.
#' It not `NULL` it has higher priority then `store_token`.
#' @return A tibble showing information about chosen tag or list of tags for given thing
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
                               store_token = "option",
                               token = NULL){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(missing(key)){cli::cli_alert_danger("missing key"); stop()}
  key = as.character(key)
  if(missing(value)){cli::cli_alert_danger("missing value"); stop()}
  value = as.character(value)

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/tags", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('key' = key, 'value' = value)
    res = httr::PUT(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      res = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      cli::cli_text(paste0("Created/Updated tag with
      {.field key} = {.val ", res$key,"} and {.field value} = {.val ", res$value,"}"))}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE)
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail, "\n"))); stop()}
  }
}
#' @name things_tags
#' @export
things_tags_list <- function(thing_id,
                             store_token = "option",
                             token = NULL){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/tags", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$tags)}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE)
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail, "\n"))); stop()}
  }
  return(res)
}

#' @name things_tags
#' @export
things_tags_delete <- function(thing_id,
                               key,
                               store_token = "option",
                               token = NULL){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(missing(key)){cli::cli_alert_danger("missing key"); stop()}
  key = as.character(key)
  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/tags/%s", thing_id, key)
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
      token = create_auth_token(store_token = store_token, return_token = TRUE)
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail, "\n"))); stop()}
  }
}

