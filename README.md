# Zero-Cost GitOps with Minikube + Argo CD

<div align="center">

![Minikube + Argo CD](https://miro.medium.com/v2/resize:fit:679/1*6e7R8cGWL5lqCMxIiApR2g.png)

A simple, zero-cost Kubernetes GitOps environment you can run on your laptop.

[![Argo CD](https://img.shields.io/badge/GitOps-Argo_CD-EF7B4D?style=flat-square&logo=argo&logoColor=white)](https://argoproj.github.io/argo-cd/)
[![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)

</div>

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

## One-Click Setup

**Just download and run a single script!**

### Step 1: Install Docker Desktop

If you don't already have Docker Desktop installed, download and install it from:
[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

### Step 2: Run the Easy Installer

```powershell
# Run this one command to set up everything
powershell -ExecutionPolicy Bypass -File .\easy-start.ps1
```

**That's it!** The script will:
- Install all required tools automatically
- Set up a local Kubernetes cluster using Minikube
- Deploy Argo CD for GitOps automation
- Create a demo web application
- Open browser windows to access everything

## What You'll Get

### 1. Argo CD Dashboard

![Argo CD Dashboard](https://miro.medium.com/v2/resize:fit:1400/1*Nj8X-TzjvQiJ7fDI_Q7sTg.png)

- **URL**: https://localhost:8080
- **Username**: admin
- **Password**: Displayed during setup and in the console

### 2. Demo Web Application

- **URL**: http://localhost:8090
- A sample NGINX application deployed using GitOps

## For Absolute Beginners

This project demonstrates how modern applications are deployed using GitOps:

1. **What is GitOps?** A way to manage your applications where:
   - All your application code lives in Git
   - Changes automatically sync to your running applications
   - Everything is version-controlled and traceable

2. **What's Included?**
   - **Kubernetes**: A platform for running containerized applications
   - **Minikube**: A small version of Kubernetes that runs on your laptop
   - **Argo CD**: The tool that watches Git and updates your applications

## How to Use It

### Making Changes

Want to see GitOps in action? Try this:

1. Edit the HTML content in `apps/nginx/configmap.yaml`
2. Commit and push your changes
3. Watch Argo CD automatically detect and apply the change

### Cleaning Up

When you're done, you can clean up everything with two simple commands:

```powershell
$env:PATH += ";$env:USERPROFILE\.minikube-argocd"
minikube.exe stop
minikube.exe delete
```

## Why This Project?

- **Zero Cloud Costs**: Everything runs locally on your laptop
- **Learn DevOps Tools**: Get hands-on with the same tools used in enterprise environments
- **Simple to Use**: One script sets up everything

---

Enjoy your zero-cost GitOps environment! Perfect for learning, testing, and experimentation.
