library(rollbar)
library(here)

readRenviron(here(".Renviron"))

R_ENV <- Sys.getenv("R_ENV")

if (R_ENV == "production") {
  rollbar.configure(
    access_token = Sys.getenv("ROLLBAR_ACCESS_TOKEN"),
    env = Sys.getenv("R_ENV"),
    root = here("")
  )
  rollbar.attach()
}
