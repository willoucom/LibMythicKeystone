$source = $PSScriptRoot
$dest   = "C:\Games\World of Warcraft\_retail_\Interface\AddOns\LibMythicKeystone"

Write-Host "Deploying LibMythicKeystone..." -ForegroundColor Cyan
Write-Host "  From : $source"
Write-Host "  To   : $dest"
Write-Host ""

robocopy $source $dest /E /NJH /NJS `
    /XD ".git" ".github" ".vscode" `
    /XF "README.md" "DEVELOPERS.md" ".pkgmeta" "deploy.ps1"

if ($LASTEXITCODE -le 7) {
    Write-Host ""
    Write-Host "Done." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Robocopy error (code $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}
