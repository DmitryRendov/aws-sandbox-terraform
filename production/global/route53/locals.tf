locals {
  team      = "ops"
  role_name = "route53"

  domain_name = "devops.net.pl"

  records = [
    {
      name    = ""
      type    = "A"
      ttl     = 300
      records = ["213.186.33.5"]
    },
    {
      name    = ""
      type    = "SPF"
      ttl     = 300
      records = ["v=spf1 include:mx.ovh.com -all"]
    },
    {
      name    = ""
      type    = "TXT"
      ttl     = 300
      records = ["1|www.devops.net.pl"]
    },
    {
      name = ""
      type = "MX"
      ttl  = 300
      records = [
        "1 mx1.mail.ovh.net.",
        "5 mx2.mail.ovh.net.",
        "100 mx3.mail.ovh.net.",
      ]
    },
    {
      name    = "ftp"
      type    = "CNAME"
      ttl     = 300
      records = ["devops.net.pl."]
    },
    {
      name    = "www"
      type    = "A"
      ttl     = 300
      records = ["213.186.33.5"]
    },
    {
      name    = "www"
      type    = "TXT"
      ttl     = 300
      records = ["3|welcome"]
    },
  ]
}
