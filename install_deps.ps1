# Flutter project dependency installer for Windows

Write-Host "Installing Flutter dependencies for the project..."

# Update packages first
flutter pub get

# Check if path_provider is in pubspec.yaml
$pubspecContent = Get-Content .\pubspec.yaml -Raw
if ($pubspecContent -match "path_provider") {
    Write-Host "path_provider already in pubspec.yaml"
} else {
    Write-Host "Adding path_provider to dependencies..."
    $updatedContent = $pubspecContent -replace "(dependencies:[\s\S]*?)(dev_dependencies)", "`$1  path_provider: ^2.1.2`n`$2"
    Set-Content -Path .\pubspec.yaml -Value $updatedContent
    flutter pub get
}

# Check for cloud_functions
if ($pubspecContent -match "cloud_functions") {
    Write-Host "cloud_functions already in pubspec.yaml"
} else {
    Write-Host "Adding cloud_functions to dependencies..."
    $pubspecContent = Get-Content .\pubspec.yaml -Raw
    $updatedContent = $pubspecContent -replace "(dependencies:[\s\S]*?)(dev_dependencies)", "`$1  cloud_functions: ^5.4.0`n`$2"
    Set-Content -Path .\pubspec.yaml -Value $updatedContent
    flutter pub get
}

Write-Host "Setting up Firebase functions..."
Set-Location -Path .\functions
npm install
Set-Location -Path ..

Write-Host "All dependencies installed!"
Write-Host "To deploy Firebase functions, run: cd functions; node deploy.js" 