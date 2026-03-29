$products = @(
    @{name="iPhone 15 Pro"; description="Latest Apple flagship with A17 Pro chip"; price=99999; stock=10; sku="IPHONE15PRO"},
    @{name="Samsung Galaxy S24"; description="Premium Android phone with AI features"; price=89999; stock=8; sku="GALAXY_S24"},
    @{name="MacBook Pro 14"; description="Powerful laptop with M3 Pro chip"; price=199999; stock=5; sku="MACBOOK_PRO_14"},
    @{name="iPad Air"; description="Versatile tablet for work and creativity"; price=54999; stock=12; sku="IPAD_AIR"},
    @{name="Sony WH-1000XM5"; description="Industry-leading noise cancelling headphones"; price=29999; stock=15; sku="SONY_HEADPHONES"},
    @{name="DJI Air 3S"; description="Professional drone with advanced features"; price=79999; stock=6; sku="DJI_AIR3S"}
)

Write-Host "Creating products..." -ForegroundColor Cyan
$successCount = 0
$failCount = 0

foreach ($product in $products) { 
    $body = $product | ConvertTo-Json
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/products" -Method POST -ContentType "application/json" -Body $body -UseBasicParsing
        $result = $response.Content | ConvertFrom-Json
        Write-Host "[OK] Created: $($product.name)" -ForegroundColor Green
        $successCount++
    } catch {
        $errorMsg = $_.Exception.Response.StatusCode
        $errorBody = $_.Exception.Message
        Write-Host "[FAIL] $($product.name) - Status: $errorMsg - Error: $errorBody" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "Success: $successCount products created" -ForegroundColor Green
Write-Host "Failed: $failCount products" -ForegroundColor Red

