#!/bin/bash

# 🛑 အဓိက Script ရဲ့ Raw URL (သင့်ရဲ့ code logic ပါတဲ့ဖိုင်)
# ဒီနေရာကို သင့်ရဲ့ GitHub Raw URL နဲ့ အစားထိုးပါ
MAIN_SCRIPT_URL="https://raw.githubusercontent.com/KP-CHANNEL-KP/gcp-vless-2/refs/heads/main/gcp-cloud-run.sh"

# 1. သက်တမ်းကုန်ဆုံးရက်ကို Command Line Argument မှ လက်ခံရယူခြင်း
EXPIRY_DATE="$1"

# Input မပေးရင် စစ်ဆေးခြင်း
if [ -z "$EXPIRY_DATE" ]; then
    echo "🚨 ERROR: သက်တမ်းကုန်ဆုံးမည့်ရက်စွဲ (YYYY-MM-DD) ကို ထည့်သွင်းပေးပါ။"
    echo "Usage: bash <(curl -Ls YOUR_LAUNCHER_URL) YYYY-MM-DD"
    exit 1
fi

# 2. လက်ရှိနေ့စွဲ ရယူခြင်း
CURRENT_DATE=$(date +%Y-%m-%d)

echo "--- VLESS Deployment Script Loader ---"
echo "📅 လက်ရှိနေ့စွဲ: $CURRENT_DATE"
echo "🛑 သတ်မှတ်ထားသော သုံးစွဲခွင့်ကုန်ဆုံးမည့်ရက်: $EXPIRY_DATE"
echo "--------------------------------------"

# 3. ရက်စွဲ နှိုင်းယှဉ်စစ်ဆေးခြင်း
# လက်ရှိရက်စွဲသည် သတ်မှတ်ရက်ထက် ကျော်လွန်နေပါက (e.g., 2025-11-10 > 2025-11-09)
if [[ "$CURRENT_DATE" > "$EXPIRY_DATE" ]]; then
    
    # ❌ သက်တမ်းကုန်ဆုံးသွားပြီ
    echo "🚨 ACCESS DENIED: သတ်မှတ်ထားသော သုံးစွဲခွင့်သက်တမ်း ($EXPIRY_DATE) ကုန်ဆုံးသွားပါပြီ။"
    echo "❌ ဆက်လက်လုပ်ဆောင်ခြင်းကို ရပ်ဆိုင်းလိုက်ပါပြီ။"
    exit 1

else
    
    # ✅ သက်တမ်းရှိနေဆဲ
    echo "🎉 သုံးစွဲခွင့်ရှိပါသေးသည်။ မူရင်း Deployment Script ကို ခေါ်ယူပါမည်..."
    
    # 4. မူရင်း Script ကို ခေါ်ယူပြီး Run ခြင်း
    bash <(curl -Ls $MAIN_SCRIPT_URL)
    
    echo "--------------------------------------"
    echo "⚙️ Initialization လုပ်ငန်းစဉ် ပြီးဆုံးပါပြီ။"
fi
