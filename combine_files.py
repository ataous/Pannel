import os

# نام فایل خروجی
output_file = 'combined_output.txt'

# باز کردن فایل خروجی برای نوشتن
with open(output_file, 'w') as outfile:
    # پیمایش تمام فایل‌ها در دایرکتوری و زیر دایرکتوری‌ها
    for root, dirs, files in os.walk("."):
        for file in files:
            file_path = os.path.join(root, file)
            # فقط فایل‌ها را پردازش می‌کنیم و دایرکتوری‌ها را نادیده می‌گیریم
            if os.path.isfile(file_path):
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as infile:
                    outfile.write(f"\n# --- Start of {file_path} ---\n\n")
                    outfile.write(infile.read())
                    outfile.write(f"\n# --- End of {file_path} ---\n\n")

print(f"تمام فایل‌ها به {output_file} ترکیب شده‌اند")
