# Launch template: Amazon Linux 2023, Nginx bootstrap, and two additional gp3 disks.
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = filebase64("${path.module}/scripts/install-env.sh")

  # These are ADDITIONAL data volumes; the AMI's root disk is separate.
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size           = var.ebs_volume_size_gib
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  block_device_mappings {
    device_name = "/dev/sdg"
    ebs {
      volume_size           = var.ebs_volume_size_gib
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${var.project_name}-web"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = local.common_tags
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = local.subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }

  lifecycle {
    precondition {
      condition     = var.asg_min_size >= 1 && var.asg_min_size <= var.asg_desired_capacity && var.asg_desired_capacity <= var.asg_max_size
      error_message = "Require 1 <= asg_min_size <= asg_desired_capacity <= asg_max_size."
    }
  }
}
