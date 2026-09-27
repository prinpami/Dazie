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
