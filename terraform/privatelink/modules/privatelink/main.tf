resource "aws_lb_target_group" "tg" {
  name     = "tg-advanced"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpcs["provider_vpc"].vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    protocol            = "TCP"
    port                = "80"
  }

  tags = { Name = "nlbTG" }
}


resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.private_instances["provider_vpc"].id
  port             = 80
}

resource "aws_lb" "nlb" {
  name                             = "NLB"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.vpcs["provider_vpc"].private_subnets
  enable_cross_zone_load_balancing = true

  tags = { Name = "NLB" }
}


resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_vpc_endpoint_service" "private_service" {
  network_load_balancer_arns = [aws_lb.nlb.arn]
  acceptance_required        = false

  tags = {
    Name = "PrivateServiceEndpoint"
  }
}

resource "aws_vpc_endpoint" "privatelink_endpoint" {
  vpc_id              = var.vpcs["consumer_vpc"].vpc_id
  service_name        = aws_vpc_endpoint_service.private_service.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpcs["consumer_vpc"].private_subnets
  private_dns_enabled = false
  security_group_ids  = [var.publicsg["consumer_vpc"].id]

  tags = {
    Name = "PrivateLinkEndpoint"
  }
}
