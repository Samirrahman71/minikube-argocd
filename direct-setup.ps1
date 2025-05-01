# ArgoBox Direct Setup Script
# This script sets up a local Kubernetes environment with Argo CD using minikube and Docker
# No cloud costs - completely free for learning

Write-Host "Setting up ArgoBox locally with Minikube and Docker..." -ForegroundColor Green

# Download and install Minikube directly
Write-Host "Downloading and installing Minikube..." -ForegroundColor Green
$minikubeUrl = "https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe"
$minikubePath = "$env:USERPROFILE\.minikube\minikube.exe"

# Create .minikube directory if it doesn't exist
if (-not (Test-Path "$env:USERPROFILE\.minikube")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.minikube" | Out-Null
}

# Download Minikube
Invoke-WebRequest -Uri $minikubeUrl -OutFile $minikubePath

# Add Minikube to PATH for the current session
$env:PATH += ";$env:USERPROFILE\.minikube"

# Download and install kubectl directly
Write-Host "Downloading and installing kubectl..." -ForegroundColor Green
$kubectlUrl = "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
$kubectlPath = "$env:USERPROFILE\.minikube\kubectl.exe"

# Download kubectl
Invoke-WebRequest -Uri $kubectlUrl -OutFile $kubectlPath

# Start minikube with Docker driver and enough resources
Write-Host "Starting minikube with Docker driver..." -ForegroundColor Green
& $minikubePath start --cpus=2 --memory=4096 --driver=docker --addons=ingress

# Verify kubectl works
Write-Host "Verifying kubectl connection..." -ForegroundColor Green
& $kubectlPath version

# Create a namespace for Argo CD
Write-Host "Creating namespace for Argo CD..." -ForegroundColor Green
& $kubectlPath create namespace argocd

# Install Helm (manual method)
Write-Host "Downloading and installing Helm..." -ForegroundColor Green
$helmUrl = "https://get.helm.sh/helm-v3.12.0-windows-amd64.zip"
$helmZipPath = "$env:TEMP\helm.zip"
$helmExtractPath = "$env:TEMP\helm"

# Download Helm
Invoke-WebRequest -Uri $helmUrl -OutFile $helmZipPath

# Extract Helm
Expand-Archive -Path $helmZipPath -DestinationPath $helmExtractPath -Force
Copy-Item "$helmExtractPath\windows-amd64\helm.exe" "$env:USERPROFILE\.minikube\helm.exe" -Force

# Install Argo CD using Helm
Write-Host "Installing Argo CD..." -ForegroundColor Green
& "$env:USERPROFILE\.minikube\helm.exe" repo add argo https://argoproj.github.io/argo-helm
& "$env:USERPROFILE\.minikube\helm.exe" repo update
& "$env:USERPROFILE\.minikube\helm.exe" install argocd argo/argo-cd --namespace argocd

# Wait for Argo CD to be ready
Write-Host "Waiting for Argo CD to start..." -ForegroundColor Green
& $kubectlPath wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get the Argo CD admin password
$PASSWORD = & $kubectlPath -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object {[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}
Write-Host "Argo CD admin password: $PASSWORD" -ForegroundColor Yellow

# Port-forward the Argo CD server to access it locally
Write-Host "Setting up port forwarding for Argo CD UI..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", "& '$kubectlPath' port-forward svc/argocd-server -n argocd 8080:443"

# Apply the NGINX application from the repository
Write-Host "Applying the NGINX demo application..." -ForegroundColor Green
& $kubectlPath apply -f ./argobox/apps/argo-app.yaml

# Instructions for accessing the applications
Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`nAccess Argo CD at: https://localhost:8080" -ForegroundColor Cyan
Write-Host "Username: admin" -ForegroundColor Cyan
Write-Host "Password: $PASSWORD" -ForegroundColor Cyan
Write-Host "`nNote: Your browser may warn about the self-signed certificate. This is normal for local development." -ForegroundColor Yellow

# Add instructions for accessing the NGINX demo app
Write-Host "`nTo access the NGINX demo application:" -ForegroundColor Cyan
Write-Host "1. Wait for Argo CD to sync the application (check the Argo CD UI)" -ForegroundColor Cyan
Write-Host "2. Run this command to get the URL: & '$minikubePath' service nginx -n default" -ForegroundColor Cyan

Write-Host "`nTo clean up when you're done:" -ForegroundColor Red
Write-Host "& '$minikubePath' stop" -ForegroundColor Red
Write-Host "& '$minikubePath' delete" -ForegroundColor Red
