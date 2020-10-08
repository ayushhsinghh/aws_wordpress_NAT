#To launch instance with wordpress and mysql
resource "aws_instance" "wordpress" {
  ami                         = var.wordpress_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.allow_wp.id]
  key_name                    = var.Key_Name
  tags = {
    Name = "wordpress"
  }
}

resource "aws_instance" "mysql" {
  ami                    = var.mysql_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.PrivateSubnet.id
  vpc_security_group_ids = [aws_security_group.allow_sql.id]
  key_name               = var.Key_Name
  tags = {
    Name = "mysql"
  }
}

output "wordpress_dns" {
  value = aws_instance.wordpress.public_ip
}

