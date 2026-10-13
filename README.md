# Infinite Image Gallery — Flutter + Pixabay

Flutter assessment starter project with Pixabay API integration.

## Features
- Responsive, cached image grid
- Pixabay keyword search and page-based infinite scrolling
- Loading, empty, and error states; retry and pull-to-refresh
- Image detail page with tags, user, resolution, likes and views
- Favorites persisted locally with SharedPreferences
- Download image to the device gallery with `gal`
- Provider / ChangeNotifier state management

## Setup
1. Install Flutter SDK (Dart 3.3+) and Android Studio or Xcode.
2. Extract this ZIP and open the folder in VS Code / Android Studio.
3. In the project folder, generate platform folders and fetch dependencies:
   ```bash
   flutter create .
   flutter pub get
   ```
4. Get your Pixabay key from https://pixabay.com/api/docs/.
5. Run the app with your key (replace `YOUR_ACTUAL_KEY`):

   Windows PowerShell / CMD, macOS or Linux:
   ```bash
   flutter run --dart-define=PIXABAY_API_KEY=YOUR_ACTUAL_KEY
   ```

6. Build an APK:
   ```bash
   flutter build apk --release --dart-define=PIXABAY_API_KEY=YOUR_ACTUAL_KEY
   ```
   Output is usually `build/app/outputs/flutter-apk/app-release.apk`.

## Android internet permission
Check `android/app/src/main/AndroidManifest.xml`. Directly inside the `<manifest>` element, ensure:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
Check current `gal` package instructions for platform-specific gallery permission/configuration. Test download behavior on a real device.

## Structure
```text
lib/
  main.dart
  models/photo.dart
  services/pixabay_service.dart
  providers/gallery_provider.dart
  providers/favorites_provider.dart
  screens/gallery_screen.dart
  screens/detail_screen.dart
  screens/favorites_screen.dart
  widgets/photo_grid.dart
```

## API key safety
The key is not included in this ZIP. `--dart-define` keeps it out of the source file, but a key embedded in a mobile app can still be extracted. Do not commit it to a public repository; use a backend proxy for stronger production protection.

## Notes
Pixabay enforces API usage limits. This is a starter implementation, not a prebuilt APK. Test dependencies, platform permissions, pagination, favorites and downloads on your target device before submission. Consider adding more unit/widget tests, retry/backoff and download progress.


## Windows Gradle memory-crash fix

The provided crash log reported `insufficient memory ... Native memory allocation` with Gradle configured as `-Xmx8G` and `MaxMetaspaceSize=4G`. This project includes reduced Gradle memory limits (`-Xmx2G`, metaspace `1G`) and only two Gradle workers.

1. Extract this ZIP. Folder name: **`infinite_image_gallery`**.
2. Open Command Prompt in that folder. Close Android Studio and other memory-heavy apps for the first build.
3. Run:

   ```bat
   flutter create .
   flutter clean
   if exist android\.gradle rmdir /s /q android\.gradle
   flutter pub get
   flutter run --dart-define=PIXABAY_API_KEY=YOUR_ACTUAL_KEY
   ```

   Replace `YOUR_ACTUAL_KEY` with your own Pixabay key. Keep it private and do not put it in source code.
4. If it still crashes, restart Windows and retry; make sure Windows virtual memory/page file is enabled and system-managed. Do not set the Gradle heap back to 8G.
5. Release APK:

   ```bat
   flutter build apk --release --dart-define=PIXABAY_API_KEY=YOUR_ACTUAL_KEY
   ```

This ZIP contains Flutter source, not a prebuilt APK. `flutter create .` generates platform files for the installed Flutter SDK. If Android files already exist, verify `android/gradle.properties` matches the memory settings included in this ZIP.
