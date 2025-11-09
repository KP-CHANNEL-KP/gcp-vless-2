#!/bin/bash

# 🛑 အဓိက Script URL
MAIN_SCRIPT_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/refs/heads/main/gcp-cloud-run.sh"

# 🔑 သုံးစွဲသူ စာရင်းဖိုင်ရဲ့ Raw URL (အဆင့် ၁ မှ ရလာသော Link)
EXPIRY_LIST_URL="သင့်ရဲ့ user_expiry_list.txt ဖိုင်ရဲ့ URL"

# 1. User Key ကို Input မှ လက်ခံရယူခြင်း
USER_KEY="$1"

# Input မပေးရင် စစ်ဆေးခြင်း
if [ -z "$USER_KEY" ]; then
    echo "🚨 ERROR: သုံးစွဲသူ Key ကို ထည့်သွင်းပေးပါ။"
    echo "Usage: bash <(curl -Ls YOUR_LAUNCHER_URL) USER_KEY"
    exit 1
fi

# 2. Online စာရင်းမှ သက်ဆိုင်ရာ Expiry Date ကို ရှာဖွေခြင်း
# (သင့်ရဲ့ list ပုံစံပေါ်မူတည်ပြီး `awk` command ပြောင်းလဲနိုင်သည်)
EXPIRY_DATE=$(curl -Ls $EXPIRY_LIST_URL | grep "$USER_KEY" | awk '{print $2}')

if [ -z "$EXPIRY_DATE" ]; then
    echo "🚨 ERROR: သတ်မှတ်ထားသော Key ($USER_KEY) ကို စာရင်းထဲတွင် မတွေ့ပါ။"
    exit 1
fi

# 3. လက်ရှိနေ့စွဲ ရယူခြင်း
CURRENT_DATE=$(date +%Y-%m-%d)

echo "--- VLESS Deployment Script Loader ---"
echo "🔑 Key: $USER_KEY"
echo "📅 လက်ရှိနေ့စွဲ: $CURRENT_DATE"
echo "🛑 စာရင်းရှိ သက်တမ်းကုန်ဆုံးမည့်ရက်: $EXPIRY_DATE"
echo "--------------------------------------"

# 4. ရက်စွဲ နှိုင်းယှဉ်စစ်ဆေးခြင်း
if [[ "$CURRENT_DATE" > "$EXPIRY_DATE" ]]; then
    echo "🚨 ACCESS DENIED: သုံးစွဲခွင့်သက်တမ်း ($EXPIRY_DATE) ကုန်ဆုံးသွားပါပြီ။"
    exit 1
else
    echo "🎉 သုံးစွဲခွင့်ရှိပါသေးသည်။ မူရင်း Deployment Script ကို ခေါ်ယူပါမည်..."
    bash <(curl -Ls $MAIN_SCRIPT_URL)
fi
