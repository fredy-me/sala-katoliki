# Android Release Preparation

Phase 13 prepares the Android-first Sala Katoliki MVP for Google Play internal testing.

## App Identity

- App name: `Sala Katoliki`
- Android application ID: `com.busaradigital.salakatoliki`
- Android namespace: `com.busaradigital.salakatoliki`
- Version source: `pubspec.yaml`
- Current version: `1.0.0+1`

## SDK Requirements

Google Play requires new apps and app updates submitted after 31 August 2025 to target Android 15, API level 35, or higher.

Current Android configuration:

- `minSdk`: `23`
- `targetSdk`: `35`
- `compileSdk`: Flutter toolchain default

Before every store upload, verify the current Google Play target API policy and update `targetSdk` if the requirement has increased.

## Signing

Release signing reads local credentials from `android/key.properties`. This file is intentionally ignored by Git.

Create a release keystore outside source control:

```bash
keytool -genkey -v -keystore android/release-keystore/sala-katoliki-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sala-katoliki-release
```

Copy `android/key.properties.example` to `android/key.properties` and replace all values.

Production AAB builds must use the release signing config. If `android/key.properties` is missing, Gradle falls back to debug signing only so local builds do not break; debug-signed bundles are not valid for store submission.

## Permissions

Main release manifest requests:

- `android.permission.POST_NOTIFICATIONS`

Reason: daily prayer reminder notifications.

Debug manifest requests:

- `android.permission.INTERNET`

Reason: Flutter debug tooling only. It is not declared in the main release manifest.

No camera, microphone, contacts, location, Bluetooth, NFC, SMS, phone, calendar, storage, or biometric permissions are required for the MVP.

## Build Command

Use this only after release signing credentials are configured:

```bash
flutter build appbundle --release
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Internal Testing Metadata

Use the metadata in [google_play_internal_testing.md](google_play_internal_testing.md) for the first internal testing upload.
