import os

# نام فایل خروجی
output_file = 'combined_output.mq5'

# باز کردن فایل خروجی برای نوشتن
with open(output_file, 'w', encoding='utf-8') as outfile:
    # هدر کلی
    outfile.write("//+------------------------------------------------------------------+\n")
    outfile.write("//| Combined Code Files                                              |\n")
    outfile.write("//+------------------------------------------------------------------+\n\n")

    # پیمایش تمام فایل‌ها در دایرکتوری و زیر دایرکتوری‌ها
    for root, dirs, files in os.walk("."):
        for file in files:
            # فقط فایل‌های با پسوند mq5 و mqh
            if file.endswith(('.mq5', '.mqh')):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as infile:
                        outfile.write(f"\n// --- Start of {file} ---\n\n")
                        outfile.write(infile.read())
                        outfile.write(f"\n// --- End of {file} ---\n\n")
                except Exception as e:
                    print(f"خطا در خواندن فایل: {file_path}. پیام خطا: {e}")

print(f"تمام فایل‌ها به {output_file} ترکیب شده‌اند.")
