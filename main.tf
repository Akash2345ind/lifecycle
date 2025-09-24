provider "aws" {
  region = "us-east-1"
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "aws_subnet" "first_subnet" {
  id = data.aws_subnets.default_subnets.ids[0]
}
resource "aws_security_group" "Demo_SG" {
  vpc_id = data.aws_vpc.default.id
  name   = "Demo_SG"
  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "jenkins on 8080"
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbound"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "Demo_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.first_subnet.id
  vpc_security_group_ids      = [aws_security_group.Demo_SG.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Demo"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install unzip net-tools curl git
    sudo apt install docker.io -y
    sudo systemctl enable docker && sudo systemctl start docker
    sudo apt install -y openjdk-17-jdk
    java -version
    curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
      /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian binary/ | sudo tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
    # Install
    sudo apt update
    sudo apt install jenkins -y
    sudo usermod -aG docker jenkins
    sudo systemctl restart jenkins
    sudo systemctl enable jenkins && sudo systemctl start jenkins
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    curl -LO "https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/   
    kubectl version --client
    EOF
}
variable "ami" {
  default = "ami-053b0d53c279acc90"
}
variable "instance_type" {
  default = "t2.large"
}
variable "key_name" {
  default = "ekskey"
}
output "instance_publicIP" {
  value = aws_instance.Demo_instance.public_ip
}
output "jenkins_url" {
  value = "http://${aws_instance.Demo_instance.public_ip}:8080"
}
