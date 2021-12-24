module "sg" {
  source  = "../"
  region        = "us-east-1"
  name          = "example-security-group"
  description   = "example=description-sec-group"
  vpc_id        = "vpc-63771219"
  ingress_rules = [{"description": "example-description-for-ingress", "from_port": 443, "to_port": 443, "protocol": "HTTPS", "cidr_blocks": ["0.0.0.0/0"]}]
  egress_rules  = [{"description": "example-description-for-engress", "from_port": 443, "to_port": 443, "protocol": "HTTPS", "cidr_blocks": ["0.0.0.0/0"]}]
}