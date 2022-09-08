library(Rduinoiot)
library(dplyr)


Sys.setenv(ARDUINO_API_CLIENT_ID = 'V8CpJ82mOtpsBgnGqeVGvRpSw9SOXcNo')
Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'OSo32AvUyJCe15UO90kXxrDQtsf1DpsFJ5CYI3xT9TaHe1SvIu8BwBteGl0pAdL5')
create_auth_token()

thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
properties_list = things_properties_list(thing_id) %>% select(property_id = id, name)

.build_data2 = function(data, ...) {
  require(dplyr)
  row.names(data) = NULL
  data = data %>% select(...)
  data = unname(data)
  out = as.list(as.data.frame(t(data))) %>% unname()
  return(out)
}

plot_ts = function(thing_id, properties_list,
                   par_name = "humidity", type = "hour", width = NULL, height = NULL){

  require(echarts4r)
  require(dplyr)
  require(lubridate)
  require(stringr)

  property_id = properties_list %>% filter(name == par_name) %>% pull(property_id)

  type_numeric = switch(type, "hour" = 1, "day" = 24, "week" = 24*7, "month" = 24*31)

  from = Sys.time() - 3600*type_numeric + 1
  to = Sys.time() + 1

  data_ts = things_properties_timeseries(
    thing_id, property_id,
    from = from, to = to, desc = TRUE) %>%
    mutate(time = with_tz(time, tzone = Sys.timezone()))

  data_ts_list = .build_data2(data_ts, time, value)

  series = list()
  series[[1]] = list(type = 'line', name = "Value", color = "#007BFF", showSymbol = FALSE, smooth = TRUE,
                     connectNulls = TRUE, animation = FALSE, data = data_ts_list, zlevel = 10,
                     emphasis = NULL)
  opts = list(
    title = list(left = 'center',
                 text = str_to_title(par_name),
                 subtext = paste0("Last ", type, " (1000 points)"),
                 textStyle = list(fontWeight = 'lighter')),
    grid = list(top = 70, right = 30, left = 50, bottom = 30),
    tooltip = list(trigger = 'axis'),
    xAxis = list(show = TRUE, type = "time",
                 min = from, max = to),
    yAxis = list(show = TRUE, scale = TRUE),
    series = series,
    backgroundColor = "white"
  )

  out = e_charts(width = width, height = height) %>% e_list(opts)
  return(out)
}

