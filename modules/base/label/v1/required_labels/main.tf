variable check {
  validation {
    condition     = var.check.team != null
    error_message = "You must provide a `team`."
  }

  validation {
    condition     = var.check.name != null
    error_message = "You must provide a `name`."
  }

  validation {
    condition     = contains(["default", "audit", "production", "staging", "integration"], var.check.environment)
    error_message = "`environment` must be one of: default, production, staging or integration."
  }
}
