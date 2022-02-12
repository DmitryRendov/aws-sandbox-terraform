output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb.main.id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.main.dns_name
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = aws_lb.main.arn_suffix
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = aws_lb.main.zone_id
}

output "listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value = [
    for listener in aws_lb_listener.main : listener.arn
  ]
}

output "listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value = [
    for listener in aws_lb_listener.main : listener.id
  ]
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value = [
    for tg in aws_lb_target_group.main : tg.arn
  ]
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value = [
    for tg in aws_lb_target_group.main : tg.arn_suffix
  ]
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value = [
    for tg in aws_lb_target_group.main : tg.name
  ]
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs."
  value = [
    for attachment in aws_lb_target_group_attachment.main : attachment.id
  ]
}
