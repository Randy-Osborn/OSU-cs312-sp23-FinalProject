terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_security_group" "minecraft" {
  ingress {
    description = "Receive SSH from home."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.96.245.19/32"]
  }
  ingress {
    description = "Receive Minecraft from everywhere."
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Send everywhere."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Minecraft"
  }
}

resource "aws_key_pair" "mcFinal" {
  key_name   = "mcFinal"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjBngzWuHE824G/5KKjaE8HPR7uc4fM10dd5Vk8MFfTm1+zMVUpcY+igYEyn/JdShXdKM+CSX2BeAqHTpbd1RMi+D3OAZZpu7DpNqlXglb39romCTV60iDBQhfQDyok146zgKuJ9wnvjN4tdLZTSWDlP8qcFuA+PU6KLqbU87MXceGKEvgIY5s31Q++SMSPkW0DFJd7W35etfuDUeiwp4vTNIGj+2N99yj9alz0MAnnPBBrHyGxAfAcyJl9ZCjt28sj8ygtGgDnkONthoLejlr1vdy7xFli3cgwDWA3XGa6U7YynfUYpdoqg9XZq4m2/Mfc53kOmTJZjgO6DcPERbg/WhipuFtuilpNUehj73Wq5IP43j1ePtupZ6Oj/u7QgEoC90xHLqonjbGTr2Qti3WcjtyzD/7cKVACU2aStH4HTrmMhtw5rV+eHTBZhwPUbYwqeBSEI2TOXd+k0GD34OYzfgMTELlkiWuhqnF3bE2bbIG6XMD+xOMrzlFAEz0D8f5V2dtZBIVwakqOv9o22MTYp8rF45kw87kbWhormym/7DJXvUlUK2RIFQNzDhNfovyjyB9Fj3hooq9kUUd/o7+qfiqqHrGknt13uU77OehlpBN/fAOxPi1We8YcEUmvGiF+AnhxkhfGQxMhMWmFoSAta6KP0X3MC/aezD7NM06lw== 15037@DESKTOP-A1U5DV9"

}

resource "aws_instance" "minecraft" {
  ami                         = "ami-01acac09adf473073"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.mcFinal.key_name
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum -y update
    sudo rpm --import https://yum.corretto.aws/corretto.key
    sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
    sudo yum install -y java-17-amazon-corretto-devel.x86_64
    wget -O server.jar https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar
    java -Xmx1024M -Xms1024M -jar server.jar nogui
    sed -i 's/eula=false/eula=true/' eula.txt
    java -Xmx1024M -Xms1024M -jar server.jar nogui
    EOF
  tags = {
    Name = "Minecraft"
  }
}

output "instance_ip_addr" {
  value = aws_instance.minecraft.public_ip
}
