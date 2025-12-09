

data "aws_ami" "ubuntu" {
     most_recent = true
     owners = ["099720109477"]
     filter { 
    name="name"
     values=["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] 
     } 
     }

resource "aws_security_group" "app_sg" {
  name = "${var.environment}-app-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.47.0.0/16"] # allow from VPC or ALB SG
  }
  egress { 
    from_port=0
    to_port=0 
    protocol="-1" 
    cidr_blocks=["0.0.0.0/0"] 
    }
}

# Launch template with user_data differentiating nginx1/nginx2 via instance index
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

user_data = base64encode(
  templatefile("${path.module}/userdata.sh", {
    environment = var.environment
  })
)
}


resource "aws_autoscaling_group" "app_asg" {
  name                 = "${var.environment}-app-asg"
  launch_template { 
    
    id = aws_launch_template.app.id
    version = "$Latest" 
    }
  vpc_zone_identifier  = var.private_subns
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  target_group_arns    = [var.alb_tg_arn]
  

  lifecycle { create_before_destroy = true }
}
