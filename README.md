ECS Three-Tier Application Deployment on AWS using Terraform

A production-style three-tier web application deployed on AWS using Terraform and Amazon ECS Fargate, with a CloudFront CDN edge layer, an Application Load Balancer, and a PostgreSQL RDS backend — all provisioned end-to-end as Infrastructure as Code.

Browser → CloudFront → ALB → ECS (Frontend / Backend) → PostgreSQL RDS


Table of Contents


Project Overview
Architecture
Technology Stack
Features
AWS Services Used
Repository Structure
Prerequisites
Security Design
Terraform Backend Setup
Networking Design
Deployment Guide
Docker Build & Push
ECS Deployment & Redeployment
Verification
Terraform Outputs
Accessing the Application
Troubleshooting Journey
Useful Terraform Commands
Cost Optimization
Future Improvements
Interview Learnings
Resume Highlights
Lessons Learned
Author



Project Overview

This project demonstrates how to design, provision, and operate a real three-tier architecture on AWS using Terraform as the single source of truth for infrastructure. It covers networking, container orchestration, CDN delivery, database provisioning, secrets management, and observability — the same building blocks used in production-grade cloud deployments.

The goal isn't just "infrastructure that works" — it's infrastructure that is modular, secure by default, and reproducible, with every resource defined in version-controlled Terraform code rather than created manually in the AWS console.


Architecture

                              ┌─────────────┐
                              │   Browser   │
                              └──────┬──────┘
                                     │ HTTPS
                                     ▼
                              ┌─────────────┐
                              │ CloudFront  │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │     ALB     │
                              └──────┬──────┘
                                     │
                  ┌──────────────────┴──────────────────┐
                  │                                      │
                  ▼                                      ▼
          ┌──────────────┐                       ┌──────────────┐
          │ Frontend ECS │                       │ Backend ECS  │
          │   Fargate    │                       │   Fargate    │
          └──────────────┘                       └──────┬───────┘
                                                          │
                                                          ▼
                                                 ┌────────────────┐
                                                 │ PostgreSQL RDS │
                                                 └────────────────┘

Traffic flow: the browser hits CloudFront (the public edge), which forwards requests to the ALB. The ALB performs path-based routing — / goes to the frontend service, /api/* goes to the backend service. The backend service is the only component permitted to reach the RDS database, which lives in a private subnet with no public exposure.


Technology Stack

LayerTechnologyInfrastructure as CodeTerraformCloud ProviderAWSContainer RuntimeDockerContainer RegistryAmazon ECRContainer OrchestrationAmazon ECS (Fargate)CDNCloudFrontLoad BalancingApplication Load BalancerDatabasePostgreSQL (RDS)Secrets ManagementAWS Secrets ManagerLogging & MonitoringCloudWatch LogsNetworkingVPC, NAT Gateway, IGWRemote StateS3 + DynamoDB


Features


✅ Infrastructure as Code using modular Terraform

✅ Serverless container orchestration via ECS Fargate (no EC2 to manage)

✅ CloudFront CDN for global caching, HTTPS, and DDoS mitigation

✅ Application Load Balancer with path-based routing

✅ PostgreSQL RDS in a private subnet, reachable only from the backend

✅ Centralized secrets via AWS Secrets Manager — no hardcoded credentials

✅ Centralized logging via CloudWatch

✅ Defense-in-depth network isolation (public/private subnets, scoped security groups)

✅ Remote Terraform state with S3 backend + DynamoDB state locking



AWS Services Used

VPC 
Public/Private Subnets
Internet Gateway 
NAT Gateway 
Route Tables 
Security Groups
ECR 
ECS Fargate 
ALB 
CloudFront 
RDS (PostgreSQL) 
IAM 
CloudWatch Logs 
Secrets Manager 
S3 (Terraform backend) 
DynamoDB (state locking)


Repository Structure

ecs-terraform-aws-project

│
├── backend-setup/            # Bootstraps the S3 + DynamoDB remote state backend

│
├── provider.tf
├── variables.tf
├── main.tf


│
├── environments/

│   └── dev/

│       ├── backend.tf

│       ├── main.tf

│       ├── outputs.tf

│       ├── provider.tf

│       ├── variables.tf

│       └── versions.tf
│


├── modules/

│   ├── alb/

│   ├── cloudfront/

│   ├── cloudwatch/

│   ├── ecr/

│   ├── ecs/

│   ├── iam/

│   ├── rds/

│   ├── secrets-manager/

│   ├── security/

│   └── vpc/

│
├── .gitignore

└── README.md


Prerequisites

AWS Account


An AWS account with an IAM user/role that has sufficient permissions
AWS CLI installed and configured


bashaws sts get-caller-identity

Region

This project is tested in us-east-1.

bashaws configure

Required Tooling

ToolMinimum VersionCheckTerraform>= 1.6terraform versionAWS CLIlatestaws --versionDockerlatestdocker --versionGitlatestgit --version


Security Design

Security is enforced in layers, with each tier only able to reach the tier directly below it.

Layer 1 — CloudFront
Public entry point. Terminates HTTPS at the edge, distributes traffic globally, and adds a layer of DDoS protection in front of the origin.

Layer 2 — Application Load Balancer
Receives traffic only from CloudFront. Routes requests to the frontend or backend service based on path.

Layer 3 — ECS Services


Frontend ECS — accepts traffic only from the ALB security group.
Backend ECS — accepts traffic only from the ALB security group (optionally also the frontend security group, if server-to-server calls are needed).


Layer 4 — Database
RDS accepts inbound traffic only from the backend ECS security group, on port 5432. It is never reachable from the public internet.

Security GroupPortAllowed FromALB80, 4430.0.0.0/0Frontend ECS8080ALB security groupBackend ECS8080ALB security group (+ optionally frontend SG)RDS5432Backend ECS security group


Terraform Backend Setup

Remote state is stored in S3, with DynamoDB providing state locking to prevent concurrent, conflicting applies.

hclterraform {
  backend "s3" {
    bucket         = "YOUR_BUCKET"
    key            = "ecs-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

Why this matters:


State is protected from local loss or corruption
Multiple engineers can collaborate safely
DynamoDB locking prevents two apply operations from racing each other
State history supports recovery if something goes wrong



Networking Design

ComponentCIDR / PurposeVPC10.0.0.0/16Public SubnetsHost the ALB and NAT GatewayPrivate SubnetsHost frontend ECS, backend ECS, and RDSInternet GatewayProvides internet access to public-subnet resourcesNAT GatewayLets private-subnet resources (ECS tasks) reach the internet outbound — e.g. pulling images from ECR, downloading dependencies — without being publicly reachable inbound


Deployment Guide

bash# 1. Clone the repository
git clone https://github.com/MuhammadJaffar52/ecs-terraform-aws-project.git
cd ecs-terraform-aws-project/environments/dev

# 2. Initialize Terraform
terraform init

# 3. Validate configuration
terraform validate

# 4. Format code (optional, keeps style consistent)
terraform fmt -recursive

# 5. Review the execution plan
terraform plan

# 6. Apply the infrastructure
terraform apply


⏱ Expected deployment time: ~15–25 minutes.




Docker Build & Push

Authenticate to ECR

bashaws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

Frontend

bashdocker build -t frontend ./frontend
docker tag frontend:latest ECR_FRONTEND_URI:latest
docker push ECR_FRONTEND_URI:latest

Backend

bashdocker build -t backend ./backend
docker tag backend:latest ECR_BACKEND_URI:latest
docker push ECR_BACKEND_URI:latest


ECS Deployment & Redeployment

After pushing new images, force ECS to roll out the updated version:

bash# Frontend
aws ecs update-service \
  --cluster ecs-three-tier-dev-cluster \
  --service ecs-three-tier-dev-frontend-service \
  --force-new-deployment

# Backend
aws ecs update-service \
  --cluster ecs-three-tier-dev-cluster \
  --service ecs-three-tier-dev-backend-service \
  --force-new-deployment


Verification

bash# Check service status
aws ecs describe-services --cluster ecs-three-tier-dev-cluster

# Check running tasks
aws ecs list-tasks --cluster ecs-three-tier-dev-cluster

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN

Expected target health status: healthy


Terraform Outputs

bashterraform output

textalb_dns_name       = ecs-three-tier-dev-alb-1541470015.us-east-1.elb.amazonaws.com
cloudfront_domain  = dxxxxxxxxxxxx.cloudfront.net
vpc_id             = vpc-091543e0975171b83


Accessing the Application

EndpointURLALB (frontend)http://ALB_DNS_NAMEALB (backend API)http://ALB_DNS_NAME/apiHealth checkhttp://ALB_DNS_NAME/api/healthCloudFront (production)https://YOUR_CLOUDFRONT_DOMAIN


✅ Recommended: use the CloudFront URL for production-style access — it provides HTTPS, caching, and edge protection that hitting the ALB directly does not.




Troubleshooting Journey

Real issues encountered (and fixed) during this build.

Incident 1 — Backend Target Group Unhealthy

Symptoms

RunningCount = 0
FailedTasks increasing
Target registration loop

Root cause
The ALB health check path was set to /, but the backend only exposes a health endpoint at /health.

Fix

hclhealth_check {
  path = "/health"
}


Incident 2 — Target.DeregistrationInProgress

Symptoms
Tasks were continuously being replaced; the ALB could never establish a stable healthy target.

Root cause
The backend security group did not allow inbound traffic from the ALB security group on port 8080, so health checks silently failed.

Fix
Added an ingress rule on the backend security group allowing traffic from the ALB security group on port 8080.


Incident 3 — ECS Deployment Loop

Symptoms

FailedTasks increasing
RunningCount = 0

Root cause
A combination of the two issues above — failing health checks meant ECS kept killing and replacing tasks before they could stabilize.

Resolution


Fixed the ALB health check path
Fixed the backend security group ingress rule
Confirmed the backend /health endpoint returned 200 OK



Incident 4 — Backend Not Directly Reachable

Symptoms
Backend service unreachable when accessed directly.

Root cause
Backend tasks are intentionally deployed in private subnets with no public IP — this is by design, not a bug.

Resolution
Access the backend only through ALB path-based routing via /api/*, never directly.


Useful Terraform Commands

bashterraform init          # Initialize backend & providers
terraform validate      # Validate configuration syntax
terraform fmt -recursive # Auto-format all .tf files
terraform plan           # Preview changes
terraform apply          # Apply changes
terraform output         # Show output values
terraform state list     # List all resources in state
terraform destroy        # Tear down all infrastructure


Cost Optimization

The biggest cost contributors in this stack, roughly in order:


NAT Gateway — billed hourly + per GB processed, even when idle
ECS Fargate — billed per vCPU/memory while tasks are running
RDS — billed continuously while the instance exists
CloudFront — pay-per-use, generally low for dev/test traffic
ALB — billed hourly + per LCU



⚠️ Always destroy resources when not actively using them:

bashterraform destroy




Future Improvements


 Custom domain via Route 53
 ACM-managed TLS certificates
 Enforce HTTPS-only on the ALB
 ECS Service Auto Scaling (target tracking)
 AWS WAF in front of CloudFront
 CI/CD pipeline via GitHub Actions
 Blue/Green deployments (CodeDeploy or ECS native)
 Multi-AZ RDS for high availability
 CloudWatch dashboards + alarms



Interview Learnings

Questions this project is good preparation for:


What is ECS Fargate, and how is it different from EC2-backed ECS?
Why put CloudFront in front of an ALB?
What's the difference between ALB and CloudFront?
Why is a NAT Gateway required for private-subnet resources?
Why deploy ECS tasks and RDS in private subnets?
How does ALB path-based routing work?
What is a Target Group, and how does target health work?
What is Secrets Manager, and why not just use environment variables?
How does the backend ECS service securely connect to RDS?
How does Terraform remote state work, and why use it?
How does Terraform state locking prevent conflicts?
How would you troubleshoot unhealthy ECS targets behind an ALB?
What's the difference between a Security Group and a NACL?
How do ECS deployments work under the hood (task definitions, revisions, rolling updates)?
What causes Target.DeregistrationInProgress, and how do you fix it?



Resume Highlights


Designed and deployed a production-style three-tier architecture on AWS using Terraform.
Implemented ECS Fargate workloads behind an Application Load Balancer with path-based routing.
Configured CloudFront CDN for secure, low-latency content delivery.
Integrated Amazon RDS (PostgreSQL) with AWS Secrets Manager for credential management.
Built reusable, modular Terraform infrastructure (VPC, ECS, ALB, RDS, IAM, CloudFront).
Diagnosed and resolved real ECS health check, target group, and security group misconfigurations.



Lessons Learned

Hands-on experience gained through this project:


Designing modular, reusable Terraform infrastructure
Operating ECS Fargate in a multi-service architecture
Configuring CloudFront as a CDN layer in front of an ALB
Securing RDS with private subnets and scoped security groups
Managing secrets without hardcoding credentials
Centralizing logs and metrics via CloudWatch
Diagnosing real networking and health-check failures in a live AWS environment
Managing Terraform remote state safely across a team workflow
