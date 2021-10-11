output "account" {
  value = aws_organizations_account.account
}

output "account_id" {
  value = aws_organizations_account.account.id
}

output "account_name" {
  value = local.name
}

output "account_email" {
  value = local.email
}
