<#
.SYNOPSIS
    Uploads local image assets from consumer_app/assets/images to Supabase Storage bucket 'assets'.

.EXAMPLE
    .\scripts\upload_assets_to_supabase.ps1 -ServiceKey "YOUR_SUPABASE_SERVICE_ROLE_KEY"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ServiceKey = $env:SUPABASE_SERVICE_ROLE_KEY
)

$SupabaseUrl = "https://ndjvkzrxgmxsdrbyeyim.supabase.co"
$BucketName = "assets"

if (-not $ServiceKey) {
    Write-Host "`n[!] Supabase Service Role Key is required for bucket administration & upload." -ForegroundColor Yellow
    Write-Host "    You can find it in: Supabase Dashboard -> Project Settings -> API -> service_role key (secret)"
    $ServiceKey = Read-Host "Enter your Supabase service_role key"
}

if (-not $ServiceKey) {
    Write-Error "No service_role key provided. Exiting."
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AssetsDir = Join-Path (Split-Path -Parent $ScriptDir) "consumer_app\assets\images"

if (-not (Test-Path $AssetsDir)) {
    Write-Error "Assets directory not found at: $AssetsDir"
    exit 1
}

# 1. Ensure bucket exists and is public
Write-Host "`n1. Ensuring public bucket '$BucketName' exists..." -ForegroundColor Cyan
$Headers = @{
    "apikey" = $ServiceKey
    "Authorization" = "Bearer $ServiceKey"
    "Content-Type" = "application/json"
}

$Body = @{
    "id" = $BucketName
    "name" = $BucketName
    "public" = $true
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "$SupabaseUrl/storage/v1/bucket" -Headers $Headers -Method Post -Body $Body | Out-Null
    Write-Host "   Bucket '$BucketName' created successfully." -ForegroundColor Green
} catch {
    Write-Host "   Bucket '$BucketName' already exists or ready." -ForegroundColor Gray
}

# 2. Upload files
$Files = Get-ChildItem -Path $AssetsDir -File | Where-Object { -not $_.Name.StartsWith(".") }
Write-Host "`n2. Found $($Files.Count) files to upload to Supabase CDN bucket '$BucketName/assets/images/'...`n" -ForegroundColor Cyan

$Uploaded = 0
$Failed = 0

for ($i = 0; $i -lt $Files.Count; $i++) {
    $file = $Files[$i]
    $destPath = "assets/images/$($file.Name)"
    $uploadUrl = "$SupabaseUrl/storage/v1/object/$BucketName/$destPath"
    
    $contentType = "image/jpeg"
    if ($file.Extension -eq ".png") { $contentType = "image/png" }

    $uploadHeaders = @{
        "apikey" = $ServiceKey
        "Authorization" = "Bearer $ServiceKey"
        "x-upsert" = "true"
        "Content-Type" = $contentType
    }

    try {
        Invoke-RestMethod -Uri $uploadUrl -Headers $uploadHeaders -Method Post -InFile $file.FullName | Out-Null
        $Uploaded++
        $sizeKb = [math]::Round($file.Length / 1KB, 1)
        Write-Host "   [$($i+1)/$($Files.Count)] OK: $destPath ($sizeKb KB)" -ForegroundColor Green
    } catch {
        $Failed++
        Write-Host "   [$($i+1)/$($Files.Count)] FAILED: $($file.Name) -> $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Yellow
Write-Host "Upload Complete! Successfully uploaded: $Uploaded/$($Files.Count)" -ForegroundColor Green
if ($Failed -gt 0) {
    Write-Host "Failed uploads: $Failed" -ForegroundColor Red
}
Write-Host "Public CDN URL prefix: $SupabaseUrl/storage/v1/object/public/$BucketName/assets/images/<filename>" -ForegroundColor Cyan
Write-Host "==================================================`n" -ForegroundColor Yellow
