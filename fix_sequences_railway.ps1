# Script to fix PostgreSQL sequences on Railway
# Run this after database migration to reset auto-increment sequences

$ErrorActionPreference = "Stop"

Write-Host "🔧 Fixing PostgreSQL sequences on Railway..." -ForegroundColor Cyan
Write-Host ""

# Railway database URL
$DATABASE_URL = "postgresql://postgres:XVVPGtCBOcfPCKkqbXLjFBwIHvMCmqKx@junction.proxy.rlwy.net:34666/railway"

Write-Host "📊 Connecting to Railway PostgreSQL database..." -ForegroundColor Yellow
Write-Host ""

# Using Python to execute the fix_sequences script
$env:DATABASE_URL = $DATABASE_URL

Set-Location "buyv_backend"

Write-Host "🐍 Running fix_sequences.py..." -ForegroundColor Green
python fix_sequences.py

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Sequences fixed successfully!" -ForegroundColor Green
    Write-Host "You can now create new orders without errors." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Failed to fix sequences" -ForegroundColor Red
    exit 1
}
