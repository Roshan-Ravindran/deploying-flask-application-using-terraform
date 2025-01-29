
resource "aws_instance" "ubuntu" {
  ami = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_22_5000.id]
  user_data                   = file("provide.yaml")
}

