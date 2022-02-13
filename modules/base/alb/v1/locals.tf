locals {
  tagret_groups = merge(flatten([{
    for index, tg in var.target_groups :
    index => tg
    }
  ])...)

  target_group_attachments = merge(flatten([
    for index, group in var.target_groups : [
      for k, targets in group : {
        for target_key, target in targets : join(".", [index, target_key]) => merge({ tg_index = index }, target)
      }
      if k == "targets"
    ]
  ])...)

  listeners = merge(flatten([{
    for index, tg in var.listeners :
    index => tg
    }
  ])...)

  listener_rules = merge(flatten([{
    for index, tg in var.listener_rules :
    index => tg
    }
  ])...)
}
