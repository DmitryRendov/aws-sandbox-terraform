## Usage

```hcl
module "service_sg" {
  source = "../../../modules/base/security-group/v1"

  label       = module.label
  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "vpc-12345678"

  ingress_rules            = [
    {
      "description": "example-description-for-ingress",
      "from_port": 443,
      "to_port": 443,
      "protocol": "HTTPS",
      "cidr_blocks": [
        "0.0.0.0/0"
      ]
    }
  ]
  egress_rules = [
    {
      "description": "example-description-for-engress",
      "from_port": 443,
      "to_port": 443,
      "protocol": "HTTPS",
      "cidr_blocks": [
        "0.0.0.0/0"
      ]
    }
  ]
}
```
