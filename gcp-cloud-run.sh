#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Logging Functions ---
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# --- Validation Functions ---
validate_uuid() {
    local uuid_pattern='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    if [[ ! $1 =~ $uuid_pattern ]]; then
        error "Invalid UUID format: $1"
        return 1
    fi
    return 0
}

validate_bot_token() {
    local token_pattern='^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$'
    if [[ ! $1 =~ $token_pattern ]]; then
        error "Invalid Telegram Bot Token format"
        return 1
    fi
    return 0
}

validate_channel_id() {
    if [[ ! $1 =~ ^-?[0-9]+$ ]]; then
        error "Invalid Channel ID format"
        return 1
    fi
    return 0
}

validate_chat_id() {
    if [[ ! $1 =~ ^-?[0-9]+$ ]]; then
        error "Invalid Chat ID format"
        return 1
    fi
    return 0
}

# --- Configuration/Selection Functions ---

# CPU selection function
select_cpu() {
    echo
    info "=== CPU Configuration ==="
    echo "1. 1 CPU Core"
    echo "2. 2 CPU Cores"
    echo "3. 4 CPU Cores"
    echo "4. 8 CPU Cores (Default)" 
    echo
    
    while true; do
        read -p "Select CPU cores (1-4, or Enter for Default 4): " cpu_choice
        # Enter နှိပ်ပါက ပုံသေတန်ဖိုး 4
        cpu_choice=${cpu_choice:-"4"}
        
        case $cpu_choice in
            1) CPU="1"; break ;;
            2) CPU="2"; break ;;
            3) CPU="4"; break ;;
            4) CPU="8"; break ;;
            *) echo "Invalid selection. Please enter a number between 1-4." ;;
        esac
    done
    
    info "Selected CPU: $CPU core(s)"
}

# Memory selection function
select_memory() {
    echo
    info "=== Memory Configuration ==="
    
    # Show recommended memory based on CPU selection
    case $CPU in
        1) echo "Recommended memory: 512Mi - 2Gi" ;;
        2) echo "Recommended memory: 1Gi - 4Gi" ;;
        4) echo "Recommended memory: 2Gi - 8Gi" ;;
        8) echo "Recommended memory: 4Gi - 16Gi" ;;
    esac
    echo
    
    echo "Memory Options:"
    echo "1. 512Mi"
    echo "2. 1Gi"
    echo "3. 2Gi"
    echo "4. 4Gi"
    echo "5. 8Gi"
    echo "6. 16Gi (Default)" 
    echo
    
    while true; do
        read -p "Select memory (1-6, or Enter for Default 6): " memory_choice
        # Enter နှိပ်ပါက ပုံသေတန်ဖိုး 6
        memory_choice=${memory_choice:-"6"}
        
        case $memory_choice in
            1) MEMORY="512Mi"; break ;;
            2) MEMORY="1Gi"; break ;;
            3) MEMORY="2Gi"; break ;;
            4) MEMORY="4Gi"; break ;;
            5) MEMORY="8Gi"; break ;;
            6) MEMORY="16Gi"; break ;;
            *) echo "Invalid selection. Please enter a number between 1-6." ;;
        esac
    done
    
    # Validate memory configuration
    validate_memory_config
    
    info "Selected Memory: $MEMORY"
}

# Validate memory configuration based on CPU (unchanged)
validate_memory_config() {
    local cpu_num=$CPU
    local memory_num=$(echo $MEMORY | sed 's/[^0-9]*//g')
    local memory_unit=$(echo $MEMORY | sed 's/[0-9]*//g')
    
    if [[ "$memory_unit" == "Gi" ]]; then
        memory_num=$((memory_num * 1024))
    fi
    
    local min_memory=0
    local max_memory=0
    
    case $cpu_num in
        1) min_memory=512; max_memory=2048 ;;
        2) min_memory=1024; max_memory=4096 ;;
        4) min_memory=2048; max_memory=8192 ;;
        8) min_memory=4096; max_memory=16384 ;;
    esac
    
    if [[ $memory_num -lt $min_memory ]]; then
        warn "Memory configuration ($MEMORY) might be too low for $CPU CPU core(s)."
        warn "Recommended minimum: $((min_memory / 1024))Gi"
        read -p "Do you want to continue with this configuration? (y/n): " confirm
        if [[ ! $confirm =~ [Yy] ]]; then
            select_memory
        fi
    elif [[ $memory_num -gt $max_memory ]]; then
        warn "Memory configuration ($MEMORY) might be too high for $CPU CPU core(s)."
        warn "Recommended maximum: $((max_memory / 1024))Gi"
        read -p "Do you want to continue with this configuration? (y/n): " confirm
        if [[ ! $confirm =~ [Yy] ]]; then
            select_memory
        fi
    fi
}

