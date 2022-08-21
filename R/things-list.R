#' Things list API methods
#'
#' List things associated to the user
#'
#' Official documentation:
#'  * \href{https://www.arduino.cc/reference/en/iot/api/#api-ThingsV2-thingsV2List}{thingsV2List}
#' @md
#'
#' @param device_id device_id of the device you  may want to filter from the list
#' @param thing_id thing_id of the thing you may want to filter from the list
#' @param show_deleted (logical) If `TRUE`, shows the soft deleted things. Default to `FALSE`
#' @param show_properties (logical) If `TRUE`, returns things with their properties, and last values. Default to `FALSE`
#' @param tags tags you  may want to filter from the list
#' @param token A valid token created with `create_auth_token`
#' (either explicitely assigned or retrieved via default \code{getOption('ARDUINO_API_TOKEN')})
#' @return A tibble showing information about things associated to the user
#' @examples
#' \dontrun{
#' Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
#' Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
#'
#' create_auth_token()
#'
#' t_list = things_list()
#' }
#' @name things_list
#' @rdname things_list
#' @export
things_list <- function(device_id = NULL, thing_id = NULL,
                        show_deleted = FALSE, show_properties = FALSE, tags = NULL,
                        token = getOption('ARDUINO_API_TOKEN')
                        ){

  ### attention: if TRUE returns 401 -> meaning of the parameter not clear ###
  across_user_ids = FALSE

  if(is.null(token)){stop("Token is null: use function create_auth_token to create a valid one", call. = FALSE)}

  url = "https://api2.arduino.cc/iot/v2/things/"
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
      still_valid_token = TRUE
      res = tibble::as_tibble(jsonlite::fromJSON(httr::content(res, 'text', encoding = "UTF-8")))
      if(nrow(res)>0){
        res$created_at = as.POSIXct(res$created_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
        res$updated_at = as.POSIXct(res$updated_at, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
      }
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
