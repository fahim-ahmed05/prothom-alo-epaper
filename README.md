# 📰 Prothom Alo ePaper → PDF Generator

This tool automatically downloads the **Prothom Alo ePaper** high-resolution pages and generates a clean, ordered **PDF**.

### 📌 Requirement

#### ImageMagick
Used to merge downloaded images into a PDF.

If ImageMagick is **not installed**, the script will attempt:

1. Automatic installation via **winget**
2. If winget is unavailable or fails → show download link.


### 🚀 How to Use

#### Option 1: Run Using the Included BAT Launcher

[Download](https://raw.githubusercontent.com/fahim-ahmed05/prothom-alo-epaper/main/prothom-alo-epaper.bat) or Create a file named `prothom-alo-epaper.bat`.

```bat
@echo off  
setlocal  

set "SCRIPT_URL=https://raw.githubusercontent.com/fahim-ahmed05/prothom-alo-epaper/main/prothom-alo-epaper.ps1"  
set "SCRIPT_NAME=prothom-alo-epaper.ps1"  
set "TEMP_PS=%TEMP%\%SCRIPT_NAME%"  

powershell -Command "Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%TEMP_PS%' -UseBasicParsing"  
powershell -ExecutionPolicy Bypass -File "%TEMP_PS%"  

endlocal  
exit /b  
```

Then, just double-click the `prothom-alo-epaper.bat` file.


#### Option 2: Run Script Manually

[Download](https://github.com/fahim-ahmed05/prothom-alo-epaper/archive/refs/heads/main.zip) or Clone the repo, then open PowerShell inside the repo folder and run.

```powershell
powershell -ExecutionPolicy Bypass -File .\prothom-alo-epaper.ps1
```

### 📂 PDF Location

```
%USERPROFILE%\Downloads\Prothom Alo\
└── prothom-alo_YYYYMMDD.pdf  
```

### ❗ Note

If ImageMagick installs but PowerShell can't find `magick.exe`, restart your system or re-open PowerShell.

### ⭐ Support

If you find this tool useful, please consider starring the repository or supporting the development.

<a href="https://www.buymeacoffee.com/fahim.ahmed" target="_blank">
  <img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" 
       alt="Buy Me A Coffee"
       style="height: 41px !important; width: 174px !important; box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5);" />
</a>
