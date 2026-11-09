variable "aws_region" {
  description = "Região da AWS para provisionamento dos recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome base para identificação dos recursos do projeto"
  type        = string
  default     = "devops-pucrs-fase1"
}

variable "instance_type" {
  description = "Tipo da instância EC2 para hospedar containers da aplicação"
  type        = string
  default     = "t3.micro"
}
