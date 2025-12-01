#!/usr/bin/env pwsh
# Test script for verifying the microservices setup
# Usage: ./test-api.ps1

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "E-Commerce Microservices API Tests" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5921"
$testsPassed = 0
$testsFailed = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [object]$Body = $null,
        [hashtable]$Headers = @{}
    )
    
    Write-Host "Testing: $Name" -ForegroundColor Yellow
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            UseBasicParsing = $true
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @params -ErrorAction Stop
        
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
            Write-Host "  ✓ PASSED - Status: $($response.StatusCode)" -ForegroundColor Green
            $script:testsPassed++
            return $response
        } else {
            Write-Host "  ✗ FAILED - Status: $($response.StatusCode)" -ForegroundColor Red
            $script:testsFailed++
            return $null
        }
    } catch {
        Write-Host "  ✗ FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:testsFailed++
        return $null
    }
}

function Test-ShouldFail {
    param(
        [string]$Name,
        [string]$Url
    )
    
    Write-Host "Testing: $Name (should fail)" -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✗ FAILED - Backend should not be accessible directly!" -ForegroundColor Red
        $script:testsFailed++
    } catch {
        Write-Host "  ✓ PASSED - Backend correctly blocked" -ForegroundColor Green
        $script:testsPassed++
    }
}

Write-Host "Waiting for services to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Test 1: Gateway Health
Write-Host ""
Write-Host "1. Gateway Health Check" -ForegroundColor Magenta
Test-Endpoint -Name "Gateway /health" -Url "$baseUrl/health"

# Test 2: Backend Health via Gateway
Write-Host ""
Write-Host "2. Backend Health Check (via Gateway)" -ForegroundColor Magenta
Test-Endpoint -Name "Backend /api/health" -Url "$baseUrl/api/health"

# Test 3: Create Product
Write-Host ""
Write-Host "3. Create Product" -ForegroundColor Magenta
$product1 = @{
    name = "Test Product 1"
    price = 99.99
}
$createResponse = Test-Endpoint -Name "POST /api/products" -Url "$baseUrl/api/products" -Method "POST" -Body $product1

# Test 4: Create Another Product
Write-Host ""
Write-Host "4. Create Another Product" -ForegroundColor Magenta
$product2 = @{
    name = "Test Product 2"
    price = 149.99
}
Test-Endpoint -Name "POST /api/products" -Url "$baseUrl/api/products" -Method "POST" -Body $product2

# Test 5: Get All Products
Write-Host ""
Write-Host "5. Get All Products" -ForegroundColor Magenta
$productsResponse = Test-Endpoint -Name "GET /api/products" -Url "$baseUrl/api/products"

if ($productsResponse) {
    $products = $productsResponse.Content | ConvertFrom-Json
    Write-Host "  Found $($products.Count) products" -ForegroundColor Cyan
    foreach ($product in $products) {
        Write-Host "    - $($product.name): `$$($product.price)" -ForegroundColor Gray
    }
}

# Test 6: Input Validation - Invalid Name
Write-Host ""
Write-Host "6. Input Validation Tests" -ForegroundColor Magenta
Write-Host "Testing invalid inputs (should fail):" -ForegroundColor Yellow

try {
    $invalidProduct = @{
        name = ""
        price = 50
    }
    $response = Invoke-WebRequest -Uri "$baseUrl/api/products" -Method POST -Body ($invalidProduct | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
    Write-Host "  ✗ FAILED - Should reject empty name" -ForegroundColor Red
    $script:testsFailed++
} catch {
    Write-Host "  ✓ PASSED - Correctly rejected empty name" -ForegroundColor Green
    $script:testsPassed++
}

# Test 7: Input Validation - Invalid Price
try {
    $invalidProduct = @{
        name = "Product"
        price = -10
    }
    $response = Invoke-WebRequest -Uri "$baseUrl/api/products" -Method POST -Body ($invalidProduct | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
    Write-Host "  ✗ FAILED - Should reject negative price" -ForegroundColor Red
    $script:testsFailed++
} catch {
    Write-Host "  ✓ PASSED - Correctly rejected negative price" -ForegroundColor Green
    $script:testsPassed++
}

# Test 8: Security - Direct Backend Access
Write-Host ""
Write-Host "7. Security Test - Direct Backend Access" -ForegroundColor Magenta
Test-ShouldFail -Name "Direct backend access" -Url "http://localhost:3847/api/products"

# Test 9: Security - Direct MongoDB Access
Write-Host ""
Write-Host "8. Security Test - Direct MongoDB Access" -ForegroundColor Magenta
Test-ShouldFail -Name "Direct MongoDB access" -Url "http://localhost:27017"

# Summary
Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Test Results Summary" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Total Tests: $($testsPassed + $testsFailed)" -ForegroundColor White
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor Red

if ($testsFailed -eq 0) {
    Write-Host ""
    Write-Host "✓ All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "✗ Some tests failed" -ForegroundColor Red
    exit 1
}
