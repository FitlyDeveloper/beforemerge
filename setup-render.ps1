# Script to set up the deployment environment for Render.com

# Copy the server file to the root
Copy-Item -Path "api-server/server.js" -Destination "server.js"

# Install required packages
npm install dotenv express cors node-fetch express-rate-limit

# Create a basic .env file if it doesn't exist
if (-not (Test-Path -Path ".env")) {
  Write-Host "Creating .env file..."
  Set-Content -Path ".env" -Value "# Configuration for Food Analyzer API"
  Add-Content -Path ".env" -Value "PORT=3000"
  Add-Content -Path ".env" -Value "NODE_ENV=production"
  # Note: Don't store actual API keys in this script
  Add-Content -Path ".env" -Value "# Add your OpenAI API key below"
  Add-Content -Path ".env" -Value "OPENAI_API_KEY=your_api_key_here"
}

Write-Host "Setup complete! Make sure to add your actual OpenAI API key to the .env file." 