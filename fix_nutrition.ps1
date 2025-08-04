# PowerShell script to fix the Nutrition.dart file
$sourceFile = "lib\Features\codia\Nutrition.dart.new"
$targetFile = "lib\Features\codia\Nutrition.dart"
$backupFile = "lib\Features\codia\Nutrition.dart.bak"

# Make sure we're in the right directory
Set-Location "C:\Users\robin\Downloads\GYM APP"

Write-Host "Creating backup of current Nutrition.dart file..."
if (Test-Path $targetFile) {
    Copy-Item -Path $targetFile -Destination $backupFile -Force
    Write-Host "Backup created at $backupFile"
} else {
    Write-Host "Target file not found: $targetFile"
    exit 1
}

Write-Host "Replacing with fixed version..."
if (Test-Path $sourceFile) {
    Copy-Item -Path $sourceFile -Destination $targetFile -Force
    Write-Host "Fixed version applied successfully!"
} else {
    Write-Host "Source file not found: $sourceFile"
    exit 1
}

Write-Host "Running Flutter analyzer to check the fixed file..."
flutter analyze $targetFile

Write-Host "Done! Check the output above for any remaining issues." 