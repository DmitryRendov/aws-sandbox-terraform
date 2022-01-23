module "atlantis-lb" {
  source = "../../../modules/base/ec2-alb/v1"

  subnet_ids = ["subnet-0a928d26804414903", "subnet-04bd0a8b3d23efaa0"] #data.terraform_remote_state.networking.public_subnet_ids
  #  security_group_ids = 
  name   = "atlantis-alb"
  vpc_id = "vpc-05839da360c2ed2a9" #data.terraform_remote_state.networking.vpc_id

  #  target_groups = [
  #    {
  #      name        = "atlantis-ecs"
  #      protocol    = "HTTP"
  #      port        = 80
  #      target_type = "ip"
  #      health_check = {
  #        interval            = 30
  #        path                = "/heathz"
  #        port                = "traffic-port"
  #        healthy_threshold   = 3
  #        unhealthy_threshold = 3
  #        timeout             = 6
  #        protocol            = "HTTP"
  #        matcher             = "200-399"
  #      }
  #    }
  #  ]

  listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    #    {
    #      port               = 443
    #      protocol           = "HTTPS"
    #      certificate_arn    = ?
    #      target_group_index = 0
    #    }
  ]
  label = module.alb_label
}