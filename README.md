# Zero-Cost GitOps with Minikube + Argo CD

<div align="center">

![Minikube + Argo CD](https://miro.medium.com/v2/resize:fit:679/1*6e7R8cGWL5lqCMxIiApR2g.png)

A simple, zero-cost Kubernetes GitOps environment you can run on your laptop.

[![Argo CD](https://img.shields.io/badge/GitOps-Argo_CD-EF7B4D?style=flat-square&logo=argo&logoColor=white)](https://argoproj.github.io/argo-cd/)
[![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)

</div>

## Table of Contents

- [Introduction to GitOps](#gitops-simply-explained)
- [Prerequisites](#prerequisites)
- [Installation Options](#installation-options)
- [System Architecture](#system-architecture)
- [Scripts Explained](#scripts-explained)
- [Environment Components](#environment-components)
- [Usage Guide](#usage-guide)
- [Troubleshooting](#troubleshooting)
- [Cleaning Up](#cleaning-up)
- [Further Resources](#further-resources)

## GitOps Simply Explained

### What Is This Project?

Imagine if your computer applications could update themselves automatically whenever you make changes. That's what this project does! Here's how it works in plain language:

#### 🚀 The Super Simple Explanation

1. **You write code** and save it to GitHub (like saving a document to Dropbox)
2. **The robot (Argo CD) watches** your GitHub for any changes
3. **When you change something**, the robot automatically updates your application

#### 💰 Zero-Cost vs. Cloud Costs

This project runs on your laptop and costs **absolutely nothing**. The same setup in the cloud (AWS) would cost approximately $70-90 per month!

#### 🔄 How It Works (Visual Explanation)

```
You → Make Changes → GitHub → Argo CD → Application Updates
                                   ↑
                                   | 
                             Runs on your laptop
                             (Not in expensive cloud!)
```

#### 🛠️ What You're Actually Learning

- **Version Control**: Keeping track of all changes to your application
- **Automation**: Making updates happen without manual work
- **Containers**: Running applications in standardized packages
- **Kubernetes**: A system for managing those containers

That's it! No complicated jargon needed. This project lets you learn powerful enterprise tools without spending a penny.

## Prerequisites

Before starting, ensure you have:

1. **Windows 10/11** with PowerShell 5.1 or later
2. **Docker Desktop** installed and running ([download link](https://www.docker.com/products/docker-desktop/))
3. **Administrator privileges** (some operations require elevated privileges)
4. **Internet connection** (to download tools and container images)
5. **At least 8GB RAM** available on your system (4GB dedicated to Minikube)
6. **At least 10GB free disk space** for Docker images and Kubernetes resources

## Installation Options

This project provides multiple installation methods to accommodate different user preferences and environments:

### Option 1: One-Click Setup (Recommended for Beginners)

The easiest way to get started is with our automatic installer script:

```powershell
# Run this command to set up everything automatically
powershell -ExecutionPolicy Bypass -File .\easy-start.ps1
```

**What this does:**
- Checks for prerequisites (Docker, etc.)
- Creates a dedicated tools directory at `$env:USERPROFILE\.minikube-argocd`
- Downloads and installs Minikube, kubectl, and Helm
- Starts a local Kubernetes cluster
- Installs Argo CD
- Deploys a sample NGINX application
- Sets up port forwarding for all services
- Opens browser windows to access the applications

### Option 2: Manual Setup with Chocolatey (Alternative Approach)

If you prefer to use the Chocolatey package manager:

```powershell
# Install Chocolatey if not already installed
# See https://chocolatey.org/install for instructions

# Install required tools through Chocolatey
powershell -ExecutionPolicy Bypass -File .\local-setup.ps1
```

**What this does:**
- Uses Chocolatey to install Minikube, kubectl, and Helm
- Sets up the environment similar to Option 1
- Requires Chocolatey to be pre-installed

### Option 3: Direct Kubernetes Setup

For users who already have Minikube or a local Kubernetes cluster:

```powershell
# Apply the configurations directly to an existing Kubernetes cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f ./apps/argo-app.yaml
```

## System Architecture

Understanding how the components work together is essential for troubleshooting and customization.

### Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      Your Local Machine                         │
│                                                                 │
│  ┌─────────────┐         ┌──────────────────────────────────┐  │
│  │             │         │ Docker Desktop                   │  │
│  │  Git Repo   │         │                                  │  │
│  │  (Source)   │         │  ┌────────────────────────────┐  │  │
│  │             │         │  │ Minikube                   │  │  │
│  │  - Config   │         │  │                            │  │  │
│  │  - YAML     │ watches │  │  ┌──────────┐   ┌───────┐  │  │  │
│  │  - Apps     │◄────────┼──┼──┤ Argo CD  │   │ NGINX │  │  │  │
│  │             │         │  │  └──────────┘   └───────┘  │  │  │
│  └─────────────┘         │  │                            │  │  │
│                          │  └────────────────────────────┘  │  │
│                          │                                  │  │
│                          └──────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Component Relationships

1. **Docker Desktop** provides the container runtime environment
2. **Minikube** creates a local Kubernetes cluster within Docker
3. **Argo CD** runs inside Minikube and monitors your Git repository
4. **NGINX** demo application is deployed and managed by Argo CD
5. **Port forwarding** exposes services to your local machine

## Scripts Explained

This project includes several PowerShell scripts, each serving a specific purpose:

### `easy-start.ps1` - The All-in-One Installer

This is the primary setup script recommended for most users. It:

- **Creates a tools directory** at `$env:USERPROFILE\.minikube-argocd`
- **Downloads and installs** Minikube, kubectl, and Helm without requiring Chocolatey
- **Configures and starts** Minikube with appropriate resource allocation
- **Installs Argo CD** via Helm chart
- **Deploys the demo NGINX application**
- **Sets up port forwarding** for all services
- **Opens browser windows** to access the applications
- **Provides detailed status messages** throughout the process

### `local-setup.ps1` - Chocolatey-Based Setup

An alternative setup script that:

- **Uses Chocolatey** to install required tools (assumes Chocolatey is already installed)
- **Offers a simpler script** with fewer checks and fallbacks
- **Provides the same end result** but with a different installation approach
- **May require additional setup** if Chocolatey isn't already installed

### `direct-setup.ps1` - Kubernetes-Only Setup

For users who already have a functioning Kubernetes environment and only want to install Argo CD:

- **Assumes Kubernetes is already available** and properly configured
- **Skips Minikube setup** entirely
- **Installs only Argo CD and demo application** components

### `setup.ps1` - Legacy Setup Script

An older setup script maintained for backward compatibility:

- **Combines features** from the other scripts
- **Not recommended** for new users (use `easy-start.ps1` instead)

## Environment Components

### 1. Argo CD Dashboard

![Argo CD Dashboard](https://miro.medium.com/v2/resize:fit:1400/1*Nj8X-TzjvQiJ7fDI_Q7sTg.png)

**Purpose**: The main control panel for your GitOps workflow
- **URL**: https://localhost:8080
- **Username**: admin
- **Password**: Automatically generated (displayed during setup and in the console)
- **Capabilities**:
  - View application sync status
  - Trigger manual syncs when needed
  - View application health and deployment details
  - Access logs and events for troubleshooting
  - Visualize your application's resource hierarchy

#### Accessing Argo CD

1. Open your browser to [https://localhost:8080](https://localhost:8080)
2. You may see a certificate warning (this is normal for local development)
3. Log in with username `admin` and the password displayed during setup
4. If you forgot the password, retrieve it with:
   ```powershell
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object {[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}
   ```

### 2. Demo NGINX Application

**Purpose**: A sample application managed by GitOps
- **URL**: http://localhost:8090
- **Source Code**: Located in `apps/nginx/` directory
- **Configuration**:
  - `configmap.yaml`: Contains HTML content that you can modify
  - `deployment.yaml`: Defines how the application is deployed
  - `service.yaml`: Defines how the application is exposed

#### Modifying the Demo Application

The demo application is designed to demonstrate GitOps principles. To see changes:

1. Edit the HTML content in `apps/nginx/configmap.yaml`
2. Commit and push your changes to your Git repository
3. Argo CD will detect the change and automatically update the application
4. Refresh your browser to see the changes

## Usage Guide

### Daily Development Workflow

Once your environment is set up, follow this workflow for development:

1. **Make code changes**:
   ```powershell
   # Edit files in your repository
   code ./apps/nginx/configmap.yaml
   ```

2. **Commit and push changes**:
   ```powershell
   git add .
   git commit -m "Update NGINX content"
   git push
   ```

3. **View changes in Argo CD**:
   - Go to [https://localhost:8080](https://localhost:8080)
   - Select your application
   - View the sync status (should automatically sync within 3 minutes)
   - If needed, click "Sync" to manually trigger a sync

4. **View your application**:
   - Go to [http://localhost:8090](http://localhost:8090) to see your changes

### Adding New Applications

To add a new application to your GitOps workflow:

1. **Create application manifests**: Add Kubernetes YAML files to your repository
2. **Create an Argo CD application definition**:
   ```yaml
   # Example: my-new-app.yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: my-new-app
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/yourusername/your-repo.git
       targetRevision: HEAD
       path: apps/my-new-app
     destination:
       server: https://kubernetes.default.svc
       namespace: default
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
   ```

3. **Apply the application definition**:
   ```powershell
   kubectl apply -f my-new-app.yaml
   ```

## Troubleshooting

### Common Issues and Solutions

#### 1. Docker Desktop Not Running

**Symptoms**:
- Error messages about Docker not being available
- Minikube fails to start

**Solution**:
1. Start Docker Desktop
2. Ensure virtualization is enabled in your BIOS
3. Restart the setup script

#### 2. Port Conflicts

**Symptoms**:
- Error messages about ports 8080 or 8090 being in use
- Services not accessible in browser

**Solution**:
1. Identify and stop applications using those ports:
   ```powershell
   # Find processes using port 8080
   netstat -ano | findstr :8080
   # Kill the process using the identified PID
   taskkill /F /PID <PID>
   ```
2. Modify the scripts to use different ports:
   - Edit `easy-start.ps1` and change `$ARGOCD_PORT` and `$NGINX_PORT`

#### 3. Insufficient Resources

**Symptoms**:
- Minikube fails to start or crashes
- Applications unstable or slow

**Solution**:
1. Increase resources allocated to Minikube:
   - Edit `easy-start.ps1` and increase `$MINIKUBE_MEMORY` and `$MINIKUBE_CPUS`
2. Close other resource-intensive applications
3. Restart your computer

#### 4. Certificate Warnings

**Symptoms**:
- Browser warnings about invalid certificates when accessing Argo CD

**Solution**:
- This is normal for local development with self-signed certificates
- Click "Advanced" and "Proceed to localhost" in your browser
- Or use the `--insecure` flag with kubectl port-forward

#### 5. Sync Issues

**Symptoms**:
- Changes not appearing in your application
- Argo CD shows sync errors

**Solution**:
1. Check Argo CD UI for specific error messages
2. Validate your YAML files for syntax errors
3. Manually trigger a sync in the Argo CD UI
4. Check logs:
   ```powershell
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
   ```

### Getting Detailed Logs

For troubleshooting deeper issues, collect logs from various components:

```powershell
# Minikube logs
minikube logs

# Argo CD application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# NGINX application logs
kubectl logs -n default -l app=nginx
```

## Cleaning Up

When you're finished using the environment, clean up resources to free system resources:

### Full Cleanup

```powershell
# Stop Minikube
$env:PATH += ";$env:USERPROFILE\.minikube-argocd"
minikube stop
minikube delete

# Remove port forwarding (find and stop PowerShell processes running kubectl port-forward)
Get-Process -Name powershell | Where-Object {$_.CommandLine -like "*port-forward*"} | Stop-Process
```

### Temporary Suspension

If you want to pause the environment but keep your configuration:

```powershell
# Just stop Minikube without deleting
$env:PATH += ";$env:USERPROFILE\.minikube-argocd"
minikube stop
```

## Further Resources

To learn more about the technologies used in this project:

### Documentation

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)

### Tutorials

- [GitOps with Argo CD](https://www.youtube.com/watch?v=0WAm0y2vLIo) (YouTube video)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Introduction to Docker](https://docs.docker.com/get-started/)

### Community

- [Argo CD GitHub Repository](https://github.com/argoproj/argo-cd)
- [Kubernetes Community](https://kubernetes.io/community/)
- [Docker Community](https://www.docker.com/community/)

---

Enjoy your zero-cost GitOps environment! Perfect for learning, testing, and experimentation. If you encounter any issues not covered in this documentation, please open an issue on the repository.
