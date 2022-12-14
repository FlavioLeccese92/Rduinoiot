% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create-auth-token.R
\name{create_auth_token}
\alias{create_auth_token}
\title{Create Auth Token for Arduino IoT Cloud API}
\usage{
create_auth_token(
  client_id = Sys.getenv("ARDUINO_API_CLIENT_ID"),
  client_secret = Sys.getenv("ARDUINO_API_CLIENT_SECRET"),
  store_token = "option",
  return_token = FALSE,
  silent = FALSE,
  ...
)
}
\arguments{
\item{client_id}{Your client id (default is the environmental variable \code{ARDUINO_API_CLIENT_ID})}

\item{client_secret}{Your client secret (default is the environmental variable \code{ARDUINO_API_CLIENT_SECRET})}

\item{store_token}{Where your token is stored. If \code{option} it will be saved into the .Rprofile (not cross-session),
if \code{envir} it will be saved as an environmental variable.}

\item{return_token}{If \code{TRUE} returns the token value as output of the function.}

\item{silent}{Whether to hide or show API method success messages (default \code{FALSE})}

\item{...}{Additional parameters needed for the body of the \code{POST} request:
\itemize{
\item \code{token_url} (default: \verb{https://api2.arduino.cc/iot/v1/clients/token/})
\item \code{grant_type} (default: \code{client_credentials})
\item \code{audience} (default: \verb{https://api2.arduino.cc/iot/})
\item \code{content_type} (default: \code{application/x-www-form-urlencoded})
}}
}
\value{
A token valid for Arduino IoT Cloud API. It can  retrievable by \code{getOption('ARDUINO_API_TOKEN')} (if \code{store_content} = "option")
or by \code{Sys.getenv("ARDUINO_API_TOKEN")} (if \code{store_token} = "envir")
}
\description{
Obtain an authorization token using your personal client_id and client_secret.

Official documentation: \href{https://www.arduino.cc/reference/en/iot/api/#api/}{API Summary}
}
\examples{
\dontrun{
# Sys.setenv(ARDUINO_API_CLIENT_ID = 'INSERT CLIENT_ID HERE')
# Sys.setenv(ARDUINO_API_CLIENT_SECRET = 'INSERT CLIENT_SECRET HERE')

create_auth_token()
}
}
