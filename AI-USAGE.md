# AI use

I used OpenAI Codex while building Dazie. My estimate is that I wrote about
**22% of the code**, and AI wrote or helped with about **78%**. I mainly worked
on the screens and app flow, with some work on Login, Register, and connecting
the database and services. Some files have work from both of us, so the split is
an estimate. I linked the related commits below.

## 1. How I used AI

### 2026-09-20 - Build onboarding and account flow

- **Tool:** OpenAI Codex
- **What I asked for:** Help me start the onboarding, Login, and Register screens in Flutter.
- **What it gave back:** A first draft of the screens and a local account flow.
- **What I kept, what I changed, and why:** I used some of the structure, then changed the screens and flow to fit my mockups. Accounts stay on the phone, so I made sure the app did not present them as online accounts.
- **Commit:** [https://github.com/prinpami/Dazie/commit/ada6062886ace4b18c8f959b8f4f96676712cf0e](https://github.com/prinpami/Dazie/commit/ada6062886ace4b18c8f959b8f4f96676712cf0e)

### 2026-09-20 - Add the searchable home flow

- **Tool:** OpenAI Codex
- **What I asked for:** Help make the searchable home screen and connect it to the other screens.
- **What it gave back:** A first home screen with search and navigation.
- **What I kept, what I changed, and why:** I kept the search idea and changed the layout and sample content to fit the app I had in mind.
- **Commit:** [https://github.com/prinpami/Dazie/commit/ab364f75a5ab59085005c10869062dc98fedf278](https://github.com/prinpami/Dazie/commit/ab364f75a5ab59085005c10869062dc98fedf278)

### 2026-09-21 - Apply the supplied brand assets

- **Tool:** OpenAI Codex
- **What I asked for:** Help apply the supplied Dazie logo, images, colors, and fonts to the onboarding and account screens.
- **What it gave back:** Theme and screen updates using the supplied logo, images, colors, and fonts.
- **What I kept, what I changed, and why:** I kept the supplied assets and dark style, then adjusted the screens to match the mockups. I also found and fixed missing font weights and a button font setting (see section 2).
- **Commit:** [https://github.com/prinpami/Dazie/commit/1dcea7e8655e520f60bca80fdbd490050607442a](https://github.com/prinpami/Dazie/commit/1dcea7e8655e520f60bca80fdbd490050607442a)

### 2026-09-22 - Build the settings and discovery screens

- **Tool:** OpenAI Codex
- **What I asked for:** Help with the Settings screen, profile header, shared rows, and nearby discovery screen.
- **What it gave back:** Settings components and an early nearby screen.
- **What I kept, what I changed, and why:** I adjusted the rows and header to match the rest of the app. Nearby discovery was only a preview then; later I added real Android nearby connections.
- **Commit:** [https://github.com/prinpami/Dazie/commit/d77e16c1e83605f542f727602ddbd2725151db1f](https://github.com/prinpami/Dazie/commit/d77e16c1e83605f542f727602ddbd2725151db1f)

### 2026-09-23 - Add flow and screenshot checks

- **Tool:** OpenAI Codex
- **What I asked for:** Help add app-flow checks and screenshots of the main screens.
- **What it gave back:** Flutter widget tests and screenshot captures for onboarding, login, registration, home, and settings.
- **What I kept, what I changed, and why:** I kept the checks, but added a wait for the fonts and screen assets. Without that, some screenshots could show missing icons or the wrong fonts.
- **Commit:** [https://github.com/prinpami/Dazie/commit/f82bd61a2a36b2459a2a49054a78668c269f4ec7](https://github.com/prinpami/Dazie/commit/f82bd61a2a36b2459a2a49054a78668c269f4ec7)

### 2026-09-23 - Review project documentation and security notes

- **Tool:** OpenAI Codex
- **What I asked for:** Help review the setup instructions and write down the app's limits and security checks.
- **What it gave back:** A draft of the project notes and security checklist.
- **What I kept, what I changed, and why:** I kept the checklist and edited it so it matched what the app could actually do at that point.
- **Commit:** [https://github.com/prinpami/Dazie/commit/4f30c0694e41ced8ad3c424d76d6b68a46331983](https://github.com/prinpami/Dazie/commit/4f30c0694e41ced8ad3c424d76d6b68a46331983)

### 2026-09-25 - Add chat and nearby screen previews

- **Tool:** OpenAI Codex
- **What I asked for:** Help with the chat and nearby screens for my project checkpoint.
- **What it gave back:** Draft chat and nearby screens, a connect sheet, a compass preview, and some flow checks.
- **What I kept, what I changed, and why:** I used some layout ideas and kept working on the screens and app flow myself. These features were previews at first; later I connected chat to local storage and nearby services.
- **Commits:** [chat and conversation screens](https://github.com/prinpami/Dazie/commit/ad75f6b0cd0460ff25ce709c9bb77711a48d3819), [nearby discovery preview](https://github.com/prinpami/Dazie/commit/00e15367fd94d8f8068dec7b2b83e06210b2f524), [flow and screenshot checks](https://github.com/prinpami/Dazie/commit/3dac3d4531f919f3ba30fd9fbd56b039aa369998)

### 2026-09-27 - Add local database and repositories

- **Tool:** OpenAI Codex
- **What I asked for:** Help store profiles, chats, messages, peers, and settings on the phone.
- **What it gave back:** The Sembast database setup, data models, and repository code.
- **What I kept, what I changed, and why:** I used it for local accounts and saved chats, then connected the screens to it. AI wrote most of the repository code; my part was mainly the simpler setup and wiring.
- **Commit:** [https://github.com/prinpami/Dazie/commit/2038fc6230ad89a7c2d183bcecd036edf2037237](https://github.com/prinpami/Dazie/commit/2038fc6230ad89a7c2d183bcecd036edf2037237)

### 2026-09-27 - Connect local chat storage and nearby messaging

- **Tool:** OpenAI Codex
- **What I asked for:** Help connect the chat screens to saved data and send messages between nearby phones.
- **What it gave back:** Code connecting screens to storage and most of the nearby messaging and sync logic.
- **What I kept, what I changed, and why:** I kept the local storage approach and checked that the service fit the screens. I made basic integration changes, while AI helped with most of the more complicated nearby messaging code.
- **Commits:** [screen and storage integration](https://github.com/prinpami/Dazie/commit/1cba036347991e609f4d51f074ce13a6b0e26eec), [nearby synchronization service](https://github.com/prinpami/Dazie/commit/5e9f28470aab0de9d48f6cf9805dc89b9df5d7db)

## 2. Where the AI got it wrong

### Case 1 - Brand font setup

- **What it gave me:** The theme missed some Fredoka font weights and did not set Nunito Sans for buttons.
- **What was wrong with it:** Some text could use the wrong font or weight and look different from my mockups.
- **What I did instead:** I added the missing weights and set the button font.
- **Commit:** [https://github.com/prinpami/Dazie/commit/6bf4cbec71274ab405c4d3e5eb87a9710a057ebe](https://github.com/prinpami/Dazie/commit/6bf4cbec71274ab405c4d3e5eb87a9710a057ebe)

### Case 2 - Screenshot assets were not ready

- **What it gave me:** The screenshot test took pictures before the fonts and icons finished loading.
- **What was wrong with it:** Some screenshots could show missing icons or the wrong fonts.
- **What I did instead:** I made the test wait for the screen assets before taking each screenshot.
- **Commit:** [https://github.com/prinpami/Dazie/commit/61ab98b95b1f10394af47026853fb1faf9f7873e](https://github.com/prinpami/Dazie/commit/61ab98b95b1f10394af47026853fb1faf9f7873e)

### Case 3 - Realistic sample identity

- **What it gave me:** The registration example used `AdaLovelace` and `ada@example.com`.
- **What was wrong with it:** I wanted the sample account to look generic. The email uses the reserved `example.com` domain, but the recognizable name was still a poor fit for my demo.
- **What I did instead:** I changed the name and email to obviously generic sample values.
- **Commit:** [https://github.com/prinpami/Dazie/commit/42fe8baa945fdecf07a7139f40ec0b283bb8396c](https://github.com/prinpami/Dazie/commit/42fe8baa945fdecf07a7139f40ec0b283bb8396c)

## 3. Who wrote what

### What I wrote

- **App flow and screens:** I worked mostly on the screens and how you move between them. My work is in `lib/main.dart` and `lib/screens/home_screen.dart` ([home and route flow](https://github.com/prinpami/Dazie/commit/ab364f75a5ab59085005c10869062dc98fedf278)). The home screen gives a clear way into chats, and I changed the layout and flow to fit the app I wanted to make.
- **Register and Login:** I wrote parts of `lib/screens/register_screen.dart` ([registration form](https://github.com/prinpami/Dazie/commit/6582ee1f5258358f5c98e295fc401bda2d0e1263)) and `lib/screens/login_screen.dart` while connecting the screens to local accounts ([screen and storage integration](https://github.com/prinpami/Dazie/commit/1cba036347991e609f4d51f074ce13a6b0e26eec)). Register checks the form before adding a local profile.
- **Shared screen widgets:** I made `lib/widgets/dazie_action_button.dart`, `lib/widgets/dazie_page.dart`, and `lib/widgets/dazie_text_field.dart` ([shared widgets](https://github.com/prinpami/Dazie/commit/056763bb326dfa99753ceb1aad1d9ff90aab87ef)). These let me reuse the same buttons, page layout, and fields across screens.
- **Database and services:** I did some of the basic setup and connected screens to the data and services. AI wrote most of the repository and nearby-sync code ([database setup](https://github.com/prinpami/Dazie/commit/2038fc6230ad89a7c2d183bcecd036edf2037237), [nearby sync](https://github.com/prinpami/Dazie/commit/5e9f28470aab0de9d48f6cf9805dc89b9df5d7db)).

My estimate is that I wrote about **22% of the codebase** and AI wrote or helped with about **78%**. Some files have changes from both of us, so I cannot split every line exactly.

### The AI-written part I understand best

- **File:** `lib/services/chat_sync_service.dart`
- **Commit:** [https://github.com/prinpami/Dazie/commit/5e9f28470aab0de9d48f6cf9805dc89b9df5d7db](https://github.com/prinpami/Dazie/commit/5e9f28470aab0de9d48f6cf9805dc89b9df5d7db)
- **What it does and why we kept it:** This service handles nearby message events and works with the local conversation and message storage. It helps send and save messages so the chat screen can focus on showing the conversation.
