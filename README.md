# Dazie

Dazie is an offline-first group communication and direction-finding app for friends, families, classmates, hikers, and event-goers. It is a third-year computer science final project. The goal is to help a small group coordinate with short messages and last-known direction when mobile data is weak or unavailable.

## Current progress

The current demo reproduces the supplied welcome, login, signup, home, and settings mockups. Welcome and account screens use the light layouts shown in the images; home and settings use the dark indigo layout. The interface uses the supplied mascot, wordmark, profile image, icons, Fredoka and Nunito Sans fonts.

The login/register screens are local UI only. The display name stays in memory for the current session; there is no account server or local persistence yet. Google and Facebook buttons, chat creation, and nearby discovery are visual previews. Conversation rows use sample content. Chat messaging, peer discovery, compass navigation, persistent account settings, and real provider sign-in remain later checkpoints.

## Planned MVP

- Find and connect to nearby peers.
- Send text-only messages to a connected friend or group.
- Browse friends and groups with local conversation history.
- Use a compass with a last-known state when a peer disconnects.
- Review the main flow in a browser using demo hardware services.

The MVP is offline-first and has no central database. The proposal selects local Sembast storage (`sembast` on native and `sembast_web` on web). Real nearby communication is intended for Android and will sit behind service interfaces; browser behavior will use demo adapters. Chat media, voice calls, Rally Point, multi-hop forwarding, offline maps, social login, and cloud sync are stretch goals.

## Project structure

```text
docs/
  AGENTS.md     Project-specific contributor and agent guidance
  DESIGN.md     Proposal summary and visual/architecture rules
  CHECKPOINTS.md
                Full staged roadmap and current status
lib/
  main.dart
  screens/      Welcome, login, signup, home, and settings
  theme/        Shared color, typography, and spacing tokens
  widgets/      Shared buttons, text field, and account layout
assets/
  fonts/        Fredoka and Nunito Sans brand fonts
  images/       Dazie logos, settings graphics, and interface icons
test/
  app_flow_test.dart  Asset, navigation, and 390x844 layout checks
```

The `docs/` directory is locally ignored by `.gitignore`, as requested. Remove the `/docs/` ignore rule if the project documents should be included in Git pushes.

## Run the demo

Install Flutter, then from the project root run:

```sh
flutter pub get
flutter run -d chrome
```

Run the widget, asset, and mockup-size checks with `flutter test`. The demo can also run on an Android target. Profile names and sample conversations are not saved between app sessions.

## Project references

- Final proposal: `6ADET_M7A1_Proposal.pdf`
- Mockup and screen exports: `6ADET_M7A2_Mockup.pdf`
- Final design system: `6ADET_M7A3_Design.pdf`
- Roadmap: `docs/CHECKPOINTS.md`
