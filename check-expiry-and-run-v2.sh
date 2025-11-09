#!/bin/bash

# ==========================================================
# ⚠️ 1. ပြင်ဆင်ရန် - MAIN SCRIPT (Logic ပါသောဖိုင်) ၏ URL
# ==========================================================
# ဒီနေရာမှာ သင့်ရဲ့ လျှို့ဝှက်ထားချင်တဲ့ gcp-cloud-run.sh ဖိုင်ရဲ့ RAW URL ကို ထည့်ပါ။
MAIN_SCRIPT_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/refs/heads/main/gcp-cloud-run.sh"

# ==========================================================
# ⚠️ 2. ပြင်ဆင်ရန် - EXPIRY LIST (Key, Date ပါသောဖိုင်) ၏ URL
# ==========================================================
# ဒီနေရာမှာ သင့်ရဲ့ user_expiry_list.txt ဖိုင်ကို တင်ထားသော RAW URL ကို ထည့်ပါ။
EXPIRY_LIST_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/refs/heads/main/user_expiry_list.txt"

# ----------------------------------------------------------

# 1. User Key ကို Command Line Argument မှ လက်ခံရယူခြင်း
USER_KEY="$1"

# Input မပေးရင် စစ်ဆေးခြင်း
if [ -z "$USER_KEY" ]; then
    echo "🚨 ERROR: သုံးစွဲသူ Key ကို ထည့်သွင်းပေးပါ။"
    echo "Usage: bash <(curl -Ls YOUR_LAUNCHER_URL) [USER_KEY]"
    exit 1
fi

echo "--- VLESS Deployment Script Loader ---"

# 2. Online စာရင်းမှ သက်ဆိုင်ရာ Expiry Date ကို ရှာဖွေခြင်း
# (သင့်ရဲ့ list ပုံစံ user_expiry_list.txt ပေါ်မူတည်ပြီး awk command ပြောင်းလဲနိုင်သည်)
EXPIRY_DATE=$(curl -Ls $EXPIRY_LIST_URL | grep -w "$USER_KEY" | awk '{print $2}')

# Key ကို စာရင်းထဲတွင် မတွေ့လျှင် Error ပြရန်
if [ -z "$EXPIRY_DATE" ]; then
    echo "🚨 ERROR: သတ်မှတ်ထားသော Key ($USER_KEY) သည် သုံးစွဲခွင့် စာရင်းထဲတွင် မရှိပါ။"
    exit 1
fi

# 3. လက်ရှိနေ့စွဲ ရယူခြင်း
CURRENT_DATE=$(date +%Y-%m-%d)

echo "🔑 Key: $USER_KEY"
echo "📅 လက်ရှိနေ့စွဲ: $CURRENT_DATE"
echo "🛑 စာရင်းရှိ သက်တမ်းကုန်ဆုံးမည့်ရက်: $EXPIRY_DATE"
echo "--------------------------------------"

# 4. ရက်စွဲများကို စက္ကန့် (Timestamp) ပုံစံသို့ ပြောင်းပြီး နှိုင်းယှဉ်စစ်ဆေးခြင်း
# ၎င်းသည် string ဖြင့် နှိုင်းယှဉ်ခြင်းထက် ပိုမိုတိကျသော နည်းလမ်းဖြစ်သည်။
CURRENT_SEC=$(date -d "$CURRENT_DATE" +%s)
EXPIRY_SEC=$(date -d "$EXPIRY_DATE" +%s)

# လက်ရှိ စက္ကန့်အရေအတွက်သည် ကုန်ဆုံးရက်၏ စက္ကန့်အရေအတွက်ထက် ကြီးနေပါက (ကျော်လွန်နေပါက)
if [ "$CURRENT_SEC" -gt "$EXPIRY_SEC" ]; then
    
    # ❌ သက်တမ်းကုန်ဆုံးသွားလျှင်
    echo "🚨 ACCESS DENIED: သုံးစွဲခွင့်သက်တမ်း ($EXPIRY_DATE) ကုန်ဆုံးသွားပါပြီ။"
    exit 1

else
    
    # ✅ သက်တမ်းရှိနေဆဲ - မူရင်း Script ကို ခေါ်ယူပြီး Run ခြင်း
    echo "🎉 သုံးစွဲခွင့်ရှိပါသေးသည်။ မူရင်း Deployment Script ကို ခေါ်ယူပြီး လုပ်ဆောင်ပါမည်..."
    
    # curl ဖြင့် မူရင်း script ကို ရယူပြီး bash ဖြင့် run ခြင်း
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization လုပ်ငန်းစဉ် ပြီးဆုံးပါပြီ။"
fi
