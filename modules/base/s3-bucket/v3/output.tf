output "id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.bucket.id
}

output "arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.bucket.arn
}

output "domain_name" {
  description = "The domain name of the bucket in format of bucketname.s3.amazonaws.com"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "regional_domain_name" {
  description = "The regional domain name of the bucket in format of bucketname.s3-us-west-2.amazonaws.com"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "backup_id" {
  description = "The name of the mirrored bucket in another region."
  value       = join("", aws_s3_bucket.s3_backups.*.id)
}

output "backup_arn" {
  description = "The ARN of the mirrored bucket in another region. Will be of format arn:aws:s3:::bucketname."
  value       = join("", aws_s3_bucket.s3_backups.*.arn)
}
