# Easy Start Script for Minikube + Argo CD GitOps Project
# Just run this one script to set up a complete zero-cost GitOps environment
# No cloud costs or complex setup required

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
$MINIKUBE_MEMORY = 4096  # Memory in MB
$MINIKUBE_CPUS = 2       # Number of CPUs
$ARGOCD_PORT = 8080      # Port for Argo CD UI
$NGINX_PORT = 8090       # Port for NGINX demo app

# -----------------------------------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------------------------------
function Write-Step {
    param([string]$Message)
    Write-Host "`n➡️ $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "   $Message" -ForegroundColor Gray
}

function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function New-DirectoryIfNotExists {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Invoke-FileDownload {
    param([string]$Url, [string]$OutputPath)
    Write-Info "Downloading from $Url..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Success "Download complete"
    }
    catch {
        Write-Error "Failed to download file: $_"
        exit 1
    }
}

# -----------------------------------------------------------------------------
# WELCOME MESSAGE
# -----------------------------------------------------------------------------
Clear-Host
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                                                     ║" -ForegroundColor Magenta
Write-Host "║   🚀 Minikube + Argo CD GitOps - Easy Installer    ║" -ForegroundColor Magenta
Write-Host "║                                                     ║" -ForegroundColor Magenta
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host "  Zero-cost local Kubernetes with GitOps workflow" -ForegroundColor Yellow
Write-Host "  Just sit back and relax - we'll set up everything for you!" -ForegroundColor Yellow
Write-Host ""

# -----------------------------------------------------------------------------
# PREREQUISITES CHECK
# -----------------------------------------------------------------------------
Write-Step "Checking prerequisites"

# 1. Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Info "This script is not running as Administrator"
    Write-Info "Some operations might require admin privileges"
}

# 2. Check for Docker
Write-Info "Checking for Docker..."
try {
    docker version | Out-Null
    Write-Success "Docker is installed and running"
} 
catch {
    Write-Error "Docker is not installed or not running"
    Write-Host "`nPlease install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host "After installing Docker Desktop, restart your computer and run this script again." -ForegroundColor Yellow
    exit 1
}

# -----------------------------------------------------------------------------
# SETUP WORKING DIRECTORY
# -----------------------------------------------------------------------------
Write-Step "Setting up tool directory"
$toolsDir = "$env:USERPROFILE\.minikube-argocd"
New-DirectoryIfNotExists $toolsDir
$env:PATH += ";$toolsDir"
Write-Success "Tools directory created: $toolsDir"

# -----------------------------------------------------------------------------
# DOWNLOAD AND INSTALL TOOLS
# -----------------------------------------------------------------------------
Write-Step "Setting up required tools"

# 1. Minikube
$minikubePath = "$toolsDir\minikube.exe"
if (-not (Test-Path $minikubePath)) {
    Write-Info "Minikube not found, downloading..."
    Invoke-FileDownload -Url "https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe" -OutputPath $minikubePath
} else {
    Write-Success "Minikube already installed"
}

# 2. kubectl
$kubectlPath = "$toolsDir\kubectl.exe"
if (-not (Test-Path $kubectlPath)) {
    Write-Info "kubectl not found, downloading..."
    Invoke-FileDownload -Url "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe" -OutputPath $kubectlPath
} else {
    Write-Success "kubectl already installed"
}

# 3. Helm
$helmPath = "$toolsDir\helm.exe"
if (-not (Test-Path $helmPath)) {
    Write-Info "Helm not found, downloading..."
    $helmZipPath = "$env:TEMP\helm.zip"
    $helmExtractPath = "$env:TEMP\helm"
    Invoke-FileDownload -Url "https://get.helm.sh/helm-v3.12.0-windows-amd64.zip" -OutputPath $helmZipPath
    
    # Extract Helm
    Expand-Archive -Path $helmZipPath -DestinationPath $helmExtractPath -Force
    Copy-Item "$helmExtractPath\windows-amd64\helm.exe" $helmPath -Force
    
    # Clean up
    Remove-Item -Path $helmZipPath -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $helmExtractPath -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Success "Helm already installed"
}

# -----------------------------------------------------------------------------
# START MINIKUBE
# -----------------------------------------------------------------------------
Write-Step "Starting Minikube"
Write-Info "This may take a few minutes..."

try {
    # Check if minikube is already running
    $minikubeStatus = & $minikubePath status --format={{.Host}} 2>$null
    
    if ($minikubeStatus -eq "Running") {
        Write-Success "Minikube is already running"
    } else {
        # Start minikube with Docker driver
        & $minikubePath start --cpus=$MINIKUBE_CPUS --memory=$MINIKUBE_MEMORY --driver=docker --addons=ingress
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to start Minikube"
            exit 1
        }
        Write-Success "Minikube started successfully"
    }
} catch {
    Write-Error "Error starting Minikube: $_"
    exit 1
}

# -----------------------------------------------------------------------------
# INSTALL ARGO CD
# -----------------------------------------------------------------------------
Write-Step "Installing Argo CD"

# 1. Create argocd namespace
Write-Info "Creating namespace for Argo CD..."
& $kubectlPath create namespace argocd 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Info "Namespace argocd already exists"
}

# 2. Add Helm repo and install Argo CD
Write-Info "Setting up Helm repository..."
& $helmPath repo add argo https://argoproj.github.io/argo-helm 2>$null
& $helmPath repo update

