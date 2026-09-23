# Security checklist

Complete this review before making the repository public. Each answer follows the supplied course template. “No” means an owner-side check or fix is still needed.

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | Reviewed current `lib/` and historical diffs; no service credential or hardcoded login secret appears there. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | N/A | This demo has no private runtime values, API keys, or backend configuration, so it needs no example secrets file. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | Checked tracked Android and platform files; no keystore or signing properties are tracked. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | Reviewed keyword and credential-pattern hits; they are UI labels and synthetic test values, not credentials. |
| 5 | Any credential that was ever committed has been rotated | N/A | No real credential was found in source or history, so there was nothing to rotate. |

## GitHub Actions

There are no GitHub Actions workflow files in this project.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | N/A | The repository has no GitHub Actions workflows. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | N/A | The repository has no GitHub Actions workflows or workflow secrets. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | N/A | There are no workflow runs or logs to inspect. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | No signed APK build workflow exists. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | N/A | No workflow uploads build artifacts. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | N/A | No workflows use third-party actions. |
| 12 | Secret scanning and push protection are enabled on the repository | No | Repository settings could not be checked in this session; confirm both settings while signed in before publication. |

## Backend and security rules

This demo is local-only and has no backend.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | The app does not use Firebase, Firestore, or Firebase Storage. |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | There are no backend user documents or access rules in this prototype. |
| 15 | If Supabase: Row Level Security is on for every table | N/A | The app does not use Supabase or have database tables. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The app contains no Firebase or Google API key. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | There is no backend or shared data to read or write; account screens are a local prototype. |
| 18 | Seed and sample data is invented, not real people's data | Yes | Visible account and conversation examples use fictional names and synthetic test values. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | N/A | Form validators run before demo navigation, but the prototype does not write or transmit form data. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | No runtime secrets or service credentials are present to extract from a build. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | Replaced personal sample identifiers and rewrote commit author metadata; checked tracked text and commit subjects. |
| 22 | No classmate's personal data in the repository | Yes | Sample conversation names and messages are fictional placeholders. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | `pubspec.lock` lists hosted pub.dev packages; `.gitignore` excludes both generated directories. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | The project owner supplied the brand images; Fredoka and Nunito Sans fonts include their OFL-1.1 license notices in `assets/fonts/`. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | No | An unauthenticated GitHub lookup returned 404, so visibility was not confirmed; check repository settings after the final push. |

## Anything I found and fixed

The review found a real-name sample conversation and a personal handle in the source and historical commits, so both were replaced with fictional examples and project-only commit metadata. No service credentials or signing secrets were found; GitHub scanning settings and repository visibility still need an owner review before publication.
