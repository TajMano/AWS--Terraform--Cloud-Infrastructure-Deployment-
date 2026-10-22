# Internet-facing ALB accepts HTTP for demonstration only.
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Public HTTP access to demo application load balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from the internet (demo only)"
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

# Web instances accept inbound HTTP only from the load balancer.
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  description = "Allow web traffic only from the application load balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound access for package installation"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
