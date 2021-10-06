output "id" {
  value       = local.id
  description = "Disambiguated ID restricted to `id_length_limit` characters in total"
}

output "id_brief" {
  value       = local.id
  description = "Brief disambiguated ID, limited to `id_length_limit` characters (Deprecated, use id)"
}

output "id_full" {
  value       = local.id_full
  description = "Disambiguated ID not restricted in length"
}

output "attributes" {
  value       = local.attributes
  description = "Normalized attributes"
}

output "environment" {
  value       = local.input.environment
  description = "Normalized environment"
}

output "tags" {
  value       = local.tags
  description = "Normalized Tag map"
}

output "context" {
  value       = local.input
  description = <<-EOT
  Merged but otherwise unmodified input to this module, to be used as context input to other modules.
  Note: this version will have null values as defaults, not the values actually used as defaults.
EOT
}

output "tags_as_list_of_maps" {
  value       = local.tags_as_list_of_maps
  description = "Additional tags as a list of maps, which can be used in several AWS resources"
}

output "normalized_context" {
  value       = local.output_context
  description = "Normalized context of this module"
}

output "name" {
  value       = local.input.name
  description = "Normalized name"
}

output "team" {
  value       = local.input.team
  description = "Normalized team name"
}

output "s3_bucket_name" {
  value       = local.s3_bucket_name
  description = "Normalized S3 bucket names"
}
