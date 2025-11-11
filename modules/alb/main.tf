# Security Group for ALBs
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id   # <-- use VPC ID, not subnet

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Public ALB
resource "aws_lb" "public" {
  name               = "public-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

# Public Target Group
resource "aws_lb_target_group" "public_tg" {
  name        = "public-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

# Public Listener
resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

# Attach public EC2s to public TG
resource "aws_lb_target_group_attachment" "public_attach" {
  for_each = { for idx, id in var.public_targets : idx => id }

  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = each.value
  port             = 80
}

# Internal ALB
resource "aws_lb" "internal" {
  name               = "alb-internal-fixed"  # renamed
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

# Private Target Group
resource "aws_lb_target_group" "private_tg" {
  name        = "private-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

# Private Listener
resource "aws_lb_listener" "private_listener" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_tg.arn
  }
}

# Attach private EC2s to private TG
resource "aws_lb_target_group_attachment" "private_attach" {
  for_each = { for idx, id in var.private_targets : idx => id }

  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = each.value
  port             = 80
}
