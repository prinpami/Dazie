# Dazie

Dazie is an offline-first group communication and direction-finding app for friends, families, classmates, hikers, and event-goers. It is a third-year computer science final project. The goal is to help a small group coordinate with short messages and last-known direction when mobile data is weak or unavailable.

## Current progress

The first demo flow is implemented: onboarding leads to local profile creation or the returning-user form, and both continue to the searchable home conversation list. The home list currently uses sample rows based on the mockup.

The login/register screens are local UI only. The display name stays in memory for the current session; there is no account server or local persistence yet. Chat, nearby discovery, compass navigation, and settings remain later checkpoints. Unfinished placeholder Dart files were removed so the source tree shows the working flow.

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
  screens/      Onboarding, local login/register, and home
  theme/        Shared color, typography, and spacing tokens
  widgets/      Shared button, text-field, logo, and page layout
```

The `docs/` directory is locally ignored by `.gitignore`, as requested. Remove the `/docs/` ignore rule if the project documents should be included in Git pushes.

## Run the demo

Install Flutter, then from the project root run:

```sh
flutter pub get
flutter run -d chrome
```

The demo can also run on an Android target. Profile names and sample conversations are not saved between app sessions.

## Project references

- Final proposal: `6ADET_M7A1_Proposal.pdf`
- Mockup and screen exports: `6ADET_M7A2_Mockup.pdf`
- Final design system: `6ADET_M7A3_Design.pdf`
- Roadmap: `docs/CHECKPOINTS.md`
