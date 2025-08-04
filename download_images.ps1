$baseUrl = "https://raw.githubusercontent.com/FitlyDeveloper/lehm60/main/assets/images/"

# Create directories if they don't exist
if (-not (Test-Path -Path "assets\images\Coach")) {
    New-Item -Path "assets\images\Coach" -ItemType Directory -Force
}
if (-not (Test-Path -Path "assets\images\SnapFood")) {
    New-Item -Path "assets\images\SnapFood" -ItemType Directory -Force
}

# Starting download process
Write-Host "Starting download of GitHub image files..." -ForegroundColor Cyan

# Main images to download - based on actual GitHub content
$mainImages = @(
    "Transformation2.jpg",
    "background4.jpg",
    "fitly logo IMPROVED.jpg"
)

# Coach folder images
$coachImages = @(
    "image1_136289.png",
    "image2_138464.png",
    "image3_138463.png",
    "image4_138459.png",
    "image5_138457.png"
)

# SnapFood folder images
$snapFoodImages = @(
    "image1_451442.png",
    "image2_451441.png",
    "image3_451435.png",
    "image4_451434.png",
    "image_40448.png",
    "image_40850.png",
    "image_40851.png"
)

$downloadCount = 0
$failedCount = 0
$existingCount = 0
$totalCount = $mainImages.Count + $coachImages.Count + $snapFoodImages.Count

# Download main folder images
foreach ($image in $mainImages) {
    $localPath = "assets\images\$image"
    if (-not (Test-Path -Path $localPath)) {
        Write-Host "Downloading $image..." -NoNewline
        try {
            Invoke-WebRequest -Uri "$baseUrl$image" -OutFile $localPath -ErrorAction Stop
            Write-Host " SUCCESS" -ForegroundColor Green
            $downloadCount++
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
            $failedCount++
            # Clean up any partially downloaded files
            if (Test-Path -Path $localPath) {
                Remove-Item -Path $localPath -Force
            }
        }
    } else {
        Write-Host "$image already exists" -ForegroundColor Yellow
        $existingCount++
    }
}

# Download Coach folder images
foreach ($image in $coachImages) {
    $localPath = "assets\images\Coach\$image"
    if (-not (Test-Path -Path $localPath)) {
        Write-Host "Downloading Coach/$image..." -NoNewline
        try {
            Invoke-WebRequest -Uri "${baseUrl}Coach/$image" -OutFile $localPath -ErrorAction Stop
            Write-Host " SUCCESS" -ForegroundColor Green
            $downloadCount++
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
            $failedCount++
            # Clean up any partially downloaded files
            if (Test-Path -Path $localPath) {
                Remove-Item -Path $localPath -Force
            }
        }
    } else {
        Write-Host "Coach/$image already exists" -ForegroundColor Yellow
        $existingCount++
    }
}

# Download SnapFood folder images
foreach ($image in $snapFoodImages) {
    $localPath = "assets\images\SnapFood\$image"
    if (-not (Test-Path -Path $localPath)) {
        Write-Host "Downloading SnapFood/$image..." -NoNewline
        try {
            Invoke-WebRequest -Uri "${baseUrl}SnapFood/$image" -OutFile $localPath -ErrorAction Stop
            Write-Host " SUCCESS" -ForegroundColor Green
            $downloadCount++
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
            $failedCount++
            # Clean up any partially downloaded files
            if (Test-Path -Path $localPath) {
                Remove-Item -Path $localPath -Force
            }
        }
    } else {
        Write-Host "SnapFood/$image already exists" -ForegroundColor Yellow
        $existingCount++
    }
}

Write-Host "`nDownload Summary:" -ForegroundColor Cyan
Write-Host "Images already existing: $existingCount" -ForegroundColor Yellow
Write-Host "Images successfully downloaded: $downloadCount" -ForegroundColor Green
Write-Host "Images failed to download: $failedCount" -ForegroundColor Red
Write-Host "Total images processed: $($existingCount + $downloadCount + $failedCount) / $totalCount" -ForegroundColor Cyan
Write-Host "Download process completed!" -ForegroundColor Cyan 