#' Properties (of things) API methods
#'
#' @description
#'
#' Create, Update, List, Show and Delete properties associated to a given thing
#'
#' Official documentation:
#'  * [propertiesV2Create](<https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Create>)
#'  * [propertiesV2Update](<https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Update>)
#'  * [propertiesV2List](<https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2List>)
#'  * [propertiesV2Show](<https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Show>)
#'  * [propertiesV2Delete](<https://www.arduino.cc/reference/en/iot/api/#api-PropertiesV2-propertiesV2Delete>)
#' @md
#'
#' @param thing_id The id of the thing
#' @param property_id The id of the property
#' @param show_deleted If `TRUE`, shows the soft deleted properties. Default to `FALSE`
#' @param name The friendly name of the property
#' @param permission The permission of the property (READ_ONLY or READ_WRITE allowed)
#' @param type The type of the property (see details for exhaustive list of values)
#' @param update_strategy The update strategy for the property value (ON_CHANGE or TIMED allowed)
#' @param ... Optional parameters for `things_properties_create`:
#'  * `max_value` (numeric) Maximum value of this property
#'  * `min_value` (numeric) Minimum value of this property
#'  * `persist` (logic) If `TRUE`, data will persist into a timeseries database
#'  * `tag` (numeric) The integer id of the property
#'  * `update_parameter` (numeric) The update frequency in seconds, or the amount of the property
#'  has to change in order to trigger an update
#'  * `variable_name` (character) The sketch variable name of the property
#' @param store_token Where your token is stored. If `option` it will be retrieved from the .Rprofile (not cross-session and default),
#' if `envir` it will be retrieved from environmental variables list (cross-session)
#' @param token A valid token created with `create_auth_token` or manually.
#' It not `NULL` it has higher priority then `store_token`.
#' @param silent Whether to hide or show API method success messages (default `FALSE`)
#' @return A tibble showing information about chosen property or list of properties for given thing
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#' create_auth_token()
#'
#' thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
#'
#' ### create property ###
#' things_properties_create(thing_id = thing_id,
#' name = "test",  permission = "READ_ONLY", type = "FLOAT",
#' update_strategy = "ON_CHANGE", update_parameter = 10)
#'
#' ### check properties list ###
#' p_list = things_properties_list(thing_id = thing_id, show_deleted = FALSE)
#' property_id = p_list %>% filter(name == "test") %>% pull(id)
#'
#' things_properties_show(thing_id = thing_id, property_id = property_id)
#'
#' ### update property ###
#' things_properties_update(thing_id = thing_id, property_id = property_id,
#' name = "test_update", permission = "READ_ONLY", type = "FLOAT",
#' update_strategy = "ON_CHANGE", update_parameter = 10)
#'
#' ### delete property ###
#' things_properties_delete(thing_id = thing_id, property_id = property_id)
#' }
#' @name things_properties
#' @rdname things_properties
#' @export
things_properties_create <- function(thing_id,
                                     name, permission, type, update_strategy,
                                     ...,
                                     store_token = "option",
                                     token = NULL,
                                     silent = FALSE){

  missing_args = setdiff(c("thing_id", "name", "permission", "type", "update_strategy"),
                         names(unlist(match.call())))
  if(length(missing_args)>0){
    cli::cli_alert_danger(paste0("Missing argument ", paste0(missing_args, collapse = ", "))); stop()
  }
  add_args = list(...)
  add_args_name = c("max_value", "min_value", "persist", "tag", "update_parameter", "variable_name")
  add_body = add_args[which(names(add_args) %in% add_args_name)]

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!(store_token %in% c("option", "envir"))){cli::cli_alert_danger("store_token must be either 'option' or 'envir'"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/", thing_id)
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
      res = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      if(!silent){
        cli::cli_alert_success("Method succeeded")
        cli::cli_text(paste0("Created property with
                             {.field name} = {.val ", res$variable_name,"} and {.field property_id} = {.val ", res$id,"}"))
        }
    }
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
      }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
#' @name things_properties
#' @export
things_properties_update <- function(thing_id, property_id,
                                     name, permission, type, update_strategy,
                                     ...,
                                     store_token = "option",
                                     token = NULL,
                                     silent = FALSE){

  missing_args = setdiff(c("thing_id", "property_id", "name", "permission", "type", "update_strategy"),
                         names(unlist(match.call())))
  if(length(missing_args)>0){
    cli::cli_alert_danger(paste0("Missing argument ", paste0(missing_args, collapse = ", "))); stop()
  }
  add_args = list(...)
  add_args_name = c("max_value", "min_value", "persist", "tag", "update_parameter", "variable_name")
  add_body = add_args[which(names(add_args) %in% add_args_name)]

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s/", thing_id, property_id)
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
      if(!silent){
        cli::cli_alert_success("Method succeeded")
        cli::cli_text(paste0("Updated property with {.field property_id} = {.val ", property_id,"}"))}
    }
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
      }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
#' @name things_properties
#' @export
things_properties_list <- function(thing_id,
                                   show_deleted = FALSE,
                                   store_token = "option",
                                   token = NULL,
                                   silent = FALSE){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(!is.logical(show_deleted)){cli::cli_alert_danger("show_deleted must be TRUE or FALSE"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties?show_deleted=%s", thing_id, show_deleted)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$value_updated_at = as.POSIXct(res$value_updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
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
#' @name things_properties
#' @export
things_properties_show <- function(thing_id,
                                   property_id,
                                   store_token = "option",
                                   token = NULL,
                                   silent = FALSE){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(missing(property_id)){cli::cli_alert_danger("missing property_id"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s", thing_id, property_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::GET(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        if("value_updated_at" %in% names(res)){
          res$value_updated_at = as.POSIXct(res$value_updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")}
      }
      still_valid_token = TRUE; if(!silent){cli::cli_alert_success("Method succeeded")}}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
      }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail, "\n"))); stop()}
  }
  return(res)
}
#' @name things_properties
#' @export
things_properties_delete <- function(thing_id,
                                     property_id,
                                     store_token = "option",
                                     token = NULL,
                                     silent = FALSE){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(missing(property_id)){cli::cli_alert_danger("missing property_id"); stop()}

  if(!is.logical(silent)){cli::cli_alert_danger("silent must be TRUE or FALSE"); stop()}

  if(!is.null(token)){token = token}
  else if(store_token == "option"){token = getOption('ARDUINO_API_TOKEN')}
  else if(store_token == "envir"){token = Sys.getenv('ARDUINO_API_TOKEN')}
  else{cli::cli_alert_danger("Token is null and store_token neither 'option' nor 'envir':
                             use function create_auth_token to create a valid one or choose a valid value
                             for store_token"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s/properties/%s", thing_id, property_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    res = httr::DELETE(url = url, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE
      if(!silent){
        cli::cli_alert_success("Method succeeded")
        cli::cli_text(paste0("Deleted property with {.field property_id} = {.val ", property_id,"}"))}
      }
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      token = create_auth_token(store_token = store_token, return_token = TRUE, silent = silent)
      }
    else if(res$status_code == 404){
      still_valid_token = TRUE; cli::cli_alert_danger("API error: Not found");}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail, "\n"))); stop()
      }
  }
}
