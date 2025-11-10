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
EXPIRY_DATE=$(curl -Ls $EXPIRY_LIST_URL | grep -w "$USER_KEY" | awk '{print $2}')


if [ -z "$EXPIRY_DATE" ]; then
    echo "🚨 ERROR: The specified key ($USER_KEY) is not in the access list."
    exit 1
fi


# 2. လက်ရှိရက်စွဲကို YYYY-MM-DD ပုံစံဖြင့် ယူခြင်း
CURRENT_DATE=$(date +%Y-%m-%d)

echo "🔑 Key: $USER_KEY"
echo "📅 To Day: $CURRENT_DATE"
echo "🛑 Exp Date: $EXPIRY_DATE"
echo "--------------------------------------"


# 3. String နှိုင်းယှဉ်ခြင်း (Bash တွင် Date String YYYY-MM-DD ကို မှန်ကန်စွာ နှိုင်းယှဉ်နိုင်သည်)
if [[ "$CURRENT_DATE" > "$EXPIRY_DATE" ]]; then
    
    
    echo "🚨 ACCESS DENIED: Access has expired ($EXPIRY_DATE)."
    exit 1

else
    
    
    echo "🎉 Access is still available. The default deployment script will be invoked and run..."
    
    
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization The process is complete."
fi
