output "web_public_ip" {
 description = "Public IP of the web instance"
 value       = aws_instance.ubuntu.public_ip
}