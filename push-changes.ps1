# PowerShell script to add, commit, and push changes
Write-Host "Adding all changes..." -ForegroundColor Cyan
git add .

Write-Host "Committing changes..." -ForegroundColor Cyan
git commit -m "Update image size limit to 4MB and improve error handling"

Write-Host "Pushing changes to remote repository..." -ForegroundColor Cyan
git push origin clean-branch

Write-Host "Done!" -ForegroundColor Green 