variable "zone_id" {
  description = "(Optional) ID of DNS zone"
  type        = string
  default     = null
}

variable "zone_name" {
  description = "(Optional) Name of DNS zone"
  type        = string
  default     = null
}

variable "private_zone" {
  description = "(Optional) Whether Route53 zone is private or public"
  type        = bool
  default     = false
}

variable "records" {
  description = <<EOF
    (Required) List of maps of DNS records parameters defined below

    (Required) name - The name of the record. (Please specify only subdomain)
    (Required) type - The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT.
    (Required for non-alias records) ttl - The TTL of the record.
    (Required for non-alias records) records - A string list of records.
    (Optional) set_identifier - Unique identifier to differentiate records with routing policies from one another. 
                                Required if using "failover", 'geolocation', "latency", or "weighted" routing policies.
    (Optional) health_check_id - The health check the record should be associated with.
    (Optional) multivalue_answer_routing_policy - Set to true to indicate a multivalue answer routing policy.
    (Optional) alias - An alias block. Conflicts with "ttl" & "records".
    (Optional) failover_routing_policy - A block indicating the routing behavior when associated health check fails.
    (Optional) geolocation_routing_policy - A block indicating a routing policy based on the geolocation of the requestor.
    (Optional) latency_routing_policy - A block indicating a routing policy based on the latency between the requestor and an AWS region.
    (Optional) weighted_routing_policy - A block indicating a weighted routing policy.
  EOF
  type        = list(any)
  default     = []
}
