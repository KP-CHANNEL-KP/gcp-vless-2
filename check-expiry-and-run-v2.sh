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
# (ယနေ့ မြန်မာပြည် အချိန် ဘယ်လောက်ရှိပြီလဲ)
# Timezone ကို Asia/Yangon ဖြင့် သတ်မှတ်ပါသည်။
CURRENT_TIMESTAMP=$(TZ="Asia/Yangon" date +%s)
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# 3. EXPIRY DATE ကို Singapore Time (SGT) ဖြင့် Unix Timestamp ယူခြင်း
# သက်တမ်းကုန်ဆုံးရက်ရဲ့ ည ၁၁:၅၉:၅၉ (Singapore Time) အဖြစ် သတ်မှတ်သည်။
# Timezone ကို Asia/Singapore ဖြင့် သတ်မှတ်ပါသည်။
# ဥပမာ: 2025-11-10 SGT 23:59:59 (MMT 11 ရက်နေ့ ညသန်းခေါင်ကျော်သွားသည်)
EXPIRY_TIMESTAMP=$(TZ="Asia/Singapore" date -d "$EXPIRY_DATE_STR 23:59:59" +%s 2>/dev/null)
# ----------------------------------------------------------------------


if [ $? -ne 0 ] || [ -z "$EXPIRY_TIMESTAMP" ]; then
    echo "🚨 CONFIGURATION ERROR: Invalid date format or date command failed."
    exit 1
fi

# အချက်အလက်ပြသခြင်း (Display Info)
echo "🔑 Key: $USER_KEY"
echo "🇲🇲 Current Time Stamp (MMT): $CURRENT_TIMESTAMP"
echo "🇸🇬 Exp Time Stamp (SGT End of Day): $EXPIRY_TIMESTAMP"
echo "--------------------------------------"


# 4. နှိုင်းယှဉ်ခြင်း: MMT လက်ရှိအချိန်က SGT Expiry Time ထက် ပိုကြီးနေပြီဆိုရင် Block
# (ဆိုလိုသည်မှာ SGT ဖြင့် သတ်မှတ်ထားသော သက်တမ်းကုန်ဆုံးချိန် ကျော်လွန်သွားပြီ)
if [[ "$CURRENT_TIMESTAMP" -gt "$EXPIRY_TIMESTAMP" ]]; then
    
    
    echo "🚨 ACCESS DENIED: Access has expired (SGT)."
    exit 1

else
    
    
    echo "🎉 Access is still available. The default deployment script will be invoked and run..."
    
    
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization The process is complete."
fi
