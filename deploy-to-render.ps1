Write-Host "Deploying to Render.com..." -ForegroundColor Green

# Check if Render CLI is installed
try {
    render -v
} catch {
    Write-Host "Render CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Visit https://render.com/docs/cli for installation instructions." -ForegroundColor Yellow
    exit 1
}

# Force deploy to Render
Write-Host "Triggering deployment..." -ForegroundColor Cyan
render deploy --yaml render.yaml

Write-Host "Deployment initiated. Check the Render dashboard for deployment status." -ForegroundColor Green
Write-Host "Once deployed, your API will be available at:"
Write-Host "* https://snap-food.onrender.com" -ForegroundColor Yellow
Write-Host "* https://deepseek-uhrc.onrender.com" -ForegroundColor Yellow 