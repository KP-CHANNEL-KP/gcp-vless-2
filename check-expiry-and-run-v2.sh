#!/bin/bash

# --- URL Definitions ---
MAIN_SCRIPT_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/main/gcp-cloud-run.sh"
EXPIRY_LIST_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/main/user_expiry_list.txt" 
USER_KEY="$1"

if [ -z "$USER_KEY" ]; then
    echo "🚨 ERROR: Enter User Key."
    echo "Usage: bash <(curl -Ls YOUR_LAUNCHER_URL) [USER_KEY]"
    exit 1
fi

echo "--- VLESS Deployment Script Loader ---"


# 1. EXPIRY DATE ကို ဆွဲယူခြင်း
EXPIRY_DATE_STR=$(curl -Ls $EXPIRY_LIST_URL | grep -w "$USER_KEY" | awk '{print $2}')


if [ -z "$EXPIRY_DATE_STR" ]; then
    echo "🚨 ERROR: The specified key ($USER_KEY) is not in the access list."
    exit 1
fi

# ----------------------------------------------------------------------
# 2. လက်ရှိအချိန်ကို Myanmar Time (MMT) ဖြင့် Unix Timestamp (စက္ကန့်) ယူခြင်း
CURRENT_TIMESTAMP=$(TZ="Asia/Yangon" date +%s)
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# 3. EXPIRY DATE ကို Singapore Time (SGT) ဖြင့် Unix Timestamp ယူခြင်း
EXPIRY_TIMESTAMP=$(TZ="Asia/Singapore" date -d "$EXPIRY_DATE_STR 23:59:59" +%s 2>/dev/null)
# ----------------------------------------------------------------------


if [ $? -ne 0 ] || [ -z "$EXPIRY_TIMESTAMP" ]; then
    echo "🚨 CONFIGURATION ERROR: Invalid date format or date command failed."
    exit 1
fi

# ----------------------------------------------------------------------
# 4. TIMESTAMP များကို လူဖတ်နိုင်သော စာသားအဖြစ် ပြန်ပြောင်းလဲခြင်း (Display Info အတွက်)
# ----------------------------------------------------------------------
# MMT ဖြင့် လက်ရှိနေ့စွဲ၊ အချိန်နှင့် Timezone ကို ဖော်ပြခြင်း
CURRENT_DATE_MMT=$(TZ="Asia/Yangon" date -d "@$CURRENT_TIMESTAMP" +"%Y-%m-%d %H:%M:%S MMT")

# SGT ဖြင့် သက်တမ်းကုန်ဆုံးမည့် အချိန်နှင့် Timezone ကို ဖော်ပြခြင်း
EXPIRY_DATE_SGT=$(TZ="Asia/Singapore" date -d "@$EXPIRY_TIMESTAMP" +"%Y-%m-%d %H:%M:%S SGT")


# အချက်အလက်ပြသခြင်း (Display Info)
echo "🔑 Key: $USER_KEY"
echo "🕒 Current Time: $CURRENT_DATE_MMT"
echo "🛑 Expire On:    $EXPIRY_DATE_SGT"
echo "--------------------------------------"


# 5. နှိုင်းယှဉ်ခြင်း (Logic သည် အရင်အတိုင်း တိကျမှု ရှိနေသည်)
if [[ "$CURRENT_TIMESTAMP" -gt "$EXPIRY_TIMESTAMP" ]]; then
    
    
    echo "🚨 ACCESS DENIED: Access has expired (SGT)."
    exit 1

else
    
    
    echo "🎉 Access is still available. The default deployment script will be invoked and run..."
    
    
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization The process is complete."
fi
