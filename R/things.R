#' Things API methods
#'
#' @description
#'
#' Create, Update, List, Show and Delete properties associated to a given thing
#'
#' Official documentation:
#'  * [thingsV2Create](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2Create>)
#'  * [thingsV2Update](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2Update>)
#'  * [thingsV2List](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2List>)
#'  * [thingsV2Show](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2Show>)
#'  * [thingsV2Delete](<https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2Delete>)
#' @md
#'
#' @param thing_id The id of the thing
#' @param device_id The id of the device (The arn of the associated device)
#' @param name The friendly name of the thing
#' @param properties A tibble with the following columns (see `things_properties_create`)
#'  * `name` (required) The friendly name of the property
#'  * `permission` (required) The permission of the property (READ_ONLY or READ_WRITE allowed)
#'  * `type` (required) The type of the property (see details for exhaustive list of values)
#'  * `update_strategy` (required) The update strategy for the property value (ON_CHANGE or TIMED allowed)
#'  * `max_value` (optional, numeric) Maximum value of this property
#'  * `min_value` (optional, numeric) Minimum value of this property
#'  * `persist` (optional, logic) If `TRUE`, data will persist into a timeseries database
#'  * `tag` (optional, numeric) The integer id of the property
#'  * `update_parameter` (optional, numeric) The update frequency in seconds, or the amount of the property
#'  has to change in order to trigger an update
#'  * `variable_name` (character) The sketch variable name of the property
#' @param timezone A time zone name. Check `get_timezone` for a list of valid names. (default: America/New_York)
#' @param force (logical)  If `TRUE`, detach device from the other thing, and attach to this thing.
#' In case of deletion, if `TRUE`, hard delete the thing. Default to `FALSE`
#' @param show_deleted (logical) If `TRUE`, shows the soft deleted things. Default to `FALSE`
#' @param show_properties (logical) If `TRUE`, returns things with their properties, and last values. Default to `FALSE`
#' @param tags tags you  may want to filter from the list
#' @param token A valid token created with `create_auth_token`
#' (either explicitly assigned or retrieved via default `getOption('ARDUINO_API_TOKEN')`)
#' @return A tibble showing information about chosen thing or list of thing for current user
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#' create_auth_token()
#'
#' ### create thing ###
#' things_create(name = "test")
#'
#' ### check things list ###
#' t_list = things_list()
#' thing_id = t_list %>% filter(name == "test") %>% pull(id)
#'
#' things_show(thing_id = thing_id)
#'
#' ### update thing ###
#' properties = tibble(name = c("test1", "test2"),
#' permission = rep("READ_ONLY", 2), type = rep("FLOAT", 2),
#' update_strategy = rep("ON_CHANGE", 2), update_parameter = rep(10, 2))
#'
#' things_update(thing_id = thing_id, name = "test_update", properties = properties)
#'
#' ### delete thing ###
#' things_delete(thing_id = thing_id)
#' }
#' @name things
#' @rdname things
#' @export
things_create <- function(device_id = NULL, thing_id = NULL, name = NULL,
                          properties = NULL, timezone = NULL, force = FALSE,
                          token = getOption('ARDUINO_API_TOKEN')){

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  if(!is.logical(force)){cli::cli_alert_danger("force must be TRUE or FALSE"); stop()}

  url = "https://api2.arduino.cc/iot/v2/things"
  still_valid_token = FALSE

  while(!still_valid_token){
    if(!is.null(properties)){properties = purrr::transpose(properties)}
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('device_id' = device_id,
                'id' = thing_id,
                'name' = name,
                'properties' = properties,
                'timezone' = timezone)
    query = list('force' = force)
    res = httr::PUT(url = url, query = query, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 201){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      res = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))
      cli::cli_text(paste0("Created thing with
      {.field name} = {.val ", res$name,"} and {.field thing_id} = {.val ", res$id,"}"))}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
#' @name things
#' @export
#'
things_update <- function(device_id = NULL, thing_id = NULL, name = NULL,
                          properties = NULL, timezone = NULL, force = FALSE,
                          token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(!is.logical(force)){cli::cli_alert_danger("force must be TRUE or FALSE"); stop()}

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    body = list('device_id' = device_id,
                'id' = thing_id,
                'name' = name,
                'properties' = properties,
                'timezone' = timezone)
    query = list('force' = force)
    res = httr::POST(url = url, query = query, body = body, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      cli::cli_text(paste0("Updated thing with {.field thing_id} = {.val ", thing_id,"}"))}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')
      cli::cli_alert_warning("Check if Thing actually exists")
      t_list = things_list()
      if(nrow(t_list) == 0){cli::cli_alert_danger("No Things associated to the user"); stop()}
      else if(!(thing_id %in% t_list$properties_count)){cli::cli_alert_danger("No Thing associated to thing_id"); stop()}
    }
    else {
      still_valid_token = TRUE
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
#' @name things
#' @export
things_list <- function(device_id = NULL, thing_id = NULL,
                        show_deleted = FALSE, show_properties = FALSE, tags = NULL,
                        token = getOption('ARDUINO_API_TOKEN')){

  ### attention: if TRUE returns 401 -> meaning of the parameter not clear ###
  across_user_ids = FALSE

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}
  if(!is.logical(show_deleted)){cli::cli_alert_danger("show_deleted must be TRUE or FALSE"); stop()}
  if(!is.logical(show_properties)){cli::cli_alert_danger("show_properties must be TRUE or FALSE"); stop()}

  url = "https://api2.arduino.cc/iot/v2/things"
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('across_user_ids' = across_user_ids,
                 'device_id' = device_id,
                 'ids' = thing_id,
                 'show_deleted' = show_deleted,
                 'show_properties' = show_properties,
                 'tags' = tags)
    res = httr::GET(url = url, query = query, httr::add_headers(header), encode = "json")
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
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
#' @name things
#' @export
#'
things_show <- function(thing_id, show_deleted = FALSE,
                        token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(!is.logical(show_deleted)){cli::cli_alert_danger("show_deleted must be TRUE or FALSE"); stop()}

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('show_deleted' = show_deleted)
    res = httr::GET(url = url, query = query, httr::add_headers(header))
    if(res$status_code == 200){
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        if("value_updated_at" %in% names(res)){
          res$value_updated_at = as.POSIXct(res$value_updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")}
      }
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
#' @name things
#' @export
#'
things_delete <- function(thing_id, force = FALSE,
                          token = getOption('ARDUINO_API_TOKEN')){

  if(missing(thing_id)){cli::cli_alert_danger("missing thing_id"); stop()}
  if(!is.logical(force)){cli::cli_alert_danger("force must be TRUE or FALSE"); stop()}

  if(is.null(token)){cli::cli_alert_danger("Token is null: use function create_auth_token to create a valid one"); stop()}

  url = sprintf("https://api2.arduino.cc/iot/v2/things/%s", thing_id)
  still_valid_token = FALSE

  while(!still_valid_token){
    header = c('Authorization' = paste0("Bearer ", token),
               'Content-Type' = "text/plain")
    query = list('force' = force)
    res = httr::DELETE(url = url, query = query, httr::add_headers(header))
    if(res$status_code == 200){
      still_valid_token = TRUE; cli::cli_alert_success("Method succeeded")
      cli::cli_text(paste0("Deleted thing with {.field thinkg_id} = {.val ", thing_id,"}"))}
    else if(res$status_code == 401){
      cli::cli_alert_warning("Request not authorized: regenerate token")
      create_auth_token(); token = getOption('ARDUINO_API_TOKEN')}
    else if(res$status_code == 404){ still_valid_token = TRUE; cli::cli_alert_danger("API error: Not found"); stop()}
    else{
      res_detail = jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8"))$detail
      cli::cli_alert_danger(cat(paste0("API error: ", res_detail))); stop()}
  }
}
