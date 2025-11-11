# -------------------------------
# Security Group for EC2s
# -------------------------------
resource "aws_security_group" "ec2_sg" {
  name   = var.is_public ? "public-ec2-sg" : "private-ec2-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.is_public ? toset(["22","80"]) : toset(["22"])
    content {
      from_port   = tonumber(ingress.value)
      to_port     = tonumber(ingress.value)
      protocol    = "tcp"
      cidr_blocks = var.is_public ? ["0.0.0.0/0"] : ["10.0.0.0/16"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# EC2 Instances
# -------------------------------
resource "aws_instance" "ec2_instances" {
  count                       = length(var.subnet_ids)
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index]
  key_name                    = var.key_name
  associate_public_ip_address = var.is_public
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

  tags = {
    Name = var.is_public ? "public-ec2-${count.index+1}" : "private-ec2-${count.index+1}"
  }
}

# -------------------------------
# Public EC2 setup (install proxy)
# -------------------------------
resource "null_resource" "public_setup" {
  count = var.is_public ? length(var.subnet_ids) : 0

  triggers = {
    instance_id = aws_instance.ec2_instances[count.index].id
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.root}/fares_key.pem")
      host        = aws_instance.ec2_instances[count.index].public_ip
    }
  }
}

# -------------------------------
# Private EC2 setup (via Bastion)
# -------------------------------
resource "null_resource" "private_setup" {
  count = var.is_public ? 0 : length(var.subnet_ids)

  triggers = {
    instance_id = aws_instance.ec2_instances[count.index].id
  }

  # Copy application file
  provisioner "file" {
    source      = "${path.root}/app/app.py"
    destination = "/home/ec2-user/app.py"

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("${path.root}/fares_key.pem")
      host                = aws_instance.ec2_instances[count.index].private_ip
      bastion_host        = var.bastion_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file("${path.root}/fares_key.pem")
    }
  }

  # Install Python/Flask and run app in background
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3 python3-pip",
      "pip3 install --user flask",
      "nohup python3 /home/ec2-user/app.py > /home/ec2-user/app.log 2>&1 &"
    ]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("${path.root}/fares_key.pem")
      host                = aws_instance.ec2_instances[count.index].private_ip
      bastion_host        = var.bastion_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file("${path.root}/fares_key.pem")
    }
  }
}

