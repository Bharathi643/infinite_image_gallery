# Infinite Image Gallery — Flutter + Pixabay

A Flutter image gallery application built with the Pixabay API. The app supports image discovery, keyword search, infinite scrolling, image details, locally persisted favorites, and downloading images to the device gallery.

## Features

- Responsive image grid with image caching.
- Pixabay keyword search.
- Page-based pagination and infinite scrolling.
- Loading, empty, and error states.
- Retry and pull-to-refresh.
- Image detail screen with available image metadata.
- Favorites persisted locally using SharedPreferences.
- Download images to the device gallery using `gal`.
- Provider / ChangeNotifier state management.

## Tech Stack

- Flutter and Dart
- Pixabay API
- Provider
- SharedPreferences
- Dio
- Gal

## Prerequisites

- Flutter SDK compatible with the project's `pubspec.yaml`.
- Android Studio or VS Code.
- An Android emulator or physical Android device.
- A Pixabay API key.

## Setup

1. Clone the repository and open the project directory.
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Obtain an API key from the [Pixabay API documentation](https://pixabay.com/api/docs/).
4. Create a `.env` file in the project root, following the configuration expected by the application:

   ```env
   PIXABAY_API_KEY=YOUR_ACTUAL_KEY
   ```

5. Run the application:

   ```bash
   flutter run
   ```

If the project requires platform files to be generated because they are missing, run `flutter create .` before fetching dependencies. Do not run it unnecessarily over an existing platform configuration.

## Architecture

- `models/` — photo data model and JSON mapping.
- `services/` — Pixabay API communication.
- `providers/` — gallery state, pagination, and favorites state.
- `screens/` — gallery, image details, and favorites screens.
- `widgets/` — reusable UI components.

The application uses Provider / ChangeNotifier to manage state and separate API communication, state management, and UI components.

## Run Tests

Run the static analyzer:

```bash
flutter analyze
```

Run the test suite:

```bash
flutter test
```

Latest verified local results: no analyzer issues and 15 tests passed. Re-run both commands after any subsequent changes.

## Build an Android APK

```bash
flutter build apk --release
```

Expected output:

`build/app/outputs/flutter-apk/app-release.apk`

Verify that the API key is configured correctly for the application's actual configuration before building and testing the release APK.

## API Key Safety

Do not commit `.env` or any file containing a real API key. Ensure `.env` is listed in `.gitignore`.

A key bundled in a mobile application can still be extracted, even when it is stored in an environment file or supplied at build time. For production applications, consider using a backend proxy and appropriate usage restrictions.

## Assumptions, Limitations & Incomplete Features

### Assumptions

- Pixabay is the source of gallery images and metadata.
- An internet connection is required to fetch images and search results.
- Some metadata may not be available for every image.

### Limitations

- Image availability and API responses depend on Pixabay.
- API usage limits may affect requests.
- Image downloads and permissions can behave differently across Android versions and devices.

### Incomplete Features and Verification

- Document any features that are not implemented.
- Document any known bugs or limitations.
- Confirm download permissions, image saving, pagination, and favorites persistence on a real device before submission.
- If no known incomplete features remain after verification, state that explicitly.

## Windows Gradle Memory Troubleshooting

If Gradle fails because of native memory allocation, check `android/gradle.properties` and use memory settings appropriate for your machine. Avoid setting an excessively large Gradle heap on a low-memory system.

Close memory-intensive applications and ensure Windows virtual memory is enabled. If the issue persists, inspect the complete Gradle error before changing build configuration.
