output "nginx_instance_id" {
  description = "Instance ID of the Nginx server"
  value       = aws_instance.nginx.id
}

output "app_instance_id" {
  description = "Instance ID of the application server"
  value       = aws_instance.app.id
}

output "nginx_public_ip" {
  description = "Public IP of the Nginx reverse proxy"
  value       = aws_instance.nginx.public_ip
}

output "nginx_private_ip" {
  description = "Private IP of the Nginx reverse proxy"
  value       = aws_instance.nginx.private_ip
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = aws_instance.app.private_ip
}
