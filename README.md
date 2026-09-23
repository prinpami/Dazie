# Final Project

**Project:** Dazie

## My project repository

- Public repository: [Dazie on GitHub](https://github.com/prinpami/Dazie) — verify its visibility before sharing it as a public link.
- Live app: Not deployed.

## 1. Overview

Dazie is an offline-first communication concept for friends, families, classmates, and small groups who need to coordinate when mobile internet is unreliable. This early demo presents the welcome, account, conversation-list, and settings screens; its sign-in and communication features are visual prototypes only.

## 2. Setup and installation

The project was built with Flutter 3.47.5 (stable) and Dart 3.13.4. Install Flutter with Dart included, then clone the repository and fetch its packages:

```sh
git clone https://github.com/prinpami/Dazie.git
cd Dazie
flutter pub get
```

No API key, backend URL, or account setup is needed for this demo. The login and registration forms use local validation and do not send or save credentials.

## 3. How to run it

On Windows with Edge configured as a Flutter device, run:

```sh
flutter run -d edge
```

On a machine configured with Chrome, use `flutter run -d chrome`. A working launch opens Dazie's welcome screen with its mascot, tagline, and account buttons. Run `flutter test` to check the current widget flow and screen references. After changing the UI, refresh the captured screen references with `flutter test --update-goldens test/screen_reference_test.dart`.

## 4. Features and usage

1. **Welcome:** Choose **GET STARTED** to open registration, or choose **I already have an account** to open login.
2. **Login:** Enter any non-empty email or username and password, then choose **LOG IN**. The form advances to the demo conversation list; it does not authenticate against a server.
3. **Registration:** Enter a username, an email containing `@`, a password of at least six characters, and a matching confirmation. **REGISTER** opens the same demo conversation list. The validation is only for this prototype.
4. **Home:** Search the fictional conversation list. Choose the menu icon to open settings. Chat rows, chat creation, and nearby discovery display prototype behavior; they do not connect to peers.
5. **Settings:** Toggle Active Status, preview the appearance options, and choose **LOG OUT** to return to the welcome screen. These settings reset when the screen is reopened.

Google and Facebook buttons show that provider sign-in is planned; neither button starts a real sign-in flow. All displayed people and conversations are sample data.

## 5. Project structure

```text
assets/
  fonts/                 Fredoka and Nunito Sans font files
  images/                Supplied brand graphics and interface icons
lib/
  main.dart              App entry point and named screen routes
  screens/               Welcome, login, registration, home, settings
  theme/                 Brand colors, typography, and spacing
  widgets/               Shared forms, buttons, and settings components
test/
  app_flow_test.dart              Asset and primary-flow checks
  screen_reference_test.dart      390 x 844 screen captures
  screenshots/                    Captured screen reference images
README.md                  Setup, usage, project map, and roadmap
SECURITY-CHECKLIST.md       Pre-release security review
AI-USAGE.md                 AI assistance disclosure
```

## 6. Screenshots

These references are captured from the current Flutter widgets at a 390 × 844 viewport.

### Welcome

![Dazie welcome screen](test/screenshots/onboarding.png)

### Login

![Dazie login screen](test/screenshots/login.png)

### Registration

![Dazie registration screen](test/screenshots/register.png)

### Home

![Dazie home screen](test/screenshots/home.png)

### Settings

![Dazie settings screen](test/screenshots/settings.png)

## 7. Known issues and next steps

- Accounts are not created or authenticated, and form values are not saved.
- Chats, group creation, nearby peer discovery, and direction finding are not implemented yet.
- Provider sign-in and settings persistence are prototypes.
- Next, connect the proposed local Sembast store, then implement and demonstrate nearby peer discovery, messaging, and last-known direction behind replaceable service interfaces.

## Presentation

- Video (public Google Drive link): Not published.
- Slides or PDF: Not published.
- Square image: [Dazie mascot](assets/images/Dazie_Logo.png).

## AI usage

Read [AI-USAGE.md](AI-USAGE.md) for the tools used, the work they helped with, and what the student still needs to review.

## Security checklist

See [SECURITY-CHECKLIST.md](SECURITY-CHECKLIST.md). GitHub repository settings still need a signed-in owner check before the repository is made public.
