# Law Draft

A free legal drafting and legal information app for Pakistan, built as a final year project.
It runs on the web and on Android from one Flutter codebase.

## Features
- 25 legal drafts: fill a guided form, preview, download an editable DOCX
- Draft history with re-download, and Urdu / Sindhi / English translation
- Step by step legal guides that work offline, with instant local search
- Ask AI: instant answers from the saved guides, optional AI explanation
- Case law notes with links to the official judgments
- Islamic inheritance and property advance tax calculators
- Dashboard with legal updates and official sources

## Tech stack
Flutter (Dart), Supabase (Auth, PostgreSQL with Row Level Security, Edge Functions),
Groq and Gemini APIs (called only from Edge Functions, never from the app).

## How it works
Drafts are stored as JSON "cards" in the `draft_templates` table (a form part and a
document part), so a new draft is added with SQL, without rebuilding the app.

## Setup
1. Install Flutter and run `flutter pub get`.
2. Create a Supabase project and run `supabase/schema.sql` in the SQL editor.
3. Put your project URL and anon key in `lib/core/supabase_config.dart`.
4. Deploy `supabase/functions/*` and add these secrets: `GROQ_API_KEY`, `GROQ_MODEL`,
   `GEMINI_API_KEY`, `GEMINI_MODEL`.
5. Put the font files from `pubspec.yaml` in `assets/fonts/`.
6. Run `flutter run -d chrome` (web) or `flutter run` (Android phone).
7. Run the tests with `flutter test`.

## Disclaimer
General information only, not legal advice. All draft wording is sample text and must be
checked by an advocate before use. AI translations and explanations can contain mistakes.

## Team
Developers: [Sheeraz Ahmed], [Mohsan Ali], [Asad Niaz]. Supervisor: [Prof. Asia Soomro].