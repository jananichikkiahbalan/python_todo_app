# End-to-End DevOps Pipeline with GitOps, Kubernetes & AWS

A production-grade DevOps project demonstrating containerization, CI/CD automation, infrastructure as code, Kubernetes orchestration, and GitOps — built progressively across 6 phases using a Python Todo application as the base workload.

---

## 🚀 Tech Stack

* **Cloud**: AWS (EKS, EC2, IAM, VPC)
* **IaC**: Terraform
* **Containers**: Docker
* **Orchestration**: Kubernetes, Helm
* **CI/CD**: GitHub Actions
* **GitOps**: ArgoCD
* **Security**: Trivy, IAM, Kubernetes RBAC, Network Policies

---

## 🏗️ Architecture Overview

```
Developer Push
     │
     ▼
┌─────────────────────────────────────────┐
│           GitHub Actions CI/CD          │
│  Build → Trivy Scan → Push to DockerHub │
│  Updates container images in repository │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│         ArgoCD (GitOps)                 │
│  Watches repository (Helm charts +      │
│  manifests) → Auto Sync                 │
│  Self-heal · Prune · Drift Detection    │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│       Kubernetes Cluster                │
│  Frontend (Nginx) · Backend (Flask)     │
│  Database (MySQL) · RBAC · NetworkPolicy│
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│         AWS Infrastructure              │
│  EKS · EC2 · VPC · IAM                  │
│  Provisioned via Terraform              │
└─────────────────────────────────────────┘
```

**Note:** Kubernetes deployments are performed on both Minikube (local) and AWS EKS (cloud) across different phases. GitHub Actions pushes container images to DockerHub; ArgoCD then syncs the desired state from the same repository containing Helm charts and manifests.

---

## 📁 Project Structure

```
python_todo_app/
├── .github/
│   └── workflows/
│       └── build.yml
├── backend/
│   ├── app.py
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── requirements.txt
│   └── schema.sql
├── frontend/
│   ├── Dockerfile
│   └── index.html
├── k8s/
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── mysql-deployment.yaml
│   ├── mysql-pv.yaml
│   ├── mysql-pvc.yaml
│   ├── configmap.yaml
│   ├── aws-secret.yaml
│   └── secret.yaml
├── my-app/
│   ├── templates/
│   ├── Chart.yaml
│   └── values.yaml
├── eks-project/
│   ├── eks.tf
│   ├── main.tf
│   ├── vpc.tf
│   ├── variables.tf
│   └── outputs.tf
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── outputs.tf
│   └── variables.tf
└── docker-compose.yml
```

---

## 📦 Phases

### Phase 1 — Docker Compose

* Multi-container setup with Docker Compose
* Nginx reverse proxy for routing frontend → backend
* MySQL persistent volume for data durability
* AWS Secrets Manager integration via IAM
* Trivy image vulnerability scanning

```bash
docker-compose up -d
```

---

### Phase 2 — GitHub Actions CI/CD

* Docker image build with run-number tagging
* Trivy scan (blocks CRITICAL vulnerabilities)
* Push images to DockerHub
* SSH deployment to EC2

**Notable decisions:**

* Avoided `latest` tag
* CRITICAL-only vulnerability threshold
* Increased EBS storage

---

### Phase 3 — Terraform on AWS

* VPC, EC2, IAM, Secrets Manager
* Least privilege IAM roles
* Secure secret handling

```bash
cd terraform
terraform init
terraform apply
```

---

### Phase 4 — Kubernetes (Minikube)

* Deployments, Services, PV, PVC
* ConfigMap & Secrets separation
* NetworkPolicy & RBAC

```bash
kubectl apply -f k8s/
```

---

### Phase 5 — EKS + Helm

* EKS cluster via Terraform
* Helm-based deployment
* MySQL with PersistentVolume

```bash
helm upgrade --install my-app ./my-app -n my-app --create-namespace
```

---

### Phase 6 — GitOps with ArgoCD

* ArgoCD monitors repo
* Auto-sync enabled
* Self-healing + drift correction

**Validation:**

* Replica changes auto-synced
* Manual changes reverted

---

## 🔐 Security Practices

* Secrets via AWS Secrets Manager & Kubernetes Secrets
* Trivy scanning in CI/CD
* IAM least privilege
* RBAC & Network Policies
* Sensitive files excluded via `.gitignore`

---

## ⚙️ Key Engineering Decisions

| Decision                     | Reasoning                                                                  |
| ---------------------------- | -------------------------------------------------------------------------- |
| MySQL on PV (EKS)            | Handled ENI pod limits by optimizing pod count; retained DB inside cluster |
| ArgoCD in separate namespace | Isolates GitOps tooling                                                    |
| Helm for packaging           | Enables environment-specific configs                                       |
| Run-number Docker tags       | Prevents stale deployments                                                 |
| NodePort for Minikube        | Required for local external access                                         |

---

## 👤 Author

**Sri Janani C B**
DevOps Engineer | Bangalore, India

---