# Region selection function
select_region() {
    echo
    info "=== Region Selection ==="
    echo "1. us-central1 (Iowa, USA) (Default)" 
    echo "2. us-west1 (Oregon, USA)" 
    echo "3. us-east1 (South Carolina, USA)"
    echo "4. europe-west1 (Belgium)"
    echo "5. asia-southeast1 (Singapore)"
    echo "6. asia-northeast1 (Tokyo, Japan)"
    echo "7. asia-east1 (Taiwan)"
    echo
    
    while true; do
        read -p "Select region (1-7, or Enter for Default 1): " region_choice
        # Enter နှိပ်ပါက ပုံသေတန်ဖိုး 1
        region_choice=${region_choice:-"1"}
        
        case $region_choice in
            1) REGION="us-central1"; break ;;
            2) REGION="us-west1"; break ;;
            3) REGION="us-east1"; break ;;
            4) REGION="europe-west1"; break ;;
            5) REGION="asia-southeast1"; break ;;
            6) REGION="asia-northeast1"; break ;;
            7) REGION="asia-east1"; break ;;
            *) echo "Invalid selection. Please enter a number between 1-7." ;;
        esac
    done
    
    info "Selected region: $REGION"
}

# Telegram destination selection
select_telegram_destination() {
    echo
    info "=== Telegram Destination ==="
    echo "1. Send to Channel only"
    echo "2. Send to Bot private message only (Default)" 
    echo "3. Send to both Channel and Bot"
    echo "4. Don't send to Telegram"
    echo
    
    # 📌 ပြင်ဆင်ထားသော ပုံသေ Channel ID နှင့် Chat ID
    local DEFAULT_CHANNEL_ID="-1002976467818" # Channel ID ပုံသေတန်ဖိုး အသစ်
    local DEFAULT_CHAT_ID="7070690379"    # Chat ID ပုံသေတန်ဖိုး
    
    while true; do
        read -p "Select destination (1-4, or Enter for Default 2): " telegram_choice
        # Enter နှိပ်ပါက ပုံသေတန်ဖိုး 2
        telegram_choice=${telegram_choice:-"2"}

        case $telegram_choice in
            1) 
                TELEGRAM_DESTINATION="channel"
                while true; do
                    # Channel ID ကို ပုံသေတန်ဖိုးဖြင့် မေးခြင်း
                    read -p "Enter Telegram Channel ID [default: ${DEFAULT_CHANNEL_ID}]: " CHANNEL_ID_INPUT
                    TELEGRAM_CHANNEL_ID=${CHANNEL_ID_INPUT:-"$DEFAULT_CHANNEL_ID"}

                    if validate_channel_id "$TELEGRAM_CHANNEL_ID"; then
                        break
                    fi
                done
                break 
                ;;
            2) 
                TELEGRAM_DESTINATION="bot"
                while true; do
                    read -p "Enter your Chat ID (for bot private message) [default: ${DEFAULT_CHAT_ID}]: " CHAT_ID_INPUT
                    # Enter နှိပ်ပါက Chat ID ပုံသေတန်ဖိုး
                    TELEGRAM_CHAT_ID=${CHAT_ID_INPUT:-"$DEFAULT_CHAT_ID"}
                    
                    if validate_chat_id "$TELEGRAM_CHAT_ID"; then
                        break
                    fi
                done
                break 
                ;;
            3) 
                TELEGRAM_DESTINATION="both"
                while true; do
                    # Channel ID ကို ပုံသေတန်ဖိုးဖြင့် မေးခြင်း
                    read -p "Enter Telegram Channel ID [default: ${DEFAULT_CHANNEL_ID}]: " CHANNEL_ID_INPUT
                    TELEGRAM_CHANNEL_ID=${CHANNEL_ID_INPUT:-"$DEFAULT_CHANNEL_ID"}

                    if validate_channel_id "$TELEGRAM_CHANNEL_ID"; then
                        break
                    fi
                done
                while true; do
                    # Chat ID ကို ပုံသေတန်ဖိုးဖြင့် မေးခြင်း
                    read -p "Enter your Chat ID (for bot private message) [default: ${DEFAULT_CHAT_ID}]: " CHAT_ID_INPUT
                    # Enter နှိပ်ပါက Chat ID ပုံသေတန်ဖိုး
                    TELEGRAM_CHAT_ID=${CHAT_ID_INPUT:-"$DEFAULT_CHAT_ID"}
                    
                    if validate_chat_id "$TELEGRAM_CHAT_ID"; then
                        break
                    fi
                done
                break 
                ;;
            4) 
                TELEGRAM_DESTINATION="none"
                break 
                ;;
            *) echo "Invalid selection. Please enter a number between 1-4." ;;
        esac
    done
}

