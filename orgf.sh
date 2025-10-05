#!/bin/bash
#
# Orgf - File Organizer.
# Author: Filipe Soares
# GitHub: https://github.com/halpr
# License: MIT
# Version: 1.0.0
# Description: File organizer script - the script will scan the specified external drive for all the file types and then organize them into respective folder.
#
# Colors for eye candy output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Icons
VIDEO_ICON="🎬"
PHOTO_ICON="📸"
MUSIC_ICON="🎵"
ARCHIVE_ICON="📦"
DOCUMENT_ICON="📄"
DESIGN_ICON="🎨"
DISK_ICON="💿"

clear
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     FILE ORGANIZER - Scanning Files...        ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Get the directory to scan (default to current directory)
SCAN_DIR="${1:-.}"
echo -e "${YELLOW}Scanning directory: ${BOLD}$SCAN_DIR${NC}\n"

# Arrays to store file paths by category
declare -a VIDEO_FILES
declare -a PHOTO_FILES
declare -a MUSIC_FILES
declare -a ARCHIVE_FILES
declare -a DOCUMENT_FILES
declare -a DESIGN_FILES
declare -a DISK_FILES

# Define file extensions for each category
VIDEO_EXTS=("mp4" "mkv" "avi" "mov")
PHOTO_EXTS=("jpg" "jpeg" "png" "heic" "raw" "cr2" "nef" "arw")
MUSIC_EXTS=("mp3" "flac" "wav" "aac")
ARCHIVE_EXTS=("zip" "rar" "7z" "tar")
DISK_EXTS=("iso" "dmg")
DOCUMENT_EXTS=("docx" "xlsx" "pptx" "pdf" "txt" "rtf")
DESIGN_EXTS=("psd" "obj" "fbx" "deb")

# Function to check if file extension matches category
check_extension() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    for e in "${VIDEO_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && VIDEO_FILES+=("$file") && return
    done
    
    for e in "${PHOTO_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && PHOTO_FILES+=("$file") && return
    done
    
    for e in "${MUSIC_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && MUSIC_FILES+=("$file") && return
    done
    
    for e in "${ARCHIVE_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && ARCHIVE_FILES+=("$file") && return
    done
    
    for e in "${DISK_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && DISK_FILES+=("$file") && return
    done
    
    for e in "${DOCUMENT_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && DOCUMENT_FILES+=("$file") && return
    done
    
    for e in "${DESIGN_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && DESIGN_FILES+=("$file") && return
    done
}

# Find all files
while IFS= read -r -d '' file; do
    check_extension "$file"
done < <(find "$SCAN_DIR" -type f -print0 2>/dev/null)

# Function to display files in a category
display_category() {
    local icon="$1"
    local color="$2"
    local title="$3"
    local -n files=$4
    
    if [ ${#files[@]} -gt 0 ]; then
        echo -e "\n${color}${BOLD}$icon $title (${#files[@]} files)${NC}"
        echo -e "${color}$(printf '─%.0s' {1..60})${NC}"
        
        for file in "${files[@]}"; do
            filename=$(basename "$file")
            filepath=$(dirname "$file")
            filesize=$(du -h "$file" 2>/dev/null | cut -f1)
            echo -e "${WHITE}  ├─${NC} ${color}${filename}${NC}"
            echo -e "${WHITE}  │  ${NC}${CYAN}Path:${NC} $filepath"
            echo -e "${WHITE}  │  ${NC}${CYAN}Size:${NC} $filesize"
        done
    fi
}

# Display all categories
display_category "$VIDEO_ICON" "$RED" "VIDEO FILES" VIDEO_FILES
display_category "$PHOTO_ICON" "$GREEN" "PHOTO FILES" PHOTO_FILES
display_category "$MUSIC_ICON" "$MAGENTA" "MUSIC FILES" MUSIC_FILES
display_category "$ARCHIVE_ICON" "$YELLOW" "ARCHIVE FILES" ARCHIVE_FILES
display_category "$DISK_ICON" "$BLUE" "DISK IMAGE FILES" DISK_FILES
display_category "$DOCUMENT_ICON" "$CYAN" "DOCUMENT FILES" DOCUMENT_FILES
display_category "$DESIGN_ICON" "$WHITE" "DESIGN FILES" DESIGN_FILES

# Summary
TOTAL=$((${#VIDEO_FILES[@]} + ${#PHOTO_FILES[@]} + ${#MUSIC_FILES[@]} + ${#ARCHIVE_FILES[@]} + ${#DISK_FILES[@]} + ${#DOCUMENT_FILES[@]} + ${#DESIGN_FILES[@]}))

echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║              SCAN COMPLETE                     ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo -e "${BOLD}Total files found: ${GREEN}$TOTAL${NC}\n"

if [ $TOTAL -eq 0 ]; then
    echo -e "${YELLOW}No files found to organize.${NC}"
    exit 0
fi

# Ask user if they want to organize
echo -e "${BOLD}${YELLOW}Would you like to move these files into organized folders?${NC}"
echo -e "${WHITE}This will create the following structure in your external drive:${NC}"
echo -e "  ${RED}├─ Videos/${NC}"
echo -e "  ${GREEN}├─ Photos/${NC}"
echo -e "  ${MAGENTA}├─ Music/${NC}"
echo -e "  ${YELLOW}├─ Archives/${NC}"
echo -e "  ${BLUE}├─ DiskImages/${NC}"
echo -e "  ${CYAN}├─ Documents/${NC}"
echo -e "  ${WHITE}└─ Design/${NC}"
echo ""

# Function to detect external drives
detect_external_drives() {
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║        DETECTING EXTERNAL DRIVES...           ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════╝${NC}\n"
    
    declare -a DRIVES
    declare -a DRIVE_NAMES
    declare -a DRIVE_SIZES
    declare -a DRIVE_USED
    declare -a DRIVE_AVAIL
    
    # Detect mounted drives (excluding system partitions)
    while IFS= read -r line; do
        device=$(echo "$line" | awk '{print $1}')
        mountpoint=$(echo "$line" | awk '{print $NF}')
        
        # Skip system partitions and special filesystems
        if [[ "$mountpoint" == "/" || "$mountpoint" == "/boot"* || "$mountpoint" == "/home" || 
              "$mountpoint" == "/snap"* || "$mountpoint" == "/sys"* || "$mountpoint" == "/dev"* ||
              "$mountpoint" == "/run"* || "$mountpoint" == "/tmp" || "$mountpoint" == "/var"* ]]; then
            continue
        fi
        
        # Get drive info
        size=$(df -h "$mountpoint" | tail -1 | awk '{print $2}')
        used=$(df -h "$mountpoint" | tail -1 | awk '{print $3}')
        avail=$(df -h "$mountpoint" | tail -1 | awk '{print $4}')
        use_percent=$(df -h "$mountpoint" | tail -1 | awk '{print $5}')
        
        # Get drive label if available
        label=$(lsblk -no LABEL "$device" 2>/dev/null | head -1)
        if [ -z "$label" ]; then
            label=$(basename "$mountpoint")
        fi
        
        DRIVES+=("$mountpoint")
        DRIVE_NAMES+=("$label")
        DRIVE_SIZES+=("$size")
        DRIVE_USED+=("$used ($use_percent)")
        DRIVE_AVAIL+=("$avail")
        
    done < <(df -h | grep "^/dev/" | grep -v "loop")
    
    if [ ${#DRIVES[@]} -eq 0 ]; then
        echo -e "${RED}No external drives detected!${NC}"
        echo -e "${YELLOW}Please enter the path manually.${NC}\n"
        read -p "$(echo -e ${BOLD}${GREEN}"Enter destination path: "${NC})" DEST_DIR
        return
    fi
    
    # Display drives in eye candy format
    echo -e "${BOLD}${WHITE}Available Drives:${NC}\n"
    
    for i in "${!DRIVES[@]}"; do
        num=$((i + 1))
        
        # Choose icon based on drive type
        if [[ "${DRIVES[$i]}" == *"usb"* || "${DRIVES[$i]}" == *"media"* ]]; then
            icon="💾"
        else
            icon="🖴"
        fi
        
        # Color based on available space percentage
        use_num=$(echo "${DRIVE_USED[$i]}" | grep -oP '\d+(?=%)')
        if [ "$use_num" -lt 50 ]; then
            bar_color="$GREEN"
        elif [ "$use_num" -lt 80 ]; then
            bar_color="$YELLOW"
        else
            bar_color="$RED"
        fi
        
        # Create usage bar
        filled=$((use_num / 5))
        empty=$((20 - filled))
        bar="${bar_color}$(printf '█%.0s' $(seq 1 $filled))${NC}$(printf '░%.0s' $(seq 1 $empty))"
        
        echo -e "${BOLD}${CYAN}[$num]${NC} $icon  ${BOLD}${WHITE}${DRIVE_NAMES[$i]}${NC}"
        echo -e "     ${CYAN}Path:${NC}      ${DRIVES[$i]}"
        echo -e "     ${CYAN}Size:${NC}      ${DRIVE_SIZES[$i]}"
        echo -e "     ${CYAN}Used:${NC}      ${DRIVE_USED[$i]}"
        echo -e "     ${CYAN}Available:${NC} ${GREEN}${DRIVE_AVAIL[$i]}${NC}"
        echo -e "     ${CYAN}Usage:${NC}     [$bar${NC}] $use_num%"
        echo ""
    done
    
    echo -e "${BOLD}${CYAN}[0]${NC} 🔧  ${BOLD}Enter custom path${NC}\n"
    
    # Ask user to choose
    read -p "$(echo -e ${BOLD}${YELLOW}"Select a drive (0-$((${#DRIVES[@]}))): "${NC})" choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#DRIVES[@]}" ]; then
        DEST_DIR="${DRIVES[$((choice - 1))]}"
        echo -e "${GREEN}Selected: ${BOLD}$DEST_DIR${NC}"
    elif [ "$choice" = "0" ]; then
        read -p "$(echo -e ${BOLD}${GREEN}"Enter destination path: "${NC})" DEST_DIR
    else
        echo -e "${RED}Invalid selection!${NC}"
        exit 1
    fi
}

# Call the function to detect drives
detect_external_drives

if [ -z "$DEST_DIR" ]; then
    echo -e "${RED}No destination provided. Exiting.${NC}"
    exit 0
fi

if [ ! -d "$DEST_DIR" ]; then
    echo -e "${RED}Error: Destination directory does not exist!${NC}"
    exit 1
fi

read -p "$(echo -e ${BOLD}${YELLOW}"Proceed with moving files? (yes/no): "${NC})" CONFIRM

if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi

# Function to move files
move_files() {
    local folder="$1"
    local -n file_array=$2
    
    if [ ${#file_array[@]} -gt 0 ]; then
        mkdir -p "$DEST_DIR/$folder"
        echo -e "\n${CYAN}Moving files to ${BOLD}$folder${NC}${CYAN}...${NC}"
        
        for file in "${file_array[@]}"; do
            filename=$(basename "$file")
            echo -e "  ${GREEN}✓${NC} Moving: $filename"
            mv "$file" "$DEST_DIR/$folder/" 2>/dev/null
        done
    fi
}

# Move all files
move_files "Videos" VIDEO_FILES
move_files "Photos" PHOTO_FILES
move_files "Music" MUSIC_FILES
move_files "Archives" ARCHIVE_FILES
move_files "DiskImages" DISK_FILES
move_files "Documents" DOCUMENT_FILES
move_files "Design" DESIGN_FILES

echo -e "\n${BOLD}${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║          FILES ORGANIZED SUCCESSFULLY!         ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}All files have been moved to: ${BOLD}$DEST_DIR${NC}\n"
