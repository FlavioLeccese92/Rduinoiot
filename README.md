
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rduinoiot

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/Rduinoiot)](https://CRAN.R-project.org/package=Rduinoiot)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/FlavioLeccese92/Rduinoiot/workflows/R-CMD-check/badge.svg)](https://github.com/FlavioLeccese92/Rduinoiot/actions)
<!-- badges: end -->

**Rduinoiot** provides an easy way to connect to [Arduino Iot Cloud
API](https://create.arduino.cc/iot/) with R. Functions allow to exploit
[API methods](https://www.arduino.cc/reference/en/iot/api) for many
purposes, manage your Arduino devices and dashboards and access to the
data produced by sensors and sketches.

## Installation

You can install the development version of Rduinoiot from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("FlavioLeccese92/Rduinoiot")
```

## Authentication

``` r
library(Rduinoiot)
# Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
# Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')

create_auth_token()
#> v Authorization succeeded
```

## List things associated to the user

Things associated to the user account can be easily accessed using
`things_list()`. This function will return detailed information, in
particular `things_id` which are needed to access to properties.

\`\`\`{r example 1\] create\_auth\_token()

things\_list()


    ## Real-time sensor data

    Reading real-time humidity sensor of one of your devices can be done like this:


    ```r

    thing_id = "b6822400-2f35-4d93-b3e7-be919bdc5eba"
    property_id = "d1134fe1-6519-49f1-afd8-7fe9e891e778"

    things_properties_timeseries(thing_id = thing_id, property_id = property_id,
                                 desc = FALSE, interval = 60)
    #> v Method succeeded
    #> # A tibble: 1,000 x 2
    #>    time                value
    #>    <dttm>              <dbl>
    #>  1 2022-08-12 21:58:00  27.8
    #>  2 2022-08-12 21:59:00  28.0
    #>  3 2022-08-12 22:00:00  28.3
    #>  4 2022-08-12 22:01:00  28.6
    #>  5 2022-08-12 22:02:00  28.9
    #>  6 2022-08-12 22:03:00  29.2
    #>  7 2022-08-12 22:04:00  29.5
    #>  8 2022-08-12 22:05:00  29.7
    #>  9 2022-08-12 22:06:00  29.9
    #> 10 2022-08-12 22:07:00  30.1
    #> # ... with 990 more rows
