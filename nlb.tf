resource "aws_lb_target_group" "nlb-tg" {
    vpc_id = aws_vpc.dev.id
    name = "nlbtg"
    protocol="TCP"
    port="8080"
    # health_check {
    # enabled             = true
    # port                = 8080
    # interval            = 30
    # protocol            = "TCP"
    # matcher             = "200"
    # healthy_threshold   = 3
    # }
    tags = {
      "Name" = "${var.vpc_name}-tg"
    }
}

resource "aws_lb_target_group_attachment" "nlbattach" {
  target_group_arn = aws_lb_target_group.nlb-tg.arn
  target_id = aws_instance.privateserver.id
}

resource "aws_lb" "nlb" {
  load_balancer_type = "network"
  name = "priyanlb"
  subnets = [aws_subnet.publicsubnet[0].id,aws_subnet.publicsubnet[1].id]
  internal = false
  security_groups = [aws_security_group.sg.id]
}

resource "aws_lb_listener" "nlbcommunications" {
  port = "80"
  protocol = "TCP"
  load_balancer_arn = aws_lb.nlb.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nlb-tg.arn
  }
}