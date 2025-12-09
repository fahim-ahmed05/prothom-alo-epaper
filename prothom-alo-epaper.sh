#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# Config / Constants
# ---------------------------
WEBSITE_URL="https://epaper.prothomalo.com/"
PDF_FILENAME="prothom-alo_$(date +%Y%m%d).pdf"

# Output folder: ~/Downloads/Prothom Alo (or XDG_DOWNLOAD_DIR on Linux)
if [[ "$OSTYPE" == darwin* ]]; then
  DOWNLOADS_DIR="$HOME/Downloads"
else
  DOWNLOADS_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
fi

OUTPUT_FOLDER="${DOWNLOADS_DIR}/Prothom Alo"
PDF_FILEPATH="${OUTPUT_FOLDER}/${PDF_FILENAME}"

# Temp folder: user's temp folder
TMP_DIR="${TMPDIR:-/tmp}"
TEMP_FOLDER_NAME="prothom-alo-epaper"
TEMP_FOLDER="${TMP_DIR}/${TEMP_FOLDER_NAME}"

# ---------------------------
# Helper: echo to stderr
# ---------------------------
log() {
  printf '%s\n' "$*" >&2
}

# ---------------------------
# Helper: check for ImageMagick
# ---------------------------
ensure_imagemagick() {
  if command -v magick >/dev/null 2>&1; then
    IM_CMD="magick"
    return 0
  elif command -v convert >/dev/null 2>&1; then
    IM_CMD="convert"
    return 0
  else
    log "ImageMagick is not installed."
    log "Please install ImageMagick:"
    if [[ "$OSTYPE" == darwin* ]]; then
      log "  brew install imagemagick"
    else
      log "  sudo apt install imagemagick      (Debian/Ubuntu)"
      log "  sudo dnf install imagemagick      (Fedora/RHEL)"
      log "  sudo pacman -S imagemagick        (Arch)"
    fi
    return 1
  fi
}

# ---------------------------
# Helper: pick HTTP client
# ---------------------------
detect_http_client() {
  if command -v curl >/dev/null 2>&1; then
    HTTP_CLIENT="curl"
  elif command -v wget >/dev/null 2>&1; then
    HTTP_CLIENT="wget"
  else
    log "Neither curl nor wget is available. Please install one of them."
    exit 1
  fi
}

http_get_to_stdout() {
  local url="$1"
  if [[ "$HTTP_CLIENT" == "curl" ]]; then
    curl -fsSL -A "Mozilla/5.0" "$url"
  else
    wget -qO- --header="User-Agent: Mozilla/5.0" "$url"
  fi
}

http_get_to_file() {
  local url="$1"
  local out="$2"
  if [[ "$HTTP_CLIENT" == "curl" ]]; then
    curl -fsSL -A "Mozilla/5.0" -o "$out" "$url"
  else
    wget -q --header="User-Agent: Mozilla/5.0" -O "$out" "$url"
  fi
}

# ---------------------------
# Helper: remove temp folder
# ---------------------------
remove_temp_folder() {
  if [[ -d "$TEMP_FOLDER" ]]; then
    rm -rf "$TEMP_FOLDER"
  fi
}

# ---------------------------
# Get website HTML
# ---------------------------
get_website_html() {
  http_get_to_stdout "$WEBSITE_URL"
}

# ---------------------------
# Extract image links from HTML
# ---------------------------
get_image_links_from_html() {
  local html="$1"
  # Use perl to extract the URLs from "HighResolution_Without_mr"
  # Then dedupe while preserving order via awk
  printf '%s' "$html" | perl -ne 'while(/"HighResolution_Without_mr"\s*:\s*"([^"]+)"/g){print "$1\n"}' \
    | awk '!seen[$0]++'
}

# ---------------------------
# Download images
# ---------------------------
download_images() {
  local folder="$1"
  shift
  local links=("$@")

  mkdir -p "$folder"

  local count="${#links[@]}"
  local i=0

  for link in "${links[@]}"; do
    i=$((i+1))
    # Basic progress in stderr
    log "Downloading page $i of $count"

    local name
    name="$(basename "$link")"
    if [[ -z "$name" || "$name" == "/" ]]; then
      name="page_${i}.jpg"
    fi

    local out="${folder}/${name}"
    http_get_to_file "$link" "$out"
  done
}

# ---------------------------
# Rename downloaded files
# (remove everything up to first underscore)
# ---------------------------
rename_downloaded_files() {
  local folder="$1"
  # shellcheck disable=SC2045
  for f in $(ls "$folder"); do
    local full="${folder}/${f}"
    if [[ -f "$full" ]]; then
      local new="${f#*_}"
      if [[ -n "$new" && "$new" != "$f" ]]; then
        mv "$full" "${folder}/${new}"
      fi
    fi
  done
}

# ---------------------------
# Convert images to PDF
# ---------------------------
convert_to_pdf() {
  local source_folder="$1"
  local pdf_path="$2"

  # Ensure we only pick jpg files
  shopt -s nullglob
  local images=("$source_folder"/*.jpg)
  shopt -u nullglob

  if [[ ${#images[@]} -eq 0 ]]; then
    log "No images found to convert in: $source_folder"
    return 1
  fi

  # Sort images by name
  IFS=$'\n' images=($(printf '%s\n' "${images[@]}" | sort))
  unset IFS

  "$IM_CMD" "${images[@]}" "$pdf_path"
}

# ---------------------------
# Main
# ---------------------------

detect_http_client

if ! ensure_imagemagick; then
  exit 1
fi

# If today's PDF already exists, exit
if [[ -f "$PDF_FILEPATH" ]]; then
  log "Today's PDF already exists: $PDF_FILEPATH"
  exit 0
fi

# Prepare folders
remove_temp_folder
mkdir -p "$TEMP_FOLDER"
mkdir -p "$OUTPUT_FOLDER"

log "Creating today's PDF: $PDF_FILENAME"

log "Fetching metadata..."
HTML_CONTENT="$(get_website_html)"

log "Extracting pages..."
# Read links into array
mapfile -t IMAGE_LINKS < <(get_image_links_from_html "$HTML_CONTENT")

if [[ ${#IMAGE_LINKS[@]} -eq 0 ]]; then
  log "No image links found in HTML."
  exit 1
fi

log "Downloading pages..."
download_images "$TEMP_FOLDER" "${IMAGE_LINKS[@]}"

log "Renaming files..."
rename_downloaded_files "$TEMP_FOLDER"

log "Building PDF..."
if convert_to_pdf "$TEMP_FOLDER" "$PDF_FILEPATH"; then
  log "PDF created: $PDF_FILEPATH"
else
  log "Failed to create PDF."
  exit 1
fi
