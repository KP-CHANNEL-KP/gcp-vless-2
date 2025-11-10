#!/bin/bash


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


# 2. လက်ရှိရက်စွဲ နှင့် သက်တမ်းကုန်ဆုံးရက် တို့ကို Unix Timestamp (စက္ကန့်) အဖြစ် ပြောင်းလဲခြင်း

# လက်ရှိ စက္ကန့် (Today's Timestamp)
CURRENT_TIMESTAMP=$(date +%s)

# EXPIRY DATE ကို ည ၁၁:၅၉:၅၉ အဖြစ် သတ်မှတ်ခြင်း (End of Day) 
# ဒါမှသာ အဲဒီရက်ရဲ့ ညသန်းခေါင်ယံမှာ တိကျစွာ သက်တမ်းကုန်ဆုံးမယ်
EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE_STR 23:59:59" +%s 2>/dev/null)

# date -d command က Error ဖြစ်ခဲ့ရင် (e.g. မမှန်ကန်တဲ့ format ဆိုရင်) 
if [ $? -ne 0 ] || [ -z "$EXPIRY_TIMESTAMP" ]; then
    echo "🚨 CONFIGURATION ERROR: Invalid date format found for key $USER_KEY ($EXPIRY_DATE_STR)."
    exit 1
fi

echo "🔑 Key: $USER_KEY"
echo "📅 Current Time Stamp: $CURRENT_TIMESTAMP"
echo "🛑 Exp Time Stamp: $EXPIRY_TIMESTAMP"
echo "--------------------------------------"


# 3. Timestamp နှိုင်းယှဉ်ခြင်း
# လက်ရှိအချိန်က သက်တမ်းကုန်ဆုံးချိန်ထက် ပိုများနေပြီဆိုရင် Block
if [[ "$CURRENT_TIMESTAMP" -gt "$EXPIRY_TIMESTAMP" ]]; then
    
    
    echo "🚨 ACCESS DENIED: Access has expired ($EXPIRY_DATE_STR)."
    exit 1

else
    
    
    echo "🎉 Access is still available. The default deployment script will be invoked and run..."
    
    
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization The process is complete."
fi
