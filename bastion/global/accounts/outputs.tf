output "accounts" {
  value = {
    (module.audit.account_id) : {
      "name" : module.audit.account_name,
      "email" : module.audit.account_email
    },

    (module.bastion.account_id) : {
      "name" : module.bastion.account_name,
      "email" : module.bastion.account_email
    },

    (module.production.account_id) : {
      "name" : module.production.account_name,
      "email" : module.production.account_email
    },
  }
}
