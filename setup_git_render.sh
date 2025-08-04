#!/bin/bash

echo "Setting up Git and preparing for Render.com deployment"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi

# Check if repository is already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
fi

# Add .gitignore if needed
if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore file..."
    cat > .gitignore << EOF
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
EOF
fi

# Make sure we have a .env.example file but not a real .env
if [ -d "api-server" ]; then
    cd api-server

    # Make sure we have .env.example
    if [ ! -f ".env.example" ]; then
        echo "Creating .env.example file..."
        cat > .env.example << EOF
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
EOF
    fi

    # Make sure .env is ignored
    if [ -f ".env" ]; then
        echo "Backing up .env file to .env.backup"
        cp .env .env.backup
        echo "Removing .env file (it will be created on Render.com with environment variables)"
        rm .env
    fi

    cd ..
fi

echo "Preparing to commit changes..."

# Remove Firebase files if they exist
echo "Removing Firebase-specific files..."
rm -f firebase.json .firebaserc
rm -rf functions/node_modules

# Add all files
git add .

# Ask for remote repository URL
echo ""
echo "To push to GitHub, please provide your GitHub repository information:"
read -p "GitHub username: " github_username
read -p "Repository name: " repo_name

# Set up the remote repository
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$github_username/$repo_name.git"

echo ""
echo "Ready to commit and push. Please complete these steps manually:"
echo ""
echo "1. Commit your changes:"
echo "   git commit -m \"Initial commit for Render.com deployment\""
echo ""
echo "2. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "3. Set up on Render.com:"
echo "   - Sign up/log in to Render.com"
echo "   - Create a new Web Service"
echo "   - Connect your GitHub repository '$github_username/$repo_name'"
echo "   - Configure as follows:"
echo "     Name: food-analyzer-api"
echo "     Build Command: cd api-server && npm install"
echo "     Start Command: cd api-server && npm start"
echo "     Environment Variables: Add OPENAI_API_KEY and other variables from .env.example"
echo ""
echo "4. Update the API URL in lib/services/food_analyzer_api.dart:"
echo "   - Replace 'https://food-analyzer-api.onrender.com' with your actual Render.com URL"
echo "" 