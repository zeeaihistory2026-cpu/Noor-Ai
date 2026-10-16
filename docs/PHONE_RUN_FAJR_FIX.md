# NOOR phone run — Fajr reminder trap found and fixed (2026-10-08)

Found while the owner was mid phone-test (APK sent 2026-10-08 10:47 UTC).

## The trap

Step 8 of the phone tour says: turn Fajr ON in the afternoon, swipe
NOOR away, and it must ring while closed. In the APK first sent,
that could never happen for tomorrow morning:

- `NotificationPlan.buildSalahPlan` drops entries already in the past.
- `ReminderCenterScreen._reschedule` only planned **today**.
- So Fajr today (already past) was dropped, and no Fajr was ever
  scheduled for tomorrow. The reminder would only ring if the user
  reopened the Reminder Center on the day itself.

## The fix (this build)

- `NotificationPlan.buildFullPlan` accepts an optional `nextDay` and
  includes its Salah entries.
- `ReminderCenterScreen._reschedule` now fetches tomorrow's exact
  prayer times from AlAdhan (method from settings) and plans today +
  tomorrow. If the network call fails, it falls back to today's
  times shifted +1 day (accurate to about a minute).
- New regression test in `test/phase8_test.dart`:
  "full plan rolls Salah reminders into tomorrow" — builds a plan at
  4 PM and requires exactly one Fajr entry, at tomorrow Fajr −15 min.

## What the tester should see (Karachi, method 5 — University of
## Islamic Sciences, Karachi)

- Today Thu 8 Oct 2026: Maghrib ~6:12 PM (reminder 5:57 PM),
  Isha ~7:28 PM (reminder 7:13 PM). Either one ringing with the app
  swiped away proves closed-app scheduling **tonight** — no need to
  wait for Fajr to learn the result.
- Tomorrow Fri 9 Oct 2026: Fajr ~5:11–5:13 AM, so the Fajr reminder
  should ring at about **4:56–4:58 AM** with the app closed. After a
  phone restart the same applies (scheduled notifications survive
  reboot via the boot receiver); re-opening NOOR once after restart
  re-plans today+tomorrow and is the safest belt-and-braces step.
- Qibla from Karachi: ~268°, i.e. just south of due West.

Independent public timetables for Karachi on 8 Oct 2026 agree within
a few minutes (Maghrib 18:10–18:14, Isha 19:23–19:42 depending on
school/method); the app uses AlAdhan method 5, so use the times the
app itself shows on Home as the reference when judging.
