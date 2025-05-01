# ArgoBox Local Setup Script
# This script sets up a local Kubernetes environment with Argo CD using minikube
# No cloud costs - completely free for learning

# Install required tools using Chocolatey
Write-Host "Installing required tools..." -ForegroundColor Green
choco install minikube kubernetes-cli kubernetes-helm -y

# Start minikube with enough resources
Write-Host "Starting minikube..." -ForegroundColor Green
minikube start --cpus=2 --memory=4096 --driver=docker --addons=ingress

# Create a namespace for Argo CD
Write-Host "Creating namespace for Argo CD..." -ForegroundColor Green
kubectl create namespace argocd

# Install Argo CD using Helm
Write-Host "Installing Argo CD..." -ForegroundColor Green
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace argocd

# Wait for Argo CD to be ready
Write-Host "Waiting for Argo CD to start..." -ForegroundColor Green
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get the Argo CD admin password
$PASSWORD = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | %{[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}
Write-Host "Argo CD admin password: $PASSWORD" -ForegroundColor Yellow

# Port-forward the Argo CD server to access it locally
Write-Host "Setting up port forwarding for Argo CD UI..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", "kubectl port-forward svc/argocd-server -n argocd 8080:443"

# Apply the NGINX application from the repository
Write-Host "Applying the NGINX demo application..." -ForegroundColor Green
kubectl apply -f ./argobox/apps/argo-app.yaml

# Instructions for accessing the applications
Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`nAccess Argo CD at: https://localhost:8080" -ForegroundColor Cyan
Write-Host "Username: admin" -ForegroundColor Cyan
Write-Host "Password: $PASSWORD" -ForegroundColor Cyan
Write-Host "`nNote: Your browser may warn about the self-signed certificate. This is normal for local development." -ForegroundColor Yellow

# Add instructions for accessing the NGINX demo app
Write-Host "`nTo access the NGINX demo application:" -ForegroundColor Cyan
Write-Host "1. Wait for Argo CD to sync the application (check the Argo CD UI)" -ForegroundColor Cyan
Write-Host "2. Run this command to get the URL: minikube service nginx -n default" -ForegroundColor Cyan

Write-Host "`nTo clean up when you're done:" -ForegroundColor Red
Write-Host "minikube stop" -ForegroundColor Red
Write-Host "minikube delete" -ForegroundColor Red