# User input function
get_user_input() {
    echo
    info "=== Service Configuration ==="
    
    # Service Name
    local DEFAULT_SERVICE_NAME="kpchannel" # Service Name ပုံသေတန်ဖိုး
    while true; do
        read -p "Enter service name [default: ${DEFAULT_SERVICE_NAME}]: " SERVICE_NAME_INPUT
        # Enter နှိပ်ပါက Service Name ပုံသေတန်ဖိုး
        SERVICE_NAME=${SERVICE_NAME_INPUT:-"$DEFAULT_SERVICE_NAME"}
        
        if [[ -n "$SERVICE_NAME" ]]; then
            break
        else
            error "Service name cannot be empty"
        fi
    done
    
    # UUID
    local DEFAULT_UUID="9c910024-714e-4221-81c6-41ca9856e7ab"
    while true; do
        read -p "Enter UUID [default: ${DEFAULT_UUID}]: " UUID_INPUT
        UUID=${UUID_INPUT:-"$DEFAULT_UUID"}
        if validate_uuid "$UUID"; then
            break
        fi
    done
    
    # Telegram Bot Token (required for any Telegram option)
    if [[ "$TELEGRAM_DESTINATION" != "none" ]]; then
        local DEFAULT_BOT_TOKEN="8318171802:AAGh49s_ysQ-D84Cbht036QaLR1U4uT68RA" # Bot Token ပုံသေတန်ဖိုး
        while true; do
            # Bot Token ကို ဖုံးကွယ်ပြီး default တန်ဖိုးကို အမြည်းပြ
            read -s -p "Enter Telegram Bot Token [default: ${DEFAULT_BOT_TOKEN:0:10}...]: " BOT_TOKEN_INPUT
            echo # Newline after silent read

            # Enter နှိပ်ပါက Bot Token ပုံသေတန်ဖိုး
            TELEGRAM_BOT_TOKEN=${BOT_TOKEN_INPUT:-"$DEFAULT_BOT_TOKEN"}

            if validate_bot_token "$TELEGRAM_BOT_TOKEN"; then
                break
            fi
        done
    fi
    
    # Host Domain (optional)
    read -p "Enter host domain [default: m.googleapis.com]: " HOST_DOMAIN_INPUT
    HOST_DOMAIN=${HOST_DOMAIN_INPUT:-"m.googleapis.com"}
}

# Display configuration summary (Proceed with deployment default 'y')
show_config_summary() {
    echo
    info "=== Configuration Summary ==="
    echo "Project ID:    $(gcloud config get-value project)"
    echo "Region:        $REGION"
    echo "Service Name:  $SERVICE_NAME"
    echo "Host Domain:   $HOST_DOMAIN"
    echo "UUID:          $UUID"
    echo "CPU:           $CPU core(s)"
    echo "Memory:        $MEMORY"
    
    if [[ "$TELEGRAM_DESTINATION" != "none" ]]; then
        echo "Bot Token:     ${TELEGRAM_BOT_TOKEN:0:8}..."
        echo "Destination:   $TELEGRAM_DESTINATION"
        if [[ "$TELEGRAM_DESTINATION" == "channel" || "$TELEGRAM_DESTINATION" == "both" ]]; then
            echo "Channel ID:    $TELEGRAM_CHANNEL_ID"
        fi
        if [[ "$TELEGRAM_DESTINATION" == "bot" || "$TELEGRAM_DESTINATION" == "both" ]]; then
            echo "Chat ID:       $TELEGRAM_CHAT_ID"
        fi
    else
        echo "Telegram:
