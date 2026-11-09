# devops-pucrs-fase1 (Fases 1 e 2)

![CI/CD Pipeline](https://github.com/jrdiiaas/devops-pucrs-fase1/actions/workflows/ci.yml/badge.svg)

Projeto completo desenvolvido para as **Fases 1 e 2** da disciplina **DevOps na Prática (PUCRS)**, abrangendo:
- **Fase 1 (Configuração e Automação Inicial):** API RESTful em Python/Flask, Testes Unitários (`pytest`), Análise Estática (`flake8`), Containerização (`Dockerfile`) e Infraestrutura como Código na AWS (`Terraform`).
- **Fase 2 (Entrega Contínua, Monitoramento e Segurança):** Expansão para pipeline de **CI/CD** (`.github/workflows/ci.yml`), Análise de Segurança Estática **DevSecOps SAST** (`bandit`), Observabilidade e Logging Estruturado (`/metrics` e `/health`), Orquestração de Containers (`docker-compose.yml` e `ecs-task-definition.json`) e Scripts Automatizados de Deploy e Rollback (`scripts/deploy.sh` e `scripts/rollback.sh`).

---

## Estrutura do Repositório

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml                  # Esteira CI/CD completa (4 Jobs: Lint/SAST/Test, IaC, Docker/Compose e CD Deploy)
├── app/
│   ├── __init__.py                 # Inicialização do pacote Python
│   └── main.py                     # API Flask com logging estruturado (/health, /calcular/<a>/<b> e /metrics)
├── iac/
│   ├── main.tf                     # Recursos AWS (VPC, Subnet, IGW, SG, ECR, ECS e EC2 com deploy automático)
│   ├── outputs.tf                  # Outputs da infraestrutura (VPC ID, ECR URL e IP público EC2)
│   └── variables.tf                # Variáveis parametrizadas (região, nome do projeto e tipo EC2)
├── scripts/
│   ├── deploy.sh                   # Script de deploy automatizado em container com Smoke Test e integração ECR
│   └── rollback.sh                 # Script de rollback automático para a imagem estável anterior
├── tests/
│   └── test_main.py                # Suíte de testes automatizados (Pytest) para todos os endpoints
├── Dockerfile                      # Imagem Docker de produção (Python 3.11 + Gunicorn + HEALTHCHECK nativo)
├── docker-compose.yml              # Orquestração declarativa de containers com healthcheck e rotação de logs
├── ecs-task-definition.json        # Definição de tarefa para orquestração no Amazon ECS + CloudWatch Logs
├── requirements.txt                # Dependências fixadas (Flask, Pytest, Flake8, Gunicorn e Bandit)
└── README.md                       # Documentação técnica das Fases 1 e 2
```

---

## Como Executar Localmente

### 1. Instalar dependências, Lint, SAST e Testes
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Análise estática de padronização (Flake8)
flake8 app/ tests/

# Análise de segurança estática DevSecOps (Bandit SAST)
bandit -r app/ -ll

# Testes unitários automatizados (Pytest)
python -m pytest -v
```

### 2. Executar Containerização e Orquestração (Docker Compose / Scripts de Deploy)
```bash
# Subir via Docker Compose
docker compose up -d --build

# Ou executar o script completo de Entrega Contínua (CD) com Smoke Test e Rollback automático
bash scripts/deploy.sh latest
```

### 3. Validar e Provisionar Infraestrutura na AWS (Terraform)
```bash
cd iac
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```
