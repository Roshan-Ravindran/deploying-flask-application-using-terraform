
output "Web-link" {
  value = "http://${aws_instance.ubuntu.public_ip}:5000"
}