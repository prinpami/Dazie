# AI usage

This project was built with AI assistance. This file is the record of it. It is
graded as the finals badge, and it is worth 100 points.

Start it in week 1 and keep it up as you go. The commit history of this file is
part of the evidence: a file written all at once the night before the deadline
looks exactly like what it is.

## 1. How I used AI

### 2026-09-20 - Build onboarding and account flow

- **Tool:** OpenAI Codex
- **What I asked for:** Help implement the onboarding, sign-in, and registration flow as a Flutter prototype.
- **What it gave back:** The initial screens and local navigation for a welcome-to-profile flow.
- **What I kept, what I changed, and why:** I kept the session-only prototype flow and refined the screens against the supplied mockups. The project has no online account service, so the screens explain that these interactions are previews.
- **Commit:** [https://github.com/prinpami/Dazie/commit/ada6062886ace4b18c8f959b8f4f96676712cf0e](https://github.com/prinpami/Dazie/commit/ada6062886ace4b18c8f959b8f4f96676712cf0e)

### 2026-09-20 - Add the searchable home flow

- **Tool:** OpenAI Codex
- **What I asked for:** Help create the home screen with searchable conversation previews and navigation between the app screens.
- **What it gave back:** A searchable conversation list and the route flow connecting the prototype screens.
- **What I kept, what I changed, and why:** I kept the local search and preview interactions as a UI demonstration. I later replaced sample content with generic wording so the demo would not expose personal-looking data.
- **Commit:** [https://github.com/prinpami/Dazie/commit/ab364f75a5ab59085005c10869062dc98fedf278](https://github.com/prinpami/Dazie/commit/ab364f75a5ab59085005c10869062dc98fedf278)

### 2026-09-21 - Apply the supplied brand assets

- **Tool:** OpenAI Codex
- **What I asked for:** Help apply the supplied Dazie logo, images, colors, and fonts to the onboarding and account screens.
- **What it gave back:** Flutter theme and screen updates using the bundled brand assets.
- **What I kept, what I changed, and why:** I kept the supplied assets and dark app styling, then adjusted the implementation to match the mockups and keep the brand resources bundled with the app.
- **Commit:** [https://github.com/prinpami/Dazie/commit/1dcea7e8655e520f60bca80fdbd490050607442a](https://github.com/prinpami/Dazie/commit/1dcea7e8655e520f60bca80fdbd490050607442a)

### 2026-09-22 - Build the settings and discovery screens

- **Tool:** OpenAI Codex
- **What I asked for:** Help implement the settings mockup, profile header, reusable settings rows, and nearby discovery shortcut.
- **What it gave back:** Settings components and a nearby shortcut arranged as prototype UI.
- **What I kept, what I changed, and why:** I kept the reusable rows and profile header to make the screen consistent. The nearby action remains a visual preview because the project has no nearby-connection service.
- **Commit:** [https://github.com/prinpami/Dazie/commit/d77e16c1e83605f542f727602ddbd2725151db1f](https://github.com/prinpami/Dazie/commit/d77e16c1e83605f542f727602ddbd2725151db1f)

### 2026-09-23 - Add flow and screenshot checks

- **Tool:** OpenAI Codex
- **What I asked for:** Help add a widget check for the supplied app flow and screenshot references for the main screens.
- **What it gave back:** Flutter widget tests and screenshot captures for onboarding, login, registration, home, and settings.
- **What I kept, what I changed, and why:** I kept the checks and added font loading and a wait for screen assets before capture, so the screenshots show the intended branding instead of incomplete renders.
- **Commit:** [https://github.com/prinpami/Dazie/commit/f82bd61a2a36b2459a2a49054a78668c269f4ec7](https://github.com/prinpami/Dazie/commit/f82bd61a2a36b2459a2a49054a78668c269f4ec7)

### 2026-09-23 - Review project documentation and security notes

- **Tool:** OpenAI Codex
- **What I asked for:** Help review repository setup and document the prototype's limitations and pre-publication security checks.
- **What it gave back:** Draft documentation describing the demo flow, AI assistance, and security review items.
- **What I kept, what I changed, and why:** I kept the checklist and clarified that authentication, messaging, nearby discovery, and the compass are not implemented as production services.
- **Commit:** [https://github.com/prinpami/Dazie/commit/4f30c0694e41ced8ad3c424d76d6b68a46331983](https://github.com/prinpami/Dazie/commit/4f30c0694e41ced8ad3c424d76d6b68a46331983)

## 2. Where the AI got it wrong

### Case 1 - Brand font setup

- **What it gave me:** The first brand theme setup did not map all the Fredoka weights used by the screens, and the button styles did not specify Nunito Sans.
- **What was wrong with it:** Some text could render with a fallback font or the wrong weight, making the UI differ from the supplied design.
- **What I did instead:** I added the missing weight mappings and set the button text family explicitly.
- **Commit:** [https://github.com/prinpami/Dazie/commit/6bf4cbec71274ab405c4d3e5eb87a9710a057ebe](https://github.com/prinpami/Dazie/commit/6bf4cbec71274ab405c4d3e5eb87a9710a057ebe)

### Case 2 - Screenshot assets were not ready

- **What it gave me:** The first screenshot test captured screens without waiting for bundled fonts, icons, and other asynchronous screen assets to finish loading.
- **What was wrong with it:** The reference images could contain missing icons or use fallback fonts, so they would not reliably represent the app UI.
- **What I did instead:** I added an explicit wait before capture so asynchronously loaded screen assets had time to finish rendering.
- **Commit:** [https://github.com/prinpami/Dazie/commit/61ab98b95b1f10394af47026853fb1faf9f7873e](https://github.com/prinpami/Dazie/commit/61ab98b95b1f10394af47026853fb1faf9f7873e)

### Case 3 - Realistic sample identity

- **What it gave me:** The registration flow and test used the name `AdaLovelace` and the email `ada@example.com` as example account data.
- **What was wrong with it:** A real person's name and a realistic email address were unnecessary in a demo and could be mistaken for personal test data.
- **What I did instead:** I changed the test values to a generic sample username and email.
- **Commit:** [https://github.com/prinpami/Dazie/commit/42fe8baa945fdecf07a7139f40ec0b283bb8396c](https://github.com/prinpami/Dazie/commit/42fe8baa945fdecf07a7139f40ec0b283bb8396c)

## 3. Who wrote what

### Written by me

- **File:** `lib/screens/register_screen.dart`, `lib/main.dart`, `lib/theme/app_spacing.dart`, and the shared UI files in `lib/widgets/`: `dazie_action_button.dart`, `dazie_page.dart`, `dazie_provider_buttons.dart`, `dazie_text_field.dart`, `settings_components.dart`, and `settings_profile_header.dart`.
- **Commit:** [Registration screen](https://github.com/prinpami/Dazie/commit/6582ee1f5258358f5c98e295fc401bda2d0e1263), [app navigation](https://github.com/prinpami/Dazie/commit/ab364f75a5ab59085005c10869062dc98fedf278), [shared onboarding widgets](https://github.com/prinpami/Dazie/commit/056763bb326dfa99753ceb1aad1d9ff90aab87ef), [shared auth controls](https://github.com/prinpami/Dazie/commit/64dc4b10593a0f8afc093a8f1c784150b663f88e), [spacing tokens](https://github.com/prinpami/Dazie/commit/e51945c58836a1777e3b4577a3338d5f0237e02a), [settings rows](https://github.com/prinpami/Dazie/commit/51580b63aa24beaaa7159383b205f48769afb52f), and [settings profile header](https://github.com/prinpami/Dazie/commit/ddfaaa303fa0eaa3d437ba3c12bbddb15c31923d).
- **What it does and why it is built this way:** I wrote the registration screen and edited the app navigation and shared widgets. The registration form checks the username, email, password length, and password confirmation before taking the user to the sample home screen. `main.dart` connects the app screens. After AI helped me understand how `app_theme.dart` centralizes visual styles, I added `app_spacing.dart` to keep layout gaps reusable. The widgets provide shared buttons, fields, page layout, and settings rows so the screens can reuse the same components. The account flow is local because this prototype does not have an authentication backend. Together, these files are about 32% of the current Dart source by line count.

### The AI-written part I understand best

- **File:** `lib/theme/app_theme.dart`
- **Commit:** [https://github.com/prinpami/Dazie/commit/6bf4cbec71274ab405c4d3e5eb87a9710a057ebe](https://github.com/prinpami/Dazie/commit/6bf4cbec71274ab405c4d3e5eb87a9710a057ebe)
- **What it does and why we kept it:** It centralizes the app colors, typography, and shared Material component styles so screens use a consistent visual theme and a design adjustment can be made in one place.
