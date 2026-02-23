output "staging_public_ip" {
  value       = aws_instance.staging.public_ip
  description = "Public IP of staging instance (http://IP)"
}

output "staging_url" {
  value       = "http://${aws_instance.staging.public_ip}"
  description = "Direct access URL"
}
