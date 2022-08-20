#' Properties (of things) API methods
#'
#' Create, Update, List, Show and Delete properties associated to a given thing
#'
#' Official documentation:
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Create}{propertiesV2Create}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Update}{propertiesV2Update}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2List}{propertiesV2List}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Show}{propertiesV2Show}
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Delete}{propertiesV2Delete}
#' @md
#'
#' @param thing_id The id of the thing
#' @param property_id The id of the thing
#' @param show_deleted If TRUE, shows the soft deleted properties (default FALSE)
#' @param name The friendly name of the property
#' @param permission The permission of the property (READ_ONLY or READ_WRITE allowed)
#' @param type The type of the property (see details for exhaustive list of values)
#' @param update_strategy The update strategy for the property value (ON_CHANGE or TIMED allowed)
#' @param ... Optional parameters for `things_properties_create`:
#'  * `max_value` (numeric) Maximum value of this property
#'  * `min_value` (numeric) Minimum value of this property
#'  * `persist` (logic) If TRUE, data will persist into a timeseries database
#'  * `tag` (numeric) The integer id of the property
#'  * `update_parameter` (numeric) The update frequency in seconds, or the amount of the property
#'  has to change in order to trigger an update
#'  * `variable_name` (character) The sketch variable name of the property
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default getOption('ARDUINO_API_TOKEN'))
#' @return A tibble showing the information about properties for given device
#' @examples
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'V8CpJ82mOtpsBgnGqeVGvRpSw9SOXcNo')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'OSo32AvUyJCe15UO90kXxrDQtsf1DpsFJ5CYI3xT9TaHe1SvIu8BwBteGl0pAdL5')
#' create_auth_token()
#'
#' thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
#'
#' ### create property ###
#' things_properties_create(thing_id = thing_id, name = "test",
#' permission = "READ_ONLY", type = "FLOAT", update_strategy = "ON_CHANGE", update_parameter = 10)
#'
#' ### check properties list ###
#' things_properties_list(thing_id = thing_id)
#' things_properties_show(thing_id = thing_id, property_id = "562c6b29-6dc0-4cc9-aaf4-3ca86e587ff3")
#'
#' ### update property ###
#' things_properties_update(thing_id = thing_id, property_id = "9f62ede5-4dab-443d-97c1-9fdf56276d6f",
#' name = "testupdated2", permission = "READ_ONLY", type = "FLOAT", update_strategy = "ON_CHANGE", update_parameter = 10)
#'
#' ### delete property ###
#' things_properties_delete(thing_id = thing_id, property_id = "9f62ede5-4dab-443d-97c1-9fdf56276d6f")
#'
#' @name things_properties
#' @rdname things_properties
#' @export
things_properties_create <- function(thing_id,
                                     name, permission, type, update_strategy,
                                     ...,
                                     token = getOption('ARDUINO_API_TOKEN')){

  missing_args = setdiff(c("thing_id", "name", "permission", "type", "update_strategy"),
                         names(unlist(match.call())))
  if(length(missing_args)>0){
    stop(paste0("missing argument ", paste0(missing_args, collapse = ", ")), call. = FALSE)
  }
  add_args = list(...)
  add_args_name = c("max_value", "min_value", "persist", "tag", "update_parameter", "variable_name")
  add_body = add_args[which(names(add_args) %in% add_args_name)]

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}
  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('name' = name,
                'permission' = permission,
                'type' = type,
                'update_strategy' = update_strategy)
    if(length(add_body)>0){body = append(body, add_body)}
    res = httr::PUT(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 201){
      still_valid_token = TRUE
      message("Method succeeded")}
    else if(res$status_code == 401){
      message("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail)))}
  }
}
#' @name things_properties
#' @export
#'
things_properties_update <- function(thing_id, property_id,
                                     name, permission, type, update_strategy,
                                     ...,
                                     token = getOption('ARDUINO_API_TOKEN')){

  missing_args = setdiff(c("thing_id", "property_id", "name", "permission", "type", "update_strategy"),
                         names(unlist(match.call())))
  if(length(missing_args)>0){
    stop(paste0("missing argument ", paste0(missing_args, collapse = ", ")), call. = FALSE)
  }
  add_args = list(...)
  add_args_name = c("max_value", "min_value", "persist", "tag", "update_parameter", "variable_name")
  add_body = add_args[which(names(add_args) %in% add_args_name)]

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}
  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s", thing_id, property_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('name' = name,
                'permission' = permission,
                'type' = type,
                'update_strategy' = update_strategy)
    if(length(add_body)>0){body = append(body, add_body)}
    res = httr::POST(url = url, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      still_valid_token = TRUE
      message("Method succeeded")}
    else if(res$status_code == 401){
      message("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail)))}
  }
}
#' @name things_properties
#' @export
#'
things_properties_list <- function(thing_id,
                                   show_deleted = FALSE,
                                   token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){stop("missing thing_id", call. = FALSE)}
  if(!is.logical(show_deleted)){stop("show_deleted must be TRUE or FALSE", call. = FALSE)}

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties?show_deleted=%s", thing_id, show_deleted)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ")
        res$value_updated_at = as.POSIXct(res$value_updated_at, format = "%Y-%m-%dT%H:%M:%OSZ")
      }
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
#' @name things_properties
#' @export
#'
things_properties_show <- function(thing_id,
                                   property_id,
                                   token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){stop("missing thing_id", call. = FALSE)}
  if(missing(thing_id)){stop("missing property_id", call. = FALSE)}

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s", thing_id, property_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ")
        if("value_updated_at" %in% names(res)){
          res$value_updated_at = as.POSIXct(res$value_updated_at, format = "%Y-%m-%dT%H:%M:%OSZ")}
      }
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
#' @name things_properties
#' @export
#'
things_properties_delete <- function(thing_id,
                                     property_id,
                                     token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){stop("missing thing_id", call. = FALSE)}
  if(missing(property_id)){stop("missing property_id", call. = FALSE)}

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s", thing_id, property_id)
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
    else if(res$status_code == 404){ still_valid_token = TRUE; stop("API error: Not found\n")}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      stop(cat(paste0("API error: ", res_detail, "\n")))}
  }
}