Write-Info "Installing Argo CD (this may take a few minutes)..."
& $helmPath install argocd argo/argo-cd --namespace argocd

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install Argo CD"
    exit 1
}

# 3. Wait for Argo CD to be ready
Write-Info "Waiting for Argo CD to start..."
$maxRetries = 30
$retryCount = 0
$argocdReady = $false

while (-not $argocdReady -and $retryCount -lt $maxRetries) {
    $retryCount++
    $deployment = & $kubectlPath -n argocd get deployment argocd-server -o jsonpath="{.status.readyReplicas}" 2>$null
    
    if ($deployment -eq "1") {
        $argocdReady = $true
    } else {
        Write-Info "Waiting for Argo CD server to be ready... (Attempt $retryCount/$maxRetries)"
        Start-Sleep -Seconds 10
    }
}

if (-not $argocdReady) {
    Write-Error "Argo CD did not become ready in the expected time"
    Write-Host "You may need to wait a bit longer before accessing the Argo CD UI." -ForegroundColor Yellow
} else {
    Write-Success "Argo CD is up and running"
}

# 4. Get the Argo CD admin password
$ARGOCD_PASSWORD = & $kubectlPath -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

if (-not $ARGOCD_PASSWORD) {
    Write-Error "Failed to retrieve Argo CD admin password"
} else {
    Write-Success "Retrieved Argo CD admin password"
}

# -----------------------------------------------------------------------------
# SETUP PORT FORWARDING FOR ARGO CD
# -----------------------------------------------------------------------------
Write-Step "Setting up port forwarding for Argo CD"

# Kill any existing port-forward on the same port
Get-NetTCPConnection -LocalPort $ARGOCD_PORT -ErrorAction SilentlyContinue | ForEach-Object { 
    Stop-Process -Id (Get-Process -Id $_.OwningProcess).Id -Force -ErrorAction SilentlyContinue 
}

# Start port forwarding in the background
Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command & '$kubectlPath' port-forward svc/argocd-server -n argocd ${ARGOCD_PORT}:443"
Write-Success "Port forwarding set up for Argo CD UI at https://localhost:$ARGOCD_PORT"

# -----------------------------------------------------------------------------
# DEPLOY DEMO APPLICATION
# -----------------------------------------------------------------------------
Write-Step "Deploying NGINX demo application"

# Apply NGINX manifests directly first to ensure they're immediately available
Write-Info "Deploying NGINX manifests directly..."
& $kubectlPath apply -f ./apps/nginx/
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to apply NGINX manifests"
} else {
    Write-Success "NGINX manifests applied successfully"
}

# Apply the Argo CD application definition for GitOps management
Write-Info "Setting up GitOps with Argo CD..."
& $kubectlPath apply -f ./apps/argo-app.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to apply Argo CD application"
} else {
    Write-Success "Argo CD application defined successfully"
}

# Kill any existing port-forward on the same port for NGINX
Get-NetTCPConnection -LocalPort $NGINX_PORT -ErrorAction SilentlyContinue | ForEach-Object { 
    Stop-Process -Id (Get-Process -Id $_.OwningProcess).Id -Force -ErrorAction SilentlyContinue 
}

# Setup port forwarding for NGINX
Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command & '$kubectlPath' port-forward svc/nginx ${NGINX_PORT}:80"
Write-Success "Port forwarding set up for NGINX demo app at http://localhost:$NGINX_PORT"
Write-Info "   This zero-cost local setup replaces the AWS implementation that would cost $70-90/month"

# -----------------------------------------------------------------------------
# SUCCESS AND INSTRUCTIONS
# -----------------------------------------------------------------------------
Write-Host "`n╔═════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                     ║" -ForegroundColor Green
Write-Host "║   🎉 Your GitOps environment is ready to use!       ║" -ForegroundColor Green
Write-Host "║                                                     ║" -ForegroundColor Green
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 Argo CD Dashboard" -ForegroundColor Yellow
Write-Host "   URL:      https://localhost:$ARGOCD_PORT" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: $ARGOCD_PASSWORD" -ForegroundColor White
Write-Host "   Note: Your browser may warn about the self-signed certificate - this is normal" -ForegroundColor Gray

Write-Host "`n🌐 NGINX Demo Application" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:$NGINX_PORT" -ForegroundColor White

Write-Host "`n🔄 Making Changes (GitOps Workflow)" -ForegroundColor Yellow
Write-Host "   1. Edit files in the 'apps/nginx' directory" -ForegroundColor White
Write-Host "   2. Commit and push to your Git repository" -ForegroundColor White
Write-Host "   3. Argo CD will automatically detect and apply changes" -ForegroundColor White

Write-Host "`n💡 Useful Commands" -ForegroundColor Yellow
Write-Host "   Check Minikube status:  .\$toolsDir\minikube.exe status" -ForegroundColor White
Write-Host "   List running pods:      .\$toolsDir\kubectl.exe get pods" -ForegroundColor White
Write-Host "   Stop Minikube:          .\$toolsDir\minikube.exe stop" -ForegroundColor White
Write-Host "   Delete everything:      .\$toolsDir\minikube.exe delete" -ForegroundColor White

Write-Host "`nPress any key to open the Argo CD Dashboard in your browser, or Ctrl+C to exit" -ForegroundColor Magenta
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open browser to Argo CD UI
Start-Process "https://localhost:$ARGOCD_PORT"

# Also open NGINX demo app
Start-Process "http://localhost:$NGINX_PORT"
