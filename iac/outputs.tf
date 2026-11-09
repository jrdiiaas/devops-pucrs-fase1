output "vpc_id" {
  description = "ID da VPC provisionada"
  value       = aws_vpc.main.id
}

output "ecr_repository_url" {
  description = "URL do repositório de imagens Docker no Amazon ECR"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ec2_public_ip" {
  description = "Endereço IP público do servidor de aplicação"
  value       = aws_instance.app_server.public_ip
}
