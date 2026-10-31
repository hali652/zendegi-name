# زندگی‌نامه — نسخه اولیه

این پروژه یک نمونه اولیه Flutter برای بازی شبیه‌ساز زندگی با رابط فارسی و راست‌چین است.

## ساخت APK بدون نصب Flutter روی کامپیوتر

در این بسته، فایل آماده GitHub Actions قرار دارد:
`.github/workflows/build-apk.yml`

1. وارد GitHub شوید و یک مخزن جدید (New repository) بسازید؛ نام پیشنهادی: `zendegi-nameh`.
2. فایل‌های داخل این پوشه را در مخزن بارگذاری کنید؛ حتماً پوشه `.github/workflows` نیز بارگذاری شود.
3. پس از ثبت فایل‌ها، از زبانه Actions اجرای `Build Android APK` را باز کنید. با `Run workflow` می‌توانید ساخت را شروع کنید.
4. پس از موفقیت، در صفحه اجرای Workflow بخش Artifacts فایل `zendegi-nameh-apk` را دانلود کنید. داخل ZIP دانلودی، فایل `app-release.apk` قرار دارد.

ساخت APK روی سرورهای GitHub انجام می‌شود؛ نیازی به نصب Android Studio یا Android SDK روی سرور شخصی نیست.
