#!/bin/bash

# ==========================================================
# ⚠️ 1. ပြင်ဆင်ရန် - MAIN SCRIPT (gcp-cloud-run.sh) ၏ URL
# ==========================================================
# URL ကို ရိုးရှင်းသော main branch ပုံစံသို့ ပြောင်းထားသည်
MAIN_SCRIPT_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/main/gcp-cloud-run.sh"

# ==========================================================
# ⚠️ 2. ပြင်ဆင်ရန် - EXPIRY LIST (user_expiry_list.txt) ၏ URL
# ==========================================================
# ဒီနေရာကို သင့်ရဲ့ user_expiry_list.txt ဖိုင်ရဲ့ RAW URL နဲ့ အစားထိုးပါ
EXPIRY_LIST_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/main/user_expiry_list.txt" 
# (အကယ်၍ သင့်ဖိုင်က gist မှာ ရှိပါက URL ကို ပြောင်းလဲပေးပါ။)

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
# စာရင်းဖိုင်ကို ယူ၊ Key ကို ရှာ (grep -w: exact match အတွက်)၊ Date ကို ယူ (awk)
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

# 4. ရက်စွဲ နှိုင်းယှဉ်စစ်ဆေးခြင်း (Cloud Shell နှင့် အသင့်တော်ဆုံး String Comparison)
if [[ "$CURRENT_DATE" > "$EXPIRY_DATE" ]]; then
    
    # ❌ သက်တမ်းကုန်ဆုံးသွားလျှင်
    echo "🚨 ACCESS DENIED: သုံးစွဲခွင့်သက်တမ်း ($EXPIRY_DATE) ကုန်ဆုံးသွားပါပြီ။"
    exit 1

else
    
    # ✅ သက်တမ်းရှိနေဆဲ - မူရင်း Script ကို ခေါ်ယူပြီး Run ခြင်း
    echo "🎉 သုံးစွဲခွင့်ရှိပါသေးသည်။ မူရင်း Deployment Script ကို ခေါ်ယူပြီး လုပ်ဆောင်ပါမည်..."
    
    # curl ဖြင့် မူရင်း script ကို ရယူပြီး bash ဖြင့် run ခြင်း
    # Cloud Shell မှာ အလုပ်လုပ်ကြောင်း အတည်ပြုပြီးသား ဖြစ်သည့် ပုံစံဖြင့် ခေါ်ယူသည်။
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization လုပ်ငန်းစဉ် ပြီးဆုံးပါပြီ။"
fi
