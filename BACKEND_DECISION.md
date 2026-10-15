# NOOR — Backend decision record (Phase 13, prepared not connected)

Status: **decision made by PM, nothing connected yet.** The app runs
today with honest local stand-ins; this document is what a backend
developer (or a later phase) needs to go live, and exactly what it
will require from the user.

## Decision

One small backend service + managed auth/database, rather than
scattering API keys inside the app:

- **Platform:** Supabase (Postgres + Auth + Storage) OR Firebase
  (Auth + Firestore). PM recommendation: **Supabase** — SQL data
  model suits prayer logs/streaks/bookmarks, generous free tier,
  Argon2/bcrypt handled by the platform, Row-Level Security keeps
  each user's data private by construction.
- **AI answers (Pages 12/23/24/26 + Hifz 27–30):** a thin server
  endpoint the app calls (never a model key in the app). The
  endpoint retrieves from licensed/verified sources first, then
  asks the model to explain with citations; the app displays
  sources separately from explanation (already the UI pattern).
  Existing client contract: `HttpAiService` with base URL injected
  at build time via `--dart-define=NOOR_AI_API=https://…`.
- **Accounts (Pages 41/42):** platform Auth (email + password with
  server-side hashing, reset email, tokens in device secure
  storage). `LocalAuthService` is a device-local stand-in until
  then and is labelled as such in code; plain SHA-256 placeholder
  must never ship as production auth.

## Configuration already prepared in the app

- `--dart-define=NOOR_AI_API=<url>` — AI endpoint base URL
  (unset → labelled offline samples; never a fake live claim).
- Prayer/Qur'an content needs **no key** (AlAdhan + AlQuran Cloud,
  already live and field-verified).

## Exactly what will be needed from the user (external gates)

1. A Supabase (or Firebase) **project** created under the user's
   own account — project URL + anon key go into build config; the
   service-role key never enters the app.
2. An **AI provider account + API key** held on the server only
   (paid usage; the user chooses the provider/budget).
3. Optional later: Apple/Google developer accounts for store
   distribution (separate gate, see PM_BOARD).

## Not decided here (deliberately)

- Final AI model choice (cost/quality decision once the endpoint
  exists and sample answers can be scholar-reviewed).
- Push-notification provider (local prayer notifications already
  work device-side; remote push is a later feature decision).
