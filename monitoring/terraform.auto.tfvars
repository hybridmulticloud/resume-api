api_canary_name      = "resume-api-canary"
homepage_canary_name = "resume-home-canary"
schedule_expression  = "rate(5 minutes)"
tags = {
  Project     = "resume-api"
  Environment = "production"
}
