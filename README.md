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

```text
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

```text
python_todo_app/
├── .github/
│   └── workflows/
│       └── build.yml           # GitHub Actions CI/CD pipeline
├── backend/                    # Flask application
│   ├── app.py
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── requirements.txt
│   └── schema.sql
├── frontend/                   # Nginx reverse proxy
│   ├── Dockerfile
│   └── index.html
├── k8s/                        # Kubernetes manifests (Phase 4)
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── mysql-deployment.yaml
│   ├── mysql-pv.yaml
│   ├── mysql-pvc.yaml
│   ├── configmap.yaml
│   ├── aws-secret.yaml
│   └── secret.yaml
├── my-app/                     # Helm chart for ArgoCD (Phase 6)
│   ├── templates/
│   │   ├── backend-deployment.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── mysql_deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-service.yaml
│   │   ├── mysql-service.yaml
│   │   ├── configmap.yaml
│   │   ├── mysql-init-configmap.yaml
│   │   ├── mysql-pvc.yaml
│   │   ├── backend-networkpolicy.yaml
│   │   ├── mysql-networkpolicy.yaml
│   │   ├── backend-role.yaml
│   │   ├── backend-rolebinding.yaml
│   │   └── serviceaccount.yaml
│   ├── Chart.yaml
│   └── values.yaml
├── eks-project/                # EKS + Terraform (Phase 5)
│   ├── eks.tf
│   ├── main.tf
│   ├── vpc.tf
│   ├── variables.tf
│   └── outputs.tf
├── terraform/                  # AWS infrastructure (Phase 3)
│   ├── main.tf
│   ├── provider.tf
│   ├── outputs.tf
│   └── variables.tf
└── docker-compose.yml          # Local multi-service setup (Phase 1)
```

---

## 📦 Phases

### Phase 1 — Docker Compose

Containerized the 3-tier Todo application (Flask backend, Nginx frontend, MySQL database) using Docker Compose with persistent storage and inter-service networking.

**Key implementations:**

* Multi-container setup with Docker Compose
* Nginx reverse proxy for routing frontend → backend
* MySQL persistent volume for data durability
* AWS Secrets Manager integration via IAM instance profile and entrypoint.sh
* Trivy image vulnerability scanning

**Run locally:**

```bash
docker-compose up -d
```

---

### Phase 2 — GitHub Actions CI/CD

Built an automated CI/CD pipeline triggered on every push to main.

**Pipeline stages:**

* Docker image build with run-number tagging
* Trivy security scan — blocks build on CRITICAL vulnerabilities (exit code 1)
* Push to DockerHub (jananibalan/todo-backend, jananibalan/todo-frontend)
* SSH deployment to EC2

**Workflow file:** `.github/workflows/build.yml`

**Notable decisions:**

* Run number tagging instead of latest to prevent stale image deployments
* CRITICAL-only Trivy threshold to avoid blocking on low-severity findings in base images
* EBS volume resized from 8GB → 20GB to handle image layer storage on EC2

---

### Phase 3 — Terraform on AWS

Provisioned AWS infrastructure using Terraform following modular, least-privilege principles.

**Resources provisioned:**

* VPC with public subnet, internet gateway, route tables
* EC2 instance with security groups
* IAM role and instance profile for Secrets Manager access
* AWS Secrets Manager for database credentials

**Run:**

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Notable decisions:**

* Secrets Manager used instead of environment variables — credentials never stored in code
* IAM role scoped to Secrets Manager read-only access (least privilege)
* Terraform state managed locally (`.gitignore` excludes *.tfstate)

---

### Phase 4 — Kubernetes on Minikube

Deployed the 3-tier application to a local Minikube cluster using Kubernetes manifests.

**Deploy:**

```bash
kubectl apply -f k8s/
kubectl get pods -n default
```

**Notable decisions:**

* ConfigMap vs Secret distinction — environment-specific config in ConfigMap, credentials in Secret
* CrashLoopBackOff resolved by injecting AWS credentials via aws-secret.yaml
* MySQL init script delivered via ConfigMap to handle schema creation on first boot

---

### Phase 5 — EKS + Helm on AWS

Deployed the application to AWS EKS using Terraform and Helm.

**Infrastructure (eks-project/):**

* EKS cluster with managed node group (t3.micro)
* VPC with private/public subnets, NAT gateway
* IAM roles for EKS service account (IRSA)
* MySQL deployed with PersistentVolume on EKS

**Deploy:**

```bash
cd eks-project
terraform init
terraform apply

aws eks update-kubeconfig --region ap-south-1 --name <cluster-name>
helm upgrade --install my-app ./my-app -n my-app --create-namespace
```

**Notable decisions:**

* t3.micro ENI pod limits handled by optimizing pod count
* Helm enables version-controlled deployments
* PersistentVolume ensures MySQL durability

---

### Phase 6 — GitOps with ArgoCD

Implemented GitOps workflow using ArgoCD.

**Setup:**

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl port-forward svc/argocd-server -n argocd 9090:443

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

**Application configuration:**

* Repository: your GitHub repo
* Chart path: `my-app`
* Namespace: `my-app`
* Sync: Automated (Prune + Self-Heal)

**Validation:**

* Replica change → auto sync
* Manual change → auto revert

**Security:**

* RBAC
* NetworkPolicy
* ServiceAccount

**Debugging resolved:**

* Helm path issues
* NodePort errors
* Namespace mismatch
* Sync loop issues

---

## 🔐 Security Practices

* Secrets via AWS Secrets Manager and Kubernetes Secrets — never hardcoded
* Trivy scanning blocks CRITICAL vulnerabilities
* IAM least privilege
* RBAC restrictions
* NetworkPolicy enforcement
* `.gitignore` excludes sensitive files

---

## ⚙️ Key Engineering Decisions

| Decision                     | Reasoning                                                                  |
| ---------------------------- | -------------------------------------------------------------------------- |
| MySQL on PV (EKS)            | ENI pod limits handled by optimizing pod count; retained DB inside cluster |
| ArgoCD in separate namespace | Isolates GitOps tooling                                                    |
| Helm for packaging           | Enables environment-specific overrides                                     |
| Run-number Docker tags       | Prevents stale deployments                                                 |
| NodePort for Minikube        | Required for local access                                                  |

---

## 👤 Author

**Sri Janani C B**
DevOps Engineer | Bangalore, India

LinkedIn · GitHub
