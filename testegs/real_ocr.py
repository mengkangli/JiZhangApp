import sys, io, json
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

print("Loading PaddleOCR...")
from paddleocr import PaddleOCR

print("Initializing OCR engine (Chinese + English)...")
ocr = PaddleOCR(lang='ch')

img = r"C:\Users\mengk\Desktop\qianjirepro\testegs\meituanpay.jpg"
print(f"Running OCR on: {img}")
print()

results = ocr.ocr(img)

print("=" * 60)
print("  REAL OCR OUTPUT (PaddleOCR)")
print("=" * 60)

all_text = []
for page in results:
    if page is None:
        continue
    for line in page:
        bbox = line[0]
        text = line[1][0]
        confidence = line[1][1]
        all_text.append(text)
        print(f"  [{confidence:.2f}] {text}")

print()
print("=" * 60)
print("  FULL TEXT:")
print("=" * 60)
full = ' '.join(all_text)
print(f"  {full}")

# Save to file for pipeline
with open(r"C:\Users\mengk\Desktop\qianjirepro\testegs\ocr_output.txt", "w", encoding="utf-8") as f:
    f.write(full)

print()
print(f"  Saved to ocr_output.txt ({len(all_text)} text segments)")
