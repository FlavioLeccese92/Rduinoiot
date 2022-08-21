
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rduinoiot

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/Rduinoiot)](https://CRAN.R-project.org/package=Rduinoiot)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/FlavioLeccese92/Rduinoiot/workflows/R-CMD-check/badge.svg)](https://github.com/FlavioLeccese92/Rduinoiot/actions)
<!-- badges: end -->

{Rduinoiot} provides an easy way to connect to (Arduino Iot Cloud
API)\[<https://create.arduino.cc/iot/>\] with R. Functions allows to
exploit (API methods)\[<https://www.arduino.cc/reference/en/iot/api>\]
for many purposes, manage your Arduino devices and dashboards and access
to the data produced by sensors and sketches.

## Installation

You can install the development version of Rduinoiot from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("FlavioLeccese92/Rduinoiot")
```

## Real-time sensor data

Reading real-time humidity sensor of one of your devices can be done
like this:

``` r
library(Rduinoiot)
# Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
# Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')
create_auth_token()
#> Authorization succeeded

thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
property_id = "d1134fe1-6519-49f1-afd8-7fe9e891e778"

dt = things_properties_timeseries(thing_id = thing_id, property_id = property_id,
                                  desc = FALSE, interval = 60)
#> Method succeeded
```
