# PowerShell script for setting up Git and preparing for Render.com deployment

Write-Host "Setting up Git and preparing for Render.com deployment"

# Check if git is installed
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Please install Git and try again."
    exit 1
}

# Check if repository is already initialized
if (!(Test-Path ".git")) {
    Write-Host "Initializing Git repository..."
    git init
}

# Add .gitignore if needed
if (!(Test-Path ".gitignore")) {
    Write-Host "Creating .gitignore file..."
    @"
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Visual Studio Code related
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Android related
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.*

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Environment files
.env
.env.local

# Firebase related
functions/node_modules/
functions/.runtimeconfig.json

# Web related
lib/generated_plugin_registrant.dart

# Exceptions to the above rules
!**/ios/**/default.mode1v3
!**/ios/**/default.mode2v3
!**/ios/**/default.pbxuser
!**/ios/**/default.perspectivev3
!/packages/flutter_tools/test/data/dart_dependencies_test/**/.packages
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
}

# Make sure we have a .env.example file but not a real .env
if (Test-Path "api-server") {
    Push-Location -Path "api-server"

    # Make sure we have .env.example
    if (!(Test-Path ".env.example")) {
        Write-Host "Creating .env.example file..."
        @"
# OpenAI API Key (Required)
OPENAI_API_KEY=sk-your-api-key-here

# Server Configuration
PORT=3000

# Access Control
# Comma-separated list of allowed origins (for CORS)
ALLOWED_ORIGINS=http://localhost:3000,https://your-app-domain.com

# Security
# Request limiting (requests per minute per IP)
RATE_LIMIT=30

# Optional: Set to 'true' to enable logging of API requests and responses
DEBUG_MODE=false
"@ | Out-File -FilePath ".env.example" -Encoding UTF8
    }

    # Make sure .env is ignored
    if (Test-Path ".env") {
        Write-Host "Backing up .env file to .env.backup"
        Copy-Item -Path ".env" -Destination ".env.backup"
        Write-Host "Removing .env file (it will be created on Render.com with environment variables)"
        Remove-Item -Path ".env"
    }

    Pop-Location
}

Write-Host "Preparing to commit changes..."

# Remove Firebase files if they exist
Write-Host "Removing Firebase-specific files..."
if (Test-Path "firebase.json") { Remove-Item -Path "firebase.json" }
if (Test-Path ".firebaserc") { Remove-Item -Path ".firebaserc" }
if (Test-Path "functions/node_modules") { Remove-Item -Path "functions/node_modules" -Recurse -Force }

# Add all files
git add .

# Ask for remote repository URL
Write-Host ""
Write-Host "To push to GitHub, please provide your GitHub repository information:"
$github_username = Read-Host -Prompt "GitHub username"
$repo_name = Read-Host -Prompt "Repository name"

# Set up the remote repository
git remote remove origin 2>$null
git remote add origin "https://github.com/$github_username/$repo_name.git"

Write-Host ""
Write-Host "Ready to commit and push. Please complete these steps manually:"
Write-Host ""
Write-Host "1. Commit your changes:"
Write-Host "   git commit -m ""Initial commit for Render.com deployment"""
Write-Host ""
Write-Host "2. Push to GitHub:"
Write-Host "   git push -u origin main"
Write-Host ""
Write-Host "3. Set up on Render.com:"
Write-Host "   - Sign up/log in to Render.com"
Write-Host "   - Create a new Web Service"
Write-Host "   - Connect your GitHub repository '$github_username/$repo_name'"
Write-Host "   - Configure as follows:"
Write-Host "     Name: food-analyzer-api"
Write-Host "     Build Command: cd api-server && npm install"
Write-Host "     Start Command: cd api-server && npm start"
Write-Host "     Environment Variables: Add OPENAI_API_KEY and other variables from .env.example"
Write-Host ""
Write-Host "4. Update the API URL in lib/services/food_analyzer_api.dart:"
Write-Host "   - Replace 'https://food-analyzer-api.onrender.com' with your actual Render.com URL"
Write-Host "" 