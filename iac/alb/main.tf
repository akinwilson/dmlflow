resource "aws_lb" "main" {
  name                       = "${var.name}-alb-${var.environment}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.sg
  subnets                    = var.public_subnets.*.id
  enable_deletion_protection = false
  tags = {
    Name        = "${var.name}-alb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.name}-tg-${var.environment}"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = {
    Name        = "${var.name}-tg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  aws_acm_certificate_validation.main.certificate_arn
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = aws_lb.main.dns_name
  validation_method = "DNS"
  tags = {
    Name        = "${var.name}-ssl-cert-${var.environment}"
    Environment = var.environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}