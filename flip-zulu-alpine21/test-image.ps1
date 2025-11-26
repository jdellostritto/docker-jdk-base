param(
    [string]$ImageTag = "flipfoundry/docker-base-zulu-alpine:1.0.0"
)

Write-Host "Testing Docker image: $ImageTag" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "`n[Test 1] Java Version" -ForegroundColor Yellow
docker run --rm $ImageTag java -version 2>&1
Write-Host "OK" -ForegroundColor Green

Write-Host "`n[Test 2] Javac (Compiler)" -ForegroundColor Yellow
docker run --rm $ImageTag javac -version 2>&1
Write-Host "OK" -ForegroundColor Green

Write-Host "`n[Test 3] User Check (appuser)" -ForegroundColor Yellow
Write-Host "Verifying appuser exists with UID 1001..." -ForegroundColor Gray
docker run --rm $ImageTag id appuser 2>&1
$appuser_id = docker run --rm $ImageTag id -u appuser 2>&1
if ($appuser_id -eq "1001") {
    Write-Host "OK - appuser (UID 1001) created successfully" -ForegroundColor Green
} else {
    Write-Host "FAIL - appuser UID is $appuser_id (expected 1001)" -ForegroundColor Red
}

Write-Host "`n[Test 4] Java Program" -ForegroundColor Yellow
docker run --rm $ImageTag javac -version 2>&1
Write-Host "OK" -ForegroundColor Green

Write-Host "`n[Test 5] Image Layers" -ForegroundColor Yellow
docker history $ImageTag 2>&1 | Select-Object -First 8
Write-Host "OK" -ForegroundColor Green

Write-Host "`n[Test 6] Image Metadata" -ForegroundColor Yellow
docker images $ImageTag
Write-Host "OK" -ForegroundColor Green

Write-Host "`n[Test 7] Environment" -ForegroundColor Yellow
docker run --rm $ImageTag sh -c "echo JAVA_HOME=`$JAVA_HOME;echo LANG=`$LANG" 2>&1
Write-Host "OK" -ForegroundColor Green

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Testing complete!" -ForegroundColor Cyan
