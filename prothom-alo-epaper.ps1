# Ensure we stop on unexpected errors
$ErrorActionPreference = 'Stop'

# ---------------------------
# Config / Constants
# ---------------------------
$WebsiteUrl = "https://epaper.prothomalo.com/"
$PdfFileName = "prothom-alo_" + (Get-Date -Format "yyyyMMdd") + ".pdf"

# Output folder: User's Downloads\Prothom Alo
$UserProfile = [Environment]::GetFolderPath("UserProfile")
$DownloadsFolder = Join-Path -Path $UserProfile -ChildPath "Downloads"
$OutputFolder = Join-Path -Path $DownloadsFolder -ChildPath "Prothom Alo"
$PdfFilePath = Join-Path -Path $OutputFolder -ChildPath $PdfFileName

# Temp folder: user's temp folder
$UserTemp = [System.IO.Path]::GetTempPath()
$TempFolderName = "prothom-alo-epaper"
$TempFolder = Join-Path -Path $UserTemp -ChildPath $TempFolderName

# ImageMagick download URL
$ImageMagickDownloadUrl = "https://imagemagick.org/script/download.php#windows"

# ---------------------------
# Helper Functions
# ---------------------------

function Test-ImageMagick {
    $cmd = Get-Command magick.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        return $true
    }

    Write-Host -ForegroundColor Yellow "ImageMagick not found. Trying winget..."

    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetCmd) {
        Write-Host -ForegroundColor Red "winget is not available."
        Write-Host -ForegroundColor Yellow "Install ImageMagick manually:"
        Write-Host -ForegroundColor Yellow $ImageMagickDownloadUrl
        return $false
    }

    try {
        $arguments = @(
            "install",
            "--id", "ImageMagick.ImageMagick",
            "-e",
            "--source", "winget",
            "--accept-source-agreements",
            "--accept-package-agreements"
        )

        $process = Start-Process -FilePath $wingetCmd.Source -ArgumentList $arguments -Wait -PassThru

        if ($process.ExitCode -ne 0) {
            Write-Host -ForegroundColor Red "winget failed to install ImageMagick."
            Write-Host -ForegroundColor Yellow "Install manually: $ImageMagickDownloadUrl"
            return $false
        }

        return $null -ne (Get-Command magick.exe -ErrorAction SilentlyContinue)
    }
    catch {
        Write-Host -ForegroundColor Red "Error installing ImageMagick: $($_.Exception.Message)"
        Write-Host -ForegroundColor Yellow "Install manually: $ImageMagickDownloadUrl"
        return $false
    }
}

function Remove-TempFolder {
    param ([string]$Path)

    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force
    }
}

function Get-WebsiteHtml {
    param ([string]$Url)

    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
    return $response.Content
}

function Get-ImageLinksFromHtml {
    param ([string]$Html)

    $pattern = '"HighResolution_Without_mr"\s*:\s*"([^"]+)"'
    $regexMatches = [regex]::Matches($Html, $pattern)

    if ($regexMatches.Count -eq 0) {
        throw "No image links found."
    }

    # Deduplicate while preserving order
    $seen = @{}
    $final = @()

    foreach ($m in $regexMatches) {
        $link = $m.Groups[1].Value
        if (-not $seen.ContainsKey($link)) {
            $seen[$link] = $true
            $final += $link
        }
    }

    return $final
}

function Get-Images {
    param (
        [string[]]$Links,
        [string]$Folder
    )

    if (-not (Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder | Out-Null
    }

    $count = $Links.Count
    $index = 0

    foreach ($link in $Links) {
        $index++
        Write-Progress -Activity "Downloading pages" -Status "Page $index of $count" -PercentComplete (($index / $count) * 100)

        $name = [System.IO.Path]::GetFileName($link)
        if (-not $name) { $name = "page_$index.jpg" }

        $out = Join-Path -Path $Folder -ChildPath $name
        Invoke-WebRequest -Uri $link -OutFile $out -UseBasicParsing
    }
}

function Rename-DownloadedFiles {
    param([string]$Folder)

    $files = Get-ChildItem -Path $Folder -File

    foreach ($file in $files) {
        $new = $file.Name -replace '^.*?_', ''
        if ($new -and $new -ne $file.Name) {
            Rename-Item $file.FullName -NewName $new
        }
    }
}

function Convert-ToPDF {
    param (
        [string]$SourceFolder,
        [string]$PdfFilePath
    )

    $images = Get-ChildItem -Path $SourceFolder -Filter *.jpg -File |
    Sort-Object Name |
    Select-Object -ExpandProperty FullName

    if (-not $images -or $images.Count -eq 0) {
        throw "No images found to convert in: $SourceFolder"
    }

    & magick.exe @images $PdfFilePath
}

# ---------------------------
# Main Script
# ---------------------------

if (-not (Test-ImageMagick)) {
    exit 1
}

if (Test-Path $PdfFilePath) {
    Write-Host -ForegroundColor Yellow "Today's PDF already exists: $PdfFilePath"
    exit 0
}

Remove-TempFolder $TempFolder
New-Item -ItemType Directory -Path $TempFolder | Out-Null

try {
    Write-Host -ForegroundColor Cyan "Creating today's PDF: $PdfFileName"

    Write-Host "Fetching metadata..."
    $html = Get-WebsiteHtml $WebsiteUrl

    Write-Host "Extracting pages..."
    $links = Get-ImageLinksFromHtml $html

    Write-Host "Downloading pages..."
    Get-Images $links $TempFolder

    Rename-DownloadedFiles $TempFolder
    
    if (-not (Test-Path $OutputFolder)) {
        New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    }
    
    Write-Host "Building PDF..."
    Convert-ToPDF $TempFolder $PdfFilePath

    Write-Host -ForegroundColor Green "PDF created: $PdfFilePath"
}
catch {
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}
