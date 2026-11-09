# devops-pucrs-fase1

![CI Pipeline](https://github.com/jrdiiaas/devops-pucrs-fase1/actions/workflows/ci.yml/badge.svg)

Projeto desenvolvido para a **Fase 1 (Configuração e Automação Inicial)** da disciplina **DevOps na Prática (PUCRS)**, contemplando uma API RESTful em Python/Flask containerizada com Docker, pipeline de Integração Contínua (CI) no GitHub Actions e provisionamento de Infraestrutura como Código (IaC) na AWS utilizando HashiCorp Terraform.

---

## Estrutura do Repositório

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml          # Pipeline de CI (Build, Flake8, Pytest, Terraform Validate e Docker)
├── app/
│   ├── __init__.py         # Inicialização do pacote Python
│   └── main.py             # API Flask (/health e /calcular/<a>/<b>)
├── iac/
│   ├── main.tf             # Recursos AWS (VPC, Subnet, IGW, SG, ECR, ECS e EC2 com Docker)
│   ├── outputs.tf          # Outputs da infraestrutura (VPC ID, ECR URL e IP público EC2)
│   └── variables.tf        # Variáveis parametrizadas (região, nome do projeto e tipo EC2)
├── tests/
│   └── test_main.py        # Testes unitários automatizados com Pytest
├── Dockerfile              # Definição da imagem Docker de produção (Python 3.11 + Gunicorn)
├── requirements.txt        # Dependências do projeto com versões fixadas
└── README.md               # Documentação técnica do projeto
```

---

## Como Executar Localmente

### 1. Instalar dependências e rodar testes
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Análise estática (Lint)
flake8 app/ tests/

# Testes unitários automatizados
python -m pytest -v
```

### 2. Executar com Docker
```bash
docker build -t devops-pucrs-api:latest .
docker run -d --name api-test -p 5000:5000 devops-pucrs-api:latest
curl http://localhost:5000/health
```

### 3. Validar e Provisionar Infraestrutura (Terraform)
```bash
cd iac
terraform init
terraform validate
terraform plan
```
