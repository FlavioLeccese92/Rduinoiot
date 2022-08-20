
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rduinoiot

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/Rduinoiot)](https://CRAN.R-project.org/package=Rduinoiot)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/FlavioLeccese92/Rduinoiot/workflows/R-CMD-check/badge.svg)](https://github.com/FlavioLeccese92/Rduinoiot/actions)
<!-- badges: end -->

Rduinoiot provides an easy way to connect to Arduino Iot Cloud API with
R. Functions allows to exploit API methods for many purposes, manage
your Arduino devices and dashboards and access to the data produced by
sensors and sketches.

## Installation

You can install the development version of Rduinoiot from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("FlavioLeccese92/Rduinoiot")
```

## Example

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

things_properties_timeseries(thing_id = thing_id, property_id = property_id,
                             desc = FALSE, interval = 60)
#> Method succeeded
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
#> # i Use `print(n = ...)` to see more rows
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
