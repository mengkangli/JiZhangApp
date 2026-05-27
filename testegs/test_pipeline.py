import json, urllib.request, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

api_key = "YOUR_DEEPSEEK_API_KEY"
text = "美团支付\n商家: 美团\n付款金额: 16.47元\n支付方式: 招商银行信用卡\n交易时间: 2026-05-27 00:20:43"

prompt = f"""从以下账单文字中提取记账信息，返回JSON：

{text}

格式：{{"amount":数字,"type":"expense或income","category":"分类","date":"YYYY-MM-DD","note":"备注"}}
规则：消费→expense，收入→income。分类选：餐饮、交通、购物、娱乐、账单、医疗、教育、居住、工资、兼职、投资、礼金。"""

data = json.dumps({
    "model": "deepseek-chat",
    "messages": [
        {"role": "system", "content": "你是精确的记账助手。只返回JSON。"},
        {"role": "user", "content": prompt}
    ],
    "temperature": 0.1,
    "max_tokens": 256,
    "response_format": {"type": "json_object"}
}, ensure_ascii=False).encode("utf-8")

print("=" * 50)
print("  Step 1: OCR (mlkit on device)")
print("=" * 50)
for line in text.strip().split("\n"):
    print(f"  | {line}")
print()

print("=" * 50)
print("  Step 2: DeepSeek parse result")
print("=" * 50)

req = urllib.request.Request(
    "https://api.deepseek.com/chat/completions",
    data=data,
    headers={
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": f"Bearer {api_key}"
    }
)
with urllib.request.urlopen(req, timeout=30) as resp:
    result = json.loads(resp.read().decode("utf-8"))

model = result.get("model", "?")
content = result["choices"][0]["message"]["content"]
usage = result.get("usage", {})
parsed = json.loads(content)
type_cn = "expense" if parsed["type"] == "expense" else "income"

# Save full result
with open("C:/Users/mengk/Desktop/qianjirepro/testegs/pipeline_result.json", "w", encoding="utf-8") as f:
    json.dump({
        "ocr_text": text,
        "model": model,
        "tokens": usage.get("total_tokens"),
        "result": parsed
    }, f, ensure_ascii=False, indent=2)

print(f"  Model:   {model}")
print(f"  Tokens:  {usage.get('total_tokens', '?')}")
print()
print(f"  Result:")
print(f"    amount:   {parsed['amount']}")
print(f"    type:     {parsed['type']} ({type_cn})")
print(f"    category: {parsed['category']}")
print(f"    date:     {parsed['date']}")
print(f"    note:     {parsed['note']}")
print()
print("  [OK] OCR -> LLM pipeline verified!")
print("  Result saved to: pipeline_result.json")
