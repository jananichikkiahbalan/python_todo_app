**End-to-End DevOps Pipeline with GitOps, Kubernetes & AWS**

A production-grade DevOps project demonstrating containerization, CI/CD automation, infrastructure as code, Kubernetes orchestration, and GitOps — built progressively across 6 phases using a Python Todo application as the base workload.

**Tech Stack**

**Cloud:** AWS (EKS, EC2, IAM, VPC)
**IaC:** Terraform
**Containers:** Docker
**Orchestration:** Kubernetes, Helm
**CI/CD:** GitHub Actions
**GitOps:** ArgoCD
**Security:** Trivy, IAM, Kubernetes RBAC, Network Policies


**Architecture Overview**

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
│  EKS · EC2 · VPC · IAM                 │
│  Provisioned via Terraform              │
└─────────────────────────────────────────┘

**Note:** Kubernetes deployments are performed on both Minikube (local) and AWS EKS (cloud) across different phases. GitHub Actions pushes container images to DockerHub; ArgoCD then syncs the desired state from the same repository containing Helm charts and manifests.


**Project Structure**

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

**Phases**
**Phase 1 — Docker Compose**

Containerized the 3-tier Todo application (Flask backend, Nginx frontend, MySQL database) using Docker Compose with persistent storage and inter-service networking.

**Key implementations:**

Multi-container setup with Docker Compose
Nginx reverse proxy for routing frontend → backend
MySQL persistent volume for data durability
AWS Secrets Manager integration via IAM instance profile and entrypoint.sh
Trivy image vulnerability scanning

**Run locally:**
docker-compose up -d

**Phase 2 — GitHub Actions CI/CD**
Built an automated CI/CD pipeline triggered on every push to main.

**Pipeline stages:**

Docker image build with run-number tagging
Trivy security scan — blocks build on CRITICAL vulnerabilities (exit code 1)
Push to DockerHub (jananibalan/todo-backend, jananibalan/todo-frontend)
SSH deployment to EC2

**Workflow file:** .github/workflows/build.yml

**Notable decisions:**

Run number tagging instead of latest to prevent stale image deployments
CRITICAL-only Trivy threshold to avoid blocking on low-severity findings in base images
EBS volume resized from 8GB → 20GB to handle image layer storage on EC2


**Phase 3 — Terraform on AWS**
Provisioned AWS infrastructure using Terraform following modular, least-privilege principles.
**Resources provisioned:**

VPC with public subnet, internet gateway, route tables
EC2 instance with security groups
IAM role and instance profile for Secrets Manager access
AWS Secrets Manager for database credentials

**Run:**
cd terraform
terraform init
terraform plan
terraform apply

**Notable decisions:**

Secrets Manager used instead of environment variables — credentials never stored in code
IAM role scoped to Secrets Manager read-only access (least privilege)
Terraform state managed locally (.gitignore excludes *.tfstate)


**Phase 4 — Kubernetes on Minikube**
Deployed the 3-tier application to a local Minikube cluster using 8 Kubernetes manifest files.
**Manifests:**
FilePurposebackend-deployment.yamlFlask app deployment + ClusterIP servicefrontend-deployment.yamlNginx deployment + NodePort servicemysql-deployment.yamlMySQL stateful deploymentmysql-pv.yamlPersistent Volume (hostPath)mysql-pvc.yamlPersistent Volume Claimconfigmap.yamlNon-sensitive app configurationaws-secret.yamlAWS credentials as Kubernetes Secretsecret.yamlMySQL credentials as Kubernetes Secret
**Deploy:**
bashkubectl apply -f k8s/
kubectl get pods -n default

**Notable decisions:**

ConfigMap vs Secret distinction — environment-specific config in ConfigMap, credentials in Secret
CrashLoopBackOff resolved by injecting AWS credentials via aws-secret.yaml
MySQL init script delivered via ConfigMap to handle schema creation on first boot


**Phase 5 — EKS + Helm on AWS**
Deployed the application to AWS EKS using Terraform for cluster provisioning and Helm for application packaging.

**Infrastructure (eks-project/):**

EKS cluster with managed node group (t3.micro)
VPC with private/public subnets, NAT gateway
IAM roles for EKS service account (IRSA)
MySQL deployed with PersistentVolume on EKS

**Deploy:**
cd eks-project
terraform init
terraform apply

aws eks update-kubeconfig --region ap-south-1 --name <cluster-name>
helm upgrade --install my-app ./my-app -n my-app --create-namespace

**Notable decisions:**

t3.micro nodes hit VPC CNI ENI pod density limits — resolved by optimizing pod count; MySQL retained on cluster with PersistentVolume
Helm chart enables repeatable, version-controlled releases across environments
PersistentVolume ensures MySQL data durability across pod restarts on EKS


**Phase 6 — GitOps with ArgoCD**
Implemented a complete GitOps workflow using ArgoCD on Minikube, where Git is the single source of truth for cluster state.

**Setup:**
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access UI
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
  
**ArgoCD Application configuration:**

**Repository**: https://github.com/jananichikkiahbalan/python_todo_app
**Chart path:** my-app
**Target namespace:** my-app
**Sync policy:** Automated with Prune and Self-Heal enabled

**GitOps validation performed:**

Updated replica count in values.yaml → pushed to GitHub → ArgoCD auto-synced cluster
Manually scaled a deployment → ArgoCD self-healed back to desired state within seconds

**Security implemented:**

**RBAC:** Role and RoleBinding scoped to backend service account
**NetworkPolicy:** Restricts inter-pod communication — only frontend → backend → MySQL traffic allowed
**ServiceAccount:** Dedicated service account for backend workload

**Notable debugging resolved:**

Incorrect Helm chart path in ArgoCD application config
NodePort out-of-range errors in service manifests
Namespace mismatch between ArgoCD app config and manifest target
Continuous sync loop caused by Helm label annotations being rewritten on every sync


**Security Practices**

Secrets managed via AWS Secrets Manager and Kubernetes Secrets — never hardcoded
Trivy scanning in CI/CD blocks builds with CRITICAL vulnerabilities
IAM roles follow least-privilege principle
Kubernetes RBAC restricts service account permissions
NetworkPolicy enforces strict inter-service traffic rules
.gitignore excludes *.tfstate, *.tfstate.backup, sensitive credential files

Author
Sri Janani C B
DevOps Engineer | Bangalore, India


