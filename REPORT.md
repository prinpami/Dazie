# Weekly Increment Report 

## Week of: September 27, 2026 

## What changed this week

- Updated the project to use Flutter 3.44.2 and Dart 3.12.2.
- Configured Android SDK 37 and resolved the Gradle compile SDK requirement.
- Installed and configured ADB for physical Android device testing.
- Connected two Android phones and authorized USB debugging.
- Implemented offline local storage using Sembast for profiles, conversations, peers, settings, and messages.
- Implemented nearby group hosting, group discovery, connection approval, synchronization, and message exchange.
- Fixed the Flutter framework assertion caused by duplicate navigation actions.
- Tested Dazie successfully on two physical Android phones.
- Updated the README with current setup steps, features, screenshots, Android testing instructions, and known issues.
- Updated the security checklist to reflect local storage and nearby device communication.

## Why

These changes moved Dazie from being an UI mockup into a almost working Android application where you can now send messages with other phones offline. The goal was to make the app usable and testable on real devices and provde that users can create or join an offline group. 

## What broke or what I got stuck on

ADB and USB debugging took a lot of time to configure when I'm testing the physical Android phones. The Android SDK installation also caused an issue, and the Windows Hypervisor was not working, so I used physical phones. 

As for the development, despite saying it is easy in my journal, it took me a while to implement it and had struggles with the database and there are sometimes where I can't see the message from the other device despite being connected. And also I've encountered an assertion error which was fixed with submission guards. 

## What is left

I need to improve the reconnection and conflict handling, fix the UI header issue on home screen, fix remaining widget features and creating accounts as well (might remove the facebook/google signup), I need to implement the radar feature since it is still on mock data. Test more Android devices. Lastly, complete the final security checklist once those things are implemented to ensure security of course. 

## Week of: September 23, 2026

## What changed this week

- Built initial onboarding, login, registration, home, and settings screens using the project mockups and supplied assets.
- Added screenshot references for the five screens, plus app flow tests.
- Updated the README with setup steps, features, project structure, screenshots, and known issues. Added AI-USAGE.md and a completed security checklist.
- Added license notices for the Fredoka and Nunito Sans fonts and replaced personal sample details with fictional ones.
- Updated commit authorship to use my prinpami GitHub account and kept the history spread across September 20–23.

## Why

I wanted to make visible progress on the app while making it easier for someone else to run and understand the project. I also started preparing the repository for review and eventual publication.
## What broke or what I got stuck on

The initial screenshots captures did not load the fonts and images correctly, so I adjusted the test setup and captured them again. I still need to sign in to GitHub and check the secret scanning and push protection settings.

## What is left
- Connect login and registration to real authentication and persistent user data.
- Build working one-to-one and group chat, including message storage.
- Implement and test nearby device discovery and connectivity.
- Test the screens on the target devices and continue comparing them with the mockups.
- Check the remaining GitHub security settings before making the repository public.
- Finish the remaining project roadmap items and prepare final presentation materials.

## Compatibility follow-up: October 3, 2026

### What changed

- Replaced the sample-only Android nearby path with a Google Nearby Connections adapter. It uses `P2P_CLUSTER`, connection-code confirmation, and byte packets; other platforms retain the demo adapter.
- Added Android permission selection and readiness checks for Nearby/Bluetooth, legacy Location, Google Play services, Bluetooth, and Wi-Fi. The app's Android minimum is API 24; the built APK targets API 36 and compiles against API 37.
- Added local group and message synchronization, queued delivery, retryable connection states, and deletion tombstones. Sembast uses native storage on mobile/desktop and its web adapter in browsers.
- Fixed widget-test shutdown waiting on an event queue in Flutter fake async, updated deletion-flow selectors, and added API 23–37 permission and simulated peer-connectivity coverage.

### Codebase map

- `lib/main.dart` wires navigation and shared connection prompts. `AppServices` constructs storage, repositories, the nearby adapter, and `ChatSyncService`.
- `lib/data/` contains database selection and repositories; `lib/models/` defines local and transmitted records. `lib/services/nearby_service.dart` is the transport contract, with Android and demo implementations. `chat_sync_service.dart` handles hello, group, message, and acknowledgement packets.
- `lib/screens/` contains onboarding, home, discovery, chat, settings, and compass flows. Accounts remain local, provider sign-in is a placeholder, and compass/location values are demonstration data.

### Checks and remaining compatibility work

- `flutter analyze` completed without issues; `flutter test --concurrency=1` passed all 14 tests.
- The debug APK, web build, and Linux build completed. The APK reports min SDK 24, target SDK 36, and compile SDK 37. The web build emitted a non-blocking Cupertino icon-font warning; the app has no `CupertinoIcons` references.
- The September 27 report above records successful testing on two physical Android phones. No phone or emulator was attached during this October 3 compatibility pass, so Android Nearby advertising, discovery, acceptance, and transfer were not retested on hardware.
- Repeat host/find, code acceptance and rejection, group/history sync, queued delivery after reconnect, and mobile-data-off checks across Android versions and vendors. API 32 and API 33+ permission behavior is covered in automated tests but still needs device checks.
- Online authentication, provider sign-in, live compass/location, and iOS Nearby transport remain outside the current prototype.
