
resource "aws_security_group" "bastion_sg" {
  name   = "${var.environment}-bastion-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict as needed
  }
  egress { 
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"] 
    }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnets[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = { Name = "${var.environment}-bastion" }
}

data "aws_ami" "ubuntu" {
     most_recent = true
     owners = ["099720109477"]
     filter { 
    name="name"
     values=["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] 
     } 
     }