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

# 3. EXPIRY DATE ရဲ့ နောက်တစ်နေ့ကို တွက်ချက်ခြင်း (Expiry Date ပြီးမှသာ Block လုပ်ရန်)
# ဥပမာ: EXPIRY_DATE က 2025-11-10 ဆိုရင်, EXPIRY_CHECK_DATE က 2025-11-11 ဖြစ်ရမယ်
# GNU date ကိုသုံးပြီး နောက်တစ်ရက်တွက်ချက် (Cloud Shell တွင် အများအားဖြင့် ရနိုင်သည်)
EXPIRY_CHECK_DATE=$(date -d "$EXPIRY_DATE + 1 day" +%Y-%m-%d 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$EXPIRY_CHECK_DATE" ]; then
    echo "🚨 CONFIGURATION ERROR: Cannot calculate expiry check date."
    exit 1
fi


echo "🔑 Key: $USER_KEY"
echo "📅 To Day: $CURRENT_DATE"
echo "🛑 Exp Date (Final Check): $EXPIRY_CHECK_DATE"
echo "--------------------------------------"


# 4. နှိုင်းယှဉ်ခြင်း: ယနေ့ရက်စွဲသည် သက်တမ်းကုန်ဆုံးရက်ရဲ့ နောက်တစ်ရက်ထက် ကြီးနေပြီဆိုရင် Block
# ဥပမာ: CURRENT_DATE=2025-11-11, EXPIRY_CHECK_DATE=2025-11-11
# 11-11 > 11-11 is FALSE. -> Access Allowed (11 ရက်နေ့ တစ်ရက်လုံးရသေးသည်)
# ဥပမာ: CURRENT_DATE=2025-11-12, EXPIRY_CHECK_DATE=2025-11-11
# 11-12 > 11-11 is TRUE. -> ACCESS DENIED (11 ရက်နေ့ ညသန်းခေါင်ကျော်သွားပြီ)
if [[ "$CURRENT_DATE" > "$EXPIRY_CHECK_DATE" ]]; then
    
    
    echo "🚨 ACCESS DENIED: Access has expired ($EXPIRY_DATE)."
    exit 1

else
    
    
    echo "🎉 Access is still available. The default deployment script will be invoked and run..."
    
    
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization The process is complete."
fi
