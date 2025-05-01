# Minikube + Argo CD Setup Script
# This script sets up a local Kubernetes environment with Argo CD using Minikube
# Zero-cost local development - no cloud expenses

Write-Host "Setting up Minikube + Argo CD - Zero Cost GitOps Environment" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Download and install Minikube directly
Write-Host "Downloading and installing Minikube..." -ForegroundColor Cyan
$minikubeUrl = "https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe"
$minikubePath = "$env:USERPROFILE\.minikube\minikube.exe"

# Create .minikube directory if it doesn't exist
if (-not (Test-Path "$env:USERPROFILE\.minikube")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.minikube" | Out-Null
}

# Download Minikube
Write-Host "  Downloading Minikube..." -ForegroundColor Gray
Invoke-WebRequest -Uri $minikubeUrl -OutFile $minikubePath

# Add Minikube to PATH for the current session
$env:PATH += ";$env:USERPROFILE\.minikube"

# Download and install kubectl directly
Write-Host "Downloading and installing kubectl..." -ForegroundColor Cyan
$kubectlUrl = "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
$kubectlPath = "$env:USERPROFILE\.minikube\kubectl.exe"

# Download kubectl
Write-Host "  Downloading kubectl..." -ForegroundColor Gray
Invoke-WebRequest -Uri $kubectlUrl -OutFile $kubectlPath

# Start minikube with Docker driver and enough resources
Write-Host "Starting Minikube with Docker driver..." -ForegroundColor Cyan
& $minikubePath start --cpus=2 --memory=4096 --driver=docker --addons=ingress

# Verify kubectl works
Write-Host "Verifying kubectl connection..." -ForegroundColor Cyan
& $kubectlPath version

# Create a namespace for Argo CD
Write-Host "Creating namespace for Argo CD..." -ForegroundColor Cyan
& $kubectlPath create namespace argocd

# Install Helm (manual method)
Write-Host "Setting up Helm for Argo CD installation..." -ForegroundColor Cyan
$helmUrl = "https://get.helm.sh/helm-v3.12.0-windows-amd64.zip"
$helmZipPath = "$env:TEMP\helm.zip"
$helmExtractPath = "$env:TEMP\helm"

# Download Helm
Write-Host "  Downloading Helm..." -ForegroundColor Gray
Invoke-WebRequest -Uri $helmUrl -OutFile $helmZipPath

# Extract Helm
Expand-Archive -Path $helmZipPath -DestinationPath $helmExtractPath -Force
Copy-Item "$helmExtractPath\windows-amd64\helm.exe" "$env:USERPROFILE\.minikube\helm.exe" -Force

# Install Argo CD using Helm
Write-Host "Installing Argo CD..." -ForegroundColor Cyan
& "$env:USERPROFILE\.minikube\helm.exe" repo add argo https://argoproj.github.io/argo-helm
& "$env:USERPROFILE\.minikube\helm.exe" repo update
& "$env:USERPROFILE\.minikube\helm.exe" install argocd argo/argo-cd --namespace argocd

# Wait for Argo CD to be ready
Write-Host "Waiting for Argo CD to start..." -ForegroundColor Cyan
& $kubectlPath wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get the Argo CD admin password
$PASSWORD = & $kubectlPath -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object {[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}
Write-Host "Argo CD admin password: $PASSWORD" -ForegroundColor Yellow

# Port-forward the Argo CD server to access it locally
Write-Host "Setting up port forwarding for Argo CD UI..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "& '$kubectlPath' port-forward svc/argocd-server -n argocd 8080:443"

# Apply the NGINX demo application
Write-Host "Deploying the NGINX demo application..." -ForegroundColor Cyan
& $kubectlPath apply -f ./apps/argo-app.yaml

# Instructions for accessing the applications
Write-Host "`n✓ Setup complete! Your zero-cost GitOps environment is ready." -ForegroundColor Green

Write-Host "`n📊 Access Argo CD Dashboard:" -ForegroundColor Magenta
Write-Host "   URL: https://localhost:8080" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: $PASSWORD" -ForegroundColor White
Write-Host "   Note: Your browser may warn about the self-signed certificate." -ForegroundColor Gray

Write-Host "`n🌐 Access the NGINX Demo Application:" -ForegroundColor Magenta
Write-Host "   1. Run: kubectl port-forward svc/nginx 8090:80" -ForegroundColor White
Write-Host "   2. Open browser to: http://localhost:8090" -ForegroundColor White

Write-Host "`n🔄 GitOps Workflow:" -ForegroundColor Magenta
Write-Host "   1. Make changes to app manifests in the 'apps/nginx' directory" -ForegroundColor White
Write-Host "   2. Commit and push changes to your Git repository" -ForegroundColor White
Write-Host "   3. Argo CD will automatically detect and apply the changes" -ForegroundColor White

Write-Host "`n🧹 When you're done:" -ForegroundColor Red
Write-Host "   & '$minikubePath' stop" -ForegroundColor White
Write-Host "   & '$minikubePath' delete" -ForegroundColor White
