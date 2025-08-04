# PowerShell script to set up OpenAI API Key on Render.com using curl

Write-Host "This script will set your OpenAI API Key on Render.com"
Write-Host "You'll need your Render.com API key for this operation"
Write-Host ""

# Prompt for Render API Key
Write-Host "Please enter your Render.com API Key:" -ForegroundColor Cyan
$RENDER_API_KEY = Read-Host -AsSecureString
$RENDER_API_KEY_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RENDER_API_KEY))

# Prompt for OpenAI API Key
Write-Host "Please enter your OpenAI API Key (starts with 'sk-'):" -ForegroundColor Cyan
$OPENAI_API_KEY = Read-Host -AsSecureString
$OPENAI_API_KEY_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($OPENAI_API_KEY))

if ([string]::IsNullOrEmpty($OPENAI_API_KEY_PLAIN)) {
    Write-Host "Error: API Key cannot be empty" -ForegroundColor Red
    exit 1
}

if (!$OPENAI_API_KEY_PLAIN.StartsWith("sk-")) {
    Write-Host "Warning: OpenAI API keys usually start with 'sk-'. Are you sure this is correct?" -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (y/n)"
    if ($confirm -ne "y") {
        Write-Host "Aborting." -ForegroundColor Red
        exit 1
    }
}

# Get the Service ID for snap-food
Write-Host "Getting service ID for snap-food..." -ForegroundColor Green
$headers = @{
    "Accept" = "application/json"
    "Authorization" = "Bearer $RENDER_API_KEY_PLAIN"
}

$response = Invoke-RestMethod -Uri "https://api.render.com/v1/services?name=snap-food" -Method Get -Headers $headers
$serviceId = $response.services[0].id

if ([string]::IsNullOrEmpty($serviceId)) {
    Write-Host "Error: Could not find 'snap-food' service on your Render account" -ForegroundColor Red
    exit 1
}

# Set the environment variable
Write-Host "Setting OpenAI API Key on Render.com..." -ForegroundColor Green

$envVarBody = @{
    "key" = "OPENAI_API_KEY"
    "value" = "$OPENAI_API_KEY_PLAIN"
} | ConvertTo-Json

$envResponse = Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars" -Method Post -Headers $headers -Body $envVarBody -ContentType "application/json"

Write-Host "Done! Your OpenAI API Key has been set on Render.com." -ForegroundColor Green
Write-Host "You need to redeploy your service for the changes to take effect." -ForegroundColor Yellow
Write-Host "Go to the Render dashboard and click 'Manual Deploy' > 'Deploy latest commit'" -ForegroundColor Yellow 