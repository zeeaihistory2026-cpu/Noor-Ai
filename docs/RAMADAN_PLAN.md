# NOOR AI Companion — Ramadan Launch Plan

**Why this document exists (2026-10-08):** the owner identified Ramadan as the highest-growth window of the year for NOOR — a month where the exact habits NOOR serves (Sehri, fasting, Taraweeh, Qur'an completion, the last ten nights) become daily, urgent, and emotionally central for the audience. This plan sequences the whole project backwards from Ramadan so NOOR launches *into* the wave, not after it.

**Expected dates (verified 2026-10-08 against published Hijri calendar projections — salatok.com Gregorian–Hijri calendar 2027 and Muslim Hands USA Islamic Calendar 2027, which agree):** Ramadan 1448 AH is expected to begin **around Monday 8 February 2027**, with Eid al-Fitr expected around **9–10 March 2027**. Sha'ban 1448 is expected to begin around 9 January 2027. **These are projections, not certainties:** the actual start depends on crescent moon sighting and local announcement, and may shift by a day. All countdowns in this plan and in the app must be labelled "expected", and the app must handle a ±1 day shift gracefully (see §2.9).

---

## 1. Countdown timeline: October 2026 → Ramadan (expected ~8 Feb 2027)

Working backwards from the launch window. Dates are **MUST-be-ready-by** deadlines, not wishes.

| Window | Milestone | Must be true by the end |
|---|---|---|
| **Oct 2026 (now)** | Phone proof | APK/installable file installed on a real Android phone; PHONE_RUN_CHECKLIST fully passed (esp. reminder rings with app closed + after reboot, audio heard, Qibla sane). **Hard deadline: 31 Oct 2026.** Nothing else matters if this slips. |
| **Nov 2026** | Fix + harden | Every phone-run failure fixed and re-proven on the phone; crash-free sessions; prayer/reminder reliability re-tested at real Fajr/Maghrib times. **Deadline: 30 Nov 2026.** |
| **Nov–Dec 2026** | Beta (20–50 users) | Beta per GROWTH_ROADMAP Phase A: 5 missions, ≥10 users returning unprompted on day 2+, zero content-accuracy incidents in sampled cards/search results. **Beta gate: 20 Dec 2026.** |
| **Dec 2026** | Launch business model ready; AI layer deferred | Free app with limited ads + PKR 500/month Remove Ads billing tested end-to-end (store-managed; ad rules in §4 enforced in configuration). **No AI-backend launch scope:** the launched AI stays the honest databank search/sample experience already built; the full AI layer is a later phase after launch retention is proven. Lightweight accounts only if a store/subscription flow requires them. **Deadline: 31 Dec 2026** — Ramadan features must not compete with monetisation plumbing in January. |
| **Dec 2026 – Jan 2027** | Ramzan Mode build (§2) | All Ramzan Mode features built, tested, and captured; Sehri/Iftar alert reliability tested on-device across several real nights (not just 3-minute tests). **Feature-complete: 20 Jan 2027.** |
| **Jan 2027 (Rajab → Sha'ban, expected Sha'ban ~9 Jan)** | Soft launch | Store listing live (Google Play first if only one store is ready); warm-up content cadence starts (preparation pillar, §3); waitlist/beta users migrated; 30-day Ramadan content bank produced and two-person checked **before** Ramadan starts. **Soft launch deadline: 15 Jan 2027.** |
| **Feb 2027 (expected Ramadan ~8 Feb – ~8 Mar)** | Ramadan launch window | Daily content engine running (§3); Ramzan Mode is the app's front door; support + accuracy watch daily; **no new feature launches mid-Ramadan** — stability only. |
| **Mar 2027 (Eid ~9–10 Mar)** | Eid + Shawwal follow-on | Eid mode, Shawwal 6-fasts follow-on (§2.8), Ramadan recap share cards ("My Ramadan" summary) — the retention bridge so Ramadan users stay after Eid. |
| **Apr 2027 →** | Post-Ramadan retention + Year-1 growth | GROWTH_ROADMAP Phases B–C continue; the launch money model (free + limited ads + PKR 500/month Remove Ads, §4) is already live from soft launch and is reviewed against real retention/ad yield. The AI layer and any Premium AI features stay deferred to the later phase. |

**The three dates that cannot move:** phone proof (31 Oct 2026), Ramzan Mode feature-complete (20 Jan 2027), soft launch (15 Jan 2027). If phone proof slips, everything downstream slips week-for-week and the Ramadan window narrows — escalate early, not in January.

---

## 2. Ramzan Mode — feature spec

Design rule for all of §2: **Ramzan Mode is a seasonal layer over existing screens and services** (NoorController as the single source of truth, prayer_service for times, the notification planner/scheduler for alerts, knowledge_search for referenced content, Share Studio for cards). No parallel data, no contradicting times — the consistency rules from the quality programme apply unchanged. Noor tokens only; emerald/gold identity deepens for Ramadan nights (darker emerald headers, gold accents), nothing garish.

### 2.1 Sehri & Iftar alerts (the flagship feature)

- **Purpose:** the single highest-value Ramadan behaviour — never miss Sehri, break fast on time.
- **How it works:** from the user's city/prayer settings, schedule for each Ramadan day: **Sehri pre-alerts at −30 min and −10 min before Fajr**, a final "Sehri ends" alert at Fajr, an optional mid-afternoon Iftar reminder, and the **Iftar alert at Maghrib**. Uses the existing notification plan → scheduler path, extended with a Ramadan series (pre-scheduled for the full month where the platform allows, rolling re-schedule on app open).
- **Reliability requirements:** must fire with the app killed and after reboot (same gate as the Fajr−15 test, re-proven in Ramzan Mode form); exact-alarm permission requested in context with a plain explanation; battery-optimisation exemption requested politely once; a visible "test tonight's Sehri alert" button so users can prove it before the first fast; times recomputed if the user changes city; moon-shift handling (§2.9) re-times the first/last day without manual edits.
- **Design notes:** alerts managed from the existing Reminder Center with a Ramadan section on top (not a buried setting); each alert row shows its offset ("30 min before Fajr — 4:58 AM today") so the promise is checkable at a glance.

### 2.2 Fasting (Roza) tracker + 30-day Ramadan journey

- **Purpose:** a gentle daily record that becomes the most-shared artefact of the month.
- **How it works:** one tap per day — *Fasted / Missed (with private reason: travel, illness, exempt, other) / Not yet*; a 30-dot journey strip (filled gold = fasted, soft outline = missed, no shaming copy anywhere, missed days framed as record-keeping for Qaza planning, which the app lists privately). Ties into the existing Journey screen and streak system — Ramadan streak is a distinct, honoured streak, not merged into Salah streak maths.
- **Shareable day cards:** "Day 12 of Ramadan" card auto-generated in the Share Studio style (day number, brief referenced reminder, NOOR branding) — the daily organic engine (§3). Sharing always optional, missed days never exposed on cards.
- **Design notes:** the journey strip lives on the Ramadan hub (§2.3) and on Journey; privacy first — reasons are never shown anywhere but the private detail view.

### 2.3 Daily Ramadan hub (Ramzan Mode home)

A seasonal home variant (replaces the standard header arrangement during Ramadan, same tab bar):

- **Day counter:** "12th Roza — Ramadan 1448" (computed from the confirmed start, §2.9).
- **Live countdowns:** time to Sehri end (Fajr) in the morning state; time to Iftar (Maghrib) in the fasting state; time to next prayer otherwise. Countdown typography uses the locked numeric (tabular) style.
- **Dua of the day:** one brief, referenced supplication per day (Sehri/Iftar duas on rotation plus the daily set) — reference on screen, full text from approved sources at runtime; two-person checked content pack prepared pre-Ramadan.
- **Ayah / Hadith of the day:** existing daily cards, Ramadan-curated rotation, exact references.
- **Taraweeh tracker:** simple nightly check-in (prayed at mosque/home, rak'ah count optional, private) feeding the journey view.
- **Qur'an Khatm planner:** pick a goal (1 Khatm = 1 Juz/day path pre-computed across 29–30 days with an adjustable slower/faster pace); daily portion shown as Juz + page range; progress ring; gentle catch-up re-planning ("2 extra pages/day") instead of guilt; Hifz/revision users can map their existing planner onto it.
- **Tonight strip:** Taraweeh time (Isha), tonight's portion, tomorrow's Sehri time — everything the user needs at 9 PM in one glance.

### 2.4 Last-10-nights / Laylatul Qadr mode (expected from ~21 Ramadan, ~28 Feb 2027)

- Activates automatically for the final ten nights (expected window; moon-shift aware).
- **Odd-night emphasis:** nights of 21, 23, 25, 27, 29 highlighted with a soft reminder to seek Laylatul Qadr; app never claims to know which night it is.
- Extra adhkar sugg
---

## 4. Launch money model: free + limited ads, PKR 500/month to remove ads — AI later

**Owner decision (2026-10-08):** NOOR launches **free**. Revenue at launch comes from **limited ads** plus a **PKR 500/month Remove Ads** subscription. The **AI layer is explicitly later** — it is not launch scope, not in the launch price, and not a launch cost. Until that later phase, the in-app AI remains the honest referenced databank search/sample experience already built. Suggested annual Remove Ads option: **PKR 3,999/year** (store price to be confirmed at submission); the model below conservatively uses PKR 500/month for everyone and a 15% store service fee, before taxes/withholding, refunds and chargebacks.

### 4.1 What “limited ads” means (trust rules — non-negotiable)

- **Frequency cap:** no more than **3 light interstitials per user per day**, only at natural breaks, **never fullscreen on app open**, and never back-to-back.
- **Sacred-space exclusion:** no ads of any format during **prayer/Salah flows, Qur'an reading, audio/recitation playback, the 16-line Mushaf, Reader, or Hifz-test screens**. No interstitials at all during those flows.
- **Banner-only surfaces:** a small banner may appear only on Home/Library-type browsing surfaces (and not inside the worship/reading surfaces listed above).
- **Ramadan pledge (even lighter):** during Ramadan days, **no interstitials — banner-only** on the allowed browsing surfaces. Rewarded ads remain only where a user deliberately taps for one (Share Studio/Settings) and are never inserted into a flow.
- **Family-safe categories:** block gambling, alcohol, dating, sexual, misleading health/finance and similarly unsuitable categories in the ad network controls; review category settings before launch and monthly.
- **No nag selling:** the one-tap Remove Ads entry lives only in **Settings/Profile**. No upsell popups, no countdowns, no blocking modals. Subscribed users see no banners/interstitials and no Remove Ads prompts.
- **Free means full core:** prayer times, Qur'an/Reader, reminders, Qibla, Tasbih/Salah tracking and the referenced databank search are **never paywalled** and never gated behind an ad.

### 4.2 Rewarded ads: voluntary, higher-value, non-worship only

Rewarded ads are **user-chosen** video ads: the user taps “watch an ad” and receives a stated reward after a completed view. They usually pay a much higher eCPM than banners/interstitials because the view is intentional and completed.

In NOOR, rewarded ads may be offered **only** in **Share Studio** and **Settings**, with a hard cap of **3 rewarded ads per user per day**, and only for non-worship rewards such as:

- unlock a premium share-card design or reel template for **24 hours**;
- unlock extra card designs for that day;
- **“ad-free until tomorrow”** for a user who cannot pay PKR 500 right now.

Rewarded ads must **never** gate Qur'an, prayer, reminders or any core content, and must never interrupt reading, listening, recitation, prayer tracking or a Hifz test. The reward must be granted only on a verified completed view, with an honest failure state if the network has no ad available.

**Cannibalisation — stated honestly:** the “ad-free until tomorrow” reward samples part of the paid benefit. Some users who might have paid PKR 500 will instead watch an occasional ad; rewarded design unlocks could also reduce a future paid design pack’s appeal. The model does **not** hide this: subscription conversion below should be read as net of normal rewarded use, and if rewarded usage becomes daily-heavy, cut the Remove Ads line by roughly 10–25% in sensitivity checks. PKR 500/month remains the convenience anchor: no daily watching, no effort, ad-free all month (and on the annual option, all year).

### 4.3 Year-1 scenario model (PKR) — assumptions first

These are **planning ranges, not promises**. “Year 1” means the first 12 months after launch (Ramadan spike inside it). Ad figures use publisher-side eCPM/revenue after the ad network’s own share (if a quoted eCPM is gross, deduct the network share first). Subscription revenue is after the 15% store fee, before taxes/withholding/refunds. Costs exclude the owner’s unpaid time, initial development already sunk, paid user acquisition and income tax.

**Common maths**

- Day-30 retained users `R = installs × Day-30 retention`: **600 / 4,000 / 21,000**.
- Remove Ads subscribers `S = R × conversion` at **0.8% / 1.5% / 2.5%** → **~5 / 60 / 525 subscribers**; average paid duration assumed **6 months** in Year 1 (installs arrive through the year). Revenue `= S × 6 × PKR 500 × 85%`.
- Free retained users `F = R − S`. Retained free user-months `= F × 6` (the same average 6 active months in Year 1).
- Limited banner/interstitial revenue `= F × 6 × PKR 30–90 per retained free user-month` (estimate for Pakistan/Android under the caps above; midpoint PKR 60 used for the point totals).
- Rewarded opt-in `= 5% / 10% / 15%` of free retained users, at **3 / 5 / 8 rewarded ads per opting user per month**, rewarded eCPM estimate **PKR 1,500 / 2,500 / 4,000 per 1,000 completed views**. General sensitivity range from the brief: **5–15% opt-in, 3–8 ads/month, PKR 1,500–4,000 eCPM**.
- Costs are lower than in the earlier AI-premium model because there is **no AI inference bill**: lightweight hosting/config/analytics, store/developer fees, ad-network/subscription operations, content checking and support tooling.

| Year-1 scenario | Installs | Day-30 retention → retained users | Remove Ads (net of 15% store fee) | Limited banner/interstitial ads | Rewarded ads (incremental) | **Total revenue (point estimate)** | Est. costs (no AI layer) | **Net (point estimate)** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Conservative | ~10,000 | 6% → 600 | ~PKR 12k | ~PKR 214k (range 107–321k) | **~PKR 1k** (range ~1–17k) | **~PKR 227k** | PKR 120–220k | **~PKR +7k to +107k** |
| Expected | ~40,000 | 10% → 4,000 | ~PKR 153k | ~PKR 1,418k (range 709k–2,128k) | **~PKR 30k** (range ~5–113k) | **~PKR 1,601k** | PKR 250–450k | **~PKR +1,151k to +1,351k** |
| Strong | ~150,000 | 14% → 21,000 | ~PKR 1,339k | ~PKR 7,371k (range 3,686k–11,057k) | **~PKR 590k** (range ~28k–590k) | **~PKR 9,299k** | PKR 500–900k | **~PKR +8,399k to +8,799k** |

*Reading the table:* PKR 1k = PKR 1,000; PKR 100k = 1 lakh. Point totals use the midpoint limited-ad value (PKR 60/free user-month) and the paired rewarded assumptions in each scenario. Rewarded is a **useful increment, not the engine**: it only becomes material in the Strong case (~PKR 5.9 lakh) because far more retained users opt in. Its strategic value is bigger than its cash: it lets non-payers earn premium designs or an ad-free day without touching worship, while PKR 500/month stays the effortless option. If limited-ad yield lands at the low end, Conservative can still be negative after costs; if a would-be subscriber switches to daily rewarded ad-free days, shave the Remove Ads line as noted in §4.2.