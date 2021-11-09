output "id" {
  value = join("", aws_iam_role.role.*.id)
}

output "name" {
  value = join("", aws_iam_role.role.*.name)
}

output "arn" {
  value = join("", aws_iam_role.role.*.arn)
}
