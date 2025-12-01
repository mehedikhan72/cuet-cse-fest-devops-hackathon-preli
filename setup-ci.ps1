#!/usr/bin/env pwsh
# Setup script for CI/CD pipeline
# Generates package-lock.json files if they don't exist

Write-Host "Setting up project for CI/CD..." -ForegroundColor Cyan
Write-Host ""

# Backend setup
Write-Host "Setting up backend..." -ForegroundColor Yellow
if (-not (Test-Path "backend/package-lock.json")) {
    Write-Host "  Generating backend package-lock.json..." -ForegroundColor Gray
    Push-Location backend
    npm install
    Pop-Location
    Write-Host "  ✓ Backend package-lock.json created" -ForegroundColor Green
} else {
    Write-Host "  ✓ Backend package-lock.json already exists" -ForegroundColor Green
}

# Gateway setup
Write-Host "Setting up gateway..." -ForegroundColor Yellow
if (-not (Test-Path "gateway/package-lock.json")) {
    Write-Host "  Generating gateway package-lock.json..." -ForegroundColor Gray
    Push-Location gateway
    npm install
    Pop-Location
    Write-Host "  ✓ Gateway package-lock.json created" -ForegroundColor Green
} else {
    Write-Host "  ✓ Gateway package-lock.json already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Commit the package-lock.json files:" -ForegroundColor White
Write-Host "   git add backend/package-lock.json gateway/package-lock.json" -ForegroundColor Gray
Write-Host "   git commit -m 'Add package-lock.json files for CI/CD'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Configure GitHub Secrets (see CI-CD.md):" -ForegroundColor White
Write-Host "   - DOCKERHUB_USERNAME" -ForegroundColor Gray
Write-Host "   - DOCKERHUB_TOKEN" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Push to GitHub to trigger CI/CD pipeline:" -ForegroundColor White
Write-Host "   git push origin main" -ForegroundColor Gray
