locals {
  team      = "ops"
  role_name = "route53"

  # The domain девопс.бел had been removed
  # due to AWS is not supporting ACM certs for BY/БЕЛ domains
  domain_name = "xn--b1add1bfm.xn--90ais"
}
