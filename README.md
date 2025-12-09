# 📰 Prothom Alo ePaper to PDF Generator

This tool automatically downloads the **Prothom Alo ePaper** high-resolution pages and generates a clean, ordered **PDF**.

## 📌 Requirements

### 🖼 ImageMagick (Required)

Used to merge downloaded page images into a PDF.

### Windows Install (Winget)

    winget install --id ImageMagick.ImageMagick -e --source winget --accept-source-agreements --accept-package-agreements

### macOS Install (Homebrew)

    brew install imagemagick

### Linux Install

    # Debian / Ubuntu
    sudo apt install imagemagick

    # Fedora / RHEL
    sudo dnf install imagemagick

    # Arch Linux
    sudo pacman -S imagemagick

Or download from the [official site](https://imagemagick.org/script/download.php).

## 🚀 How to Use (Windows)

### Option 1: Run Using the Included BAT Launcher

[Download](https://raw.githubusercontent.com/fahim-ahmed05/prothom-alo-epaper/main/prothom-alo-epaper.bat) or create a file named `prothom-alo-epaper.bat`:

    @echo off
    setlocal

    set "SCRIPT_URL=https://raw.githubusercontent.com/fahim-ahmed05/prothom-alo-epaper/main/prothom-alo-epaper.ps1"
    set "SCRIPT_NAME=prothom-alo-epaper.ps1"
    set "TEMP_PS=%TEMP%\%SCRIPT_NAME%"

    powershell -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%TEMP_PS%' -UseBasicParsing"
    powershell -ExecutionPolicy Bypass -File "%TEMP_PS%"

    endlocal
    exit /b

Double-click `prothom-alo-epaper.bat` — it will download and run the script automatically.

## Option 2: Run PowerShell Script Manually

[Download](https://github.com/fahim-ahmed05/prothom-alo-epaper/archive/refs/heads/main.zip) or clone the repo then run inside the repo folder:

    powershell -ExecutionPolicy Bypass -File .\prothom-alo-epaper.ps1

## 🚀 How to Use (macOS & Linux)

[Download](https://github.com/fahim-ahmed05/prothom-alo-epaper/archive/refs/heads/main.zip) or clone the repo then cd into the repo folder:

Make the script executable:

    chmod +x prothom-alo-epaper.sh

Then run:

    ./prothom-alo-epaper.sh

## 📂 PDF Location

    ~/Downloads/Prothom Alo/
    └── prothom-alo_YYYYMMDD.pdf

## ❗ Notes

Restart your terminal or reboot if `magick` or `convert` is not recognized after installing ImageMagick.

## ⭐ Support the Project

If you find this tool useful, please consider starring the repository or supporting development:

<a href="https://www.buymeacoffee.com/fahim.ahmed" target="_blank">
  <img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" 
       alt="Buy Me A Coffee"
       style="height: 41px !important; width: 174px !important; box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5);" />
</a>
