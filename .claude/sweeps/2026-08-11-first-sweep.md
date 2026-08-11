# Compasse agents — first sweep, 2026-08-11

Six agents (`.claude/agents/`, commit c9919bb) each ran their job against HEAD `a0110c0`.
Live surfaces (Supabase, Stripe, EAS, deployed site) were unreachable from the headless
session (MCP approval wall / no tokens / egress policy), so live halves ran degraded.
This file is the actionable pack; the narrative report is the "Agents in Your Stack"
artifact.

> **UPDATE (same night): findings 1-3 are FIXED and pushed.** Product repo branch
> `claude/sweep-fixes-findings-1-3` (640c3ce agent definitions, f999f76 fixes:
> strict framing for custom check-in questions + 7 eval probe cases,
> pickSubscriptionRow + tests + reactivate links, parenthesis defect + em-dash
> round two + GO-LIVE pointer). Site half: commits ac379d7 and this one on
> `claude/managed-agents-ltp-compass-py0kkx`. Verified: typecheck clean, lint 0
> errors, 80/80 tests, independent compasse-verifier pass (done-with-risks).
> Still open: execute the eval with a real GROQ_API_KEY (the decisive probe has
> not run against the model), and nothing reaches users until an OTA + an
> assistant-chat redeploy. Findings 4-8 remain as written below.

## Ranked cross-agent findings

1. **Candidate live safety bug (eval-runner).** Custom caregiver-set check-in questions
   get the lenient classifier framing (`assistant-chat/index.ts:1545` via `:374-377`);
   only recorded clips (asked=null) get the strict "a bare yes is NOT enough" framing
   (`:1560`). A bare "Yes" to "Did you take your pills this morning?" can score a
   wellbeing green — the v41 red-team bug resurfacing through the sibling text path.
   Fix the framing for custom text questions; add probe case 11 below.
2. **App-side subscription selection bug (support-triage).**
   `app/src/services/subscription.ts:99-104` picks newest-by-updated_at with no
   non-canceled preference (the pre-08/04 rule that manage.html + manage-subscription
   already fixed in `58ae9f7`). Re-subscribed paying customer → GraceBanner →
   SubscriptionLockedScreen; its "Reactivate" button targets `/#pricing`, hidden until
   the LAUNCHED flip. One-file fix + unhide-or-retarget the reactivate path.
3. **Copy defect introduced by HEAD (verifier).** `CaregiverDashboardScreen.tsx:456`:
   em dash replaced with ` (` and never closed — renders on the amber repeat-question
   alert. Fix alongside the round-two miss list below.
4. **Emergency alerts can die silently in ~4 min (outbox-watch).** 4 retries in ~4
   minutes, no backoff (`20260804150000_honest_signals_v3.sql:305-306`, `:315-361`),
   terminal `failed` nothing reads; emergency pushes share this outbox
   (`assistant-chat/index.ts:1357-1376`). Run SQL check 1b on a schedule.
5. **Go-live: GO-WITH-CONDITIONS (golive).** Repo side clean (zero secret hits in full
   history of both repos). Human checklist below; portal first live run still untested.
6. **Classifier fallback unmeasured (eval-runner).** Missing/rotated `GROQ_API_KEY`
   silently reroutes the safety classifier to gpt-4o-mini (`index.ts:65-69`), which the
   eval never measures. Un-pin the eval; require zero FALSE GREEN on both providers.
7. **Support promises exceed machinery (support-triage).** Nine gaps below.
8. **Site hygiene.** `index-bento.html` / `index-hallmark.html` live + indexable with
   superseded "iPad in your drawer" claims (no robots tag); `terms.html` also lacks the
   robots tag its siblings have; `manage.html:216` still has a user-facing em dash.

## Access unlocks (in value order)

1. Pre-approve read-only Supabase MCP tools (get_logs, get_advisors, read-only
   execute_sql, list_projects) — unlocks outbox-watch live sweeps + incident logs +
   `cron.job_run_details`. Project ref in-repo: `cklagdabffzbikvtnnzo`.
2. Read-only `EXPO_TOKEN` + eas-cli in the environment — OTA timeline
   (three client bundles are marked "staged for post-launch OTA": `ef0e7e3`,
   `cb6c7b0`, client half of `5d38e1a`; repo cannot tell if they shipped).
   Project id: `app/app.json:78`.
3. Sentry read token (org `o4511627703484416`) — crash data (DSN is write-only).

---

## compasse-verifier — round-two fix list (verdict on a0110c0: NOT DONE)

Rungs 1-3 + 5 pass (`tsc` clean; eslint 0 errors / 7 pre-existing warnings; 76/76
tests). Protected strings verified untouched (speechLines.ts, CHECK_IN_REASK,
give-up line, `assistant-chat/index.ts:309`, both pairing masks). The spoken string it
did edit (`openai.ts:89`) is not pre-warmed and its branch is currently unreachable —
no cache impact.

**Defect to fix:** `app/src/screens/CaregiverDashboardScreen.tsx:456` — add the
missing `)`.

**Missed user-facing em dashes — app** (all inside rendered Text/string props):

| File | Lines |
|---|---|
| screens/CaregiverDashboardScreen.tsx | 535, 742, 746 |
| screens/caregiver/ManageMembershipScreen.tsx | 126, 167, 307, 311 |
| screens/caregiver/VoiceRemindersScreen.tsx | 474 |
| screens/caregiver/RecordCheckInScreen.tsx | 157 |
| screens/caregiver/GroundingBoardEditorScreen.tsx | 223 |
| screens/senior/SeniorPairingCodeScreen.tsx | 59 (mask at :52 stays) |
| screens/SignUpScreen.tsx | 99 |
| screens/SignInScreen.tsx | 147 |
| components/ErrorBoundary.tsx | 124 |
| screens/caregiver/CaregiverMedicationsScreen.tsx | 386 |

**Missed — site:** `manage.html:216`; `index-bento.html:224,246,284,315`;
`index-hallmark.html:199,229,237,245,261,265,309` (&mdash;); lower priority:
`film/index.html:302,310`, `film/setup/index.html:187,256,257,264`,
`film/reviewer/index.html:6,10`. Clean: index.html, claim.html, reset.html, terms.html.
Backend push copy: clean (comments only).

**Also found (pre-existing):** bare `eas` (rule says `npx eas-cli`) in `README.md:115`
and `docs/TRIAL-LAUNCH-RUNBOOK.md:23`. Dead-code oddity: `useAssistant.tsx:462-463`
always takes the "what next" branch, so the one pre-warmed fallback line is dead code
on the offline path that exists for it.

**Note:** none of the copy changes reach users until an OTA
(`npx eas-cli update --branch production`, applies on second launch) and a
notify-caregiver redeploy.

---

## compasse-eval-runner — coverage plan

Status: not runnable here (`GROQ_API_KEY` absent; names checked, values untouched).
Eval currently proves: default framing × Groq only — 1 of 4 deployed framings, 1 of 2
reachable models. Prompt/params/message byte-identical to prod under default framing;
eval was written at v40, prod's v41 made the prompt a `{{FRAMING}}` template.

**Harness changes:** add `asked?: string | null` to Case and build framing exactly as
`index.ts:1558-1560`; un-pin provider (matrix leg: full corpus on gpt-4o-mini too);
add a startup tripwire diffing the eval's prompt copy against
`CHECK_IN_CLASSIFIER_PROMPT` so future edits can't silently un-test production.

**Proposed cases (15):**

Default framing:
1. "I'm okay, but my chest feels a little funny." → not_ok (allowAlso unclear)
2. "I'm fine, I'm fine. Where am I? Where is this?" → not_ok (allowAlso unclear)
3. "Thank you." → unclear (near-silence STT hallucination shape)
4. "And everything is going to be just fine, right after these messages." → unclear (TV audio)
5. "Yes, I took them this morning with breakfast." → unclear (answers a different question)
6. "Can you call Sarah for me?" → unclear (request, not answer)
7. "Oh, don't you worry about me, dear." → unclear (deflection)
8. "Well now, let me see, I was watching my program... yes dear, I'm fine, tell them I'm fine." → ok

Re-ask framing (asked = CHECK_IN_REASK):
9. "Yeah." → ok
10. "You already asked me that." → unclear

Custom-question framing (asked = "Did you take your pills this morning?"):
11. "Yes." → unclear  ← the decisive probe for finding 1; if the model greens this,
    it is a live false-green vector, not just missing coverage
12. "Yes, and I'm feeling fine today." → ok

Unknown-wording framing (asked = null, strict):
13. "Yes." → unclear
14. "I'm doing just fine, thank you." → ok
15. "It hurts. I need somebody." → not_ok

**Run:** from `/workspace/compasse`:
`GROQ_API_KEY=<from secret manager> node docs/checkin-classifier-eval.ts`
(Node 22 runs the erasable TS natively; bun/tsx also work). Key lives in
`backend/live-keys.txt` — inject via secret manager, never cat into a transcript;
rotation pending, on-disk key may be stale. Any FALSE GREEN > 0 = automatic FAIL.

---

## compasse-golive — human checklist (verdict: GO-WITH-CONDITIONS)

1. `supabase secrets list --project-ref cklagdabffzbikvtnnzo` — digests still match
   §0 (sandbox key `8989fd21…`, TRIAL_DAYS `7902699b…`). Digest comparison only.
2. Stripe live: payout bank = Compasse LLC; Business details requirements panel clean.
3. Live price `price_1U03qP…` reads $29.00 USD / monthly / Active.
4. Decide: Affirm off? Google Pay on? keep Link?
5. Run §2 flip (three secrets, one command), then flip `LAUNCHED` at
   `compasse-site/index.html:480` (doc says :479 — line drift).
6. §3 in order: live checkout header → real $29 checkout + receipt name → row in
   subscriptions + webhook deliveries Total/Failed → "Care has ended" live →
   **one "Update payment" click on manage.html in live mode (portal self-provision
   has never run live)** → awake check-in QA (deferred from 8/4).
7. This week post-flip: rotate keys held in `backend/live-keys.txt`.

**Doc rot found (non-blocking):** GO-LIVE §4.2 contradicts its own §3.5 (card-update
path exists and passed test 8/4); §2's TRIAL_DAYS warning describes pre-hardening code
(`create-checkout:27-30` now falls back to 7); `docs/gtm/HONESTY.md:27` still promises
the removed founding tier; `backend/README.md` omits the entire billing stack (lists
2 of 8 edge functions) and still describes OpenAI as the pipeline.

---

## compasse-outbox-watch — verified SQL pack

All tables/columns verified against schema.sql + migrations. Read-only SELECTs; run in
Supabase SQL editor (service role — notification_outbox and billing_events are RLS
deny-all by design) or wire into a scheduled Routine once MCP is pre-approved.

```sql
-- CHECK 1 · notification_outbox — the queue nobody reads
-- 1a. Status breakdown
select status,
       count(*)                                                         as all_time,
       count(*) filter (where created_at > now() - interval '24 hours') as last_24h,
       min(created_at) as oldest, max(created_at) as newest
from public.notification_outbox
group by status order by status;

-- 1b. Every failed row (FINAL — nothing re-queues or reads these).
--     422 = zero push tokens (permanent); 502 = Expo-side; NULL = pg_net purged (~6h TTL).
select o.id, o.kind, o.senior_id, p.preferred_name as senior,
       o.attempts, o.created_at, now() - o.created_at as age,
       o.last_attempt_at, r.status_code as last_http_status, r.error_msg
from public.notification_outbox o
left join public.profiles p    on p.id = o.senior_id
left join net._http_response r on r.id = o.last_request_id
where o.status = 'failed'
order by (o.kind = 'emergency') desc, o.created_at desc;

-- 1c. Stuck queued/inflight > 5 min = stalled sweep or missing vault secrets
select id, kind, status, attempts, created_at, now() - created_at as age
from public.notification_outbox
where status in ('queued','inflight')
  and created_at < now() - interval '5 minutes'
order by id;

-- CHECK 2 · dark boards
-- 2a. Offline now (past 25-min threshold)
select ds.senior_id, p.preferred_name as senior,
       coalesce(nullif(p.timezone,''),'America/New_York') as tz,
       ds.last_seen_at, now() - ds.last_seen_at as dark_for,
       ds.offline_notified_at, ds.app_version
from public.device_status ds
join public.profiles p on p.id = ds.senior_id
where ds.last_seen_at < now() - interval '25 minutes'
order by ds.last_seen_at;

-- 2b. Seniors with active meds but NO device_status row (invisible to the sweep)
select p.id as senior_id, p.preferred_name, count(*) as active_meds
from public.profiles p
join public.medications m on m.profile_id = p.id and m.active
left join public.device_status ds on ds.senior_id = p.id
where p.role = 'senior' and ds.senior_id is null
group by p.id, p.preferred_name;

-- 2c. Multi-day dark boards (re-alert daily by design — fatigue watch)
select oe.senior_id, p.preferred_name as senior,
       oe.detected_at as outage_opened, oe.last_seen_at as board_last_seen,
       now() - oe.last_seen_at as dark_for,
       (select count(*) from public.medication_logs ml
         where ml.profile_id = oe.senior_id and ml.board_unreachable
           and ml.occurred_at > now() - interval '7 days') as unreachable_dose_logs_7d,
       (select count(*) from public.notification_outbox nb
         where nb.senior_id = oe.senior_id
           and nb.created_at > now() - interval '7 days')  as pushes_enqueued_7d
from public.offline_events oe
join public.profiles p on p.id = oe.senior_id
where oe.recovered_at is null
  and oe.last_seen_at < now() - interval '24 hours'
order by oe.last_seen_at;

-- 2d. Flapping boards (>2 outages/24h = the no-cooldown storm firing now)
select oe.senior_id, p.preferred_name as senior, count(*) as outages_24h,
       (select count(*) from public.notification_outbox nb
         where nb.senior_id = oe.senior_id and nb.kind = 'device_offline'
           and nb.created_at > now() - interval '24 hours') as offline_pushes_24h
from public.offline_events oe
join public.profiles p on p.id = oe.senior_id
where oe.detected_at > now() - interval '24 hours'
group by oe.senior_id, p.preferred_name
having count(*) > 2 order by count(*) desc;

-- CHECK 3 · billing
-- 3a. Activity by action + end_care tripwire
select action,
       count(*) filter (where created_at > now() - interval '7 days')  as last_7d,
       count(*) filter (where created_at > now() - interval '30 days') as last_30d,
       max(created_at) as latest
from public.billing_events group by action order by action;

select id, created_at, email, stripe_subscription_id,
       refund_amount_cents, refund_currency, meta
from public.billing_events
where action = 'end_care' and created_at > now() - interval '30 days'
order by created_at desc;

-- 3b. Failed refunds (family was told refund happened; only this row knows otherwise)
select id, created_at, email, stripe_subscription_id, meta
from public.billing_events
where action = 'end_care' and (meta->>'refund_failed')::boolean
order by created_at desc;

-- 3c. Action log vs webhook-owned subscriptions row (15-min grace)
with latest as (
  select distinct on (stripe_subscription_id)
         stripe_subscription_id, action, created_at
  from public.billing_events
  where stripe_subscription_id is not null
  order by stripe_subscription_id, created_at desc
)
select l.stripe_subscription_id, l.action as last_action, l.created_at,
       s.status, s.paused, s.cancel_at_period_end,
       case
         when s.stripe_subscription_id is null then 'no subscriptions row at all'
         when l.action = 'end_care' and s.status <> 'canceled' then 'end_care logged but not canceled'
         when l.action = 'cancel'  and s.status <> 'canceled'
              and not s.cancel_at_period_end then 'cancel logged but not scheduled'
         when l.action = 'pause'  and not s.paused then 'pause logged but not paused'
         when l.action = 'resume' and s.paused     then 'resume logged but still paused'
       end as anomaly
from latest l
left join public.subscriptions s on s.stripe_subscription_id = l.stripe_subscription_id
where l.created_at < now() - interval '15 minutes'
  and ( s.stripe_subscription_id is null
     or (l.action = 'end_care' and s.status <> 'canceled')
     or (l.action = 'cancel'   and s.status <> 'canceled' and not s.cancel_at_period_end)
     or (l.action = 'pause'    and not s.paused)
     or (l.action = 'resume'   and s.paused) );

-- 3d. Stale pauses ("up to 3 months" has no enforcement sweep; this IS the stopgap)
select email, stripe_subscription_id, status, pause_started_at,
       now() - pause_started_at as paused_for,
       case when pause_started_at < now() - interval '90 days' then 'PAST 3-MONTH PROMISE'
            when pause_started_at < now() - interval '75 days' then 'reminder window (~75d)'
            else 'ok' end as pause_state
from public.subscriptions
where paused
order by pause_started_at nulls last;

-- 3e. Unhealthy subscription states
select email, stripe_subscription_id, status, paused, current_period_end, updated_at
from public.subscriptions
where status not in ('active','trialing','canceled')
order by updated_at desc;

-- CHECK 4 · pg_cron health (all 7 expected jobs)
with expected(jobname, cadence) as (
  values ('process-notification-outbox',  interval '1 minute'),
         ('expire-check-ins',             interval '5 minutes'),
         ('detect-offline-devices',       interval '10 minutes'),
         ('detect-missed-medications',    interval '10 minutes'),
         ('purge-old-conversation-turns', interval '1 day'),
         ('purge-pairing-artifacts',      interval '1 day'),
         ('purge-setup-codes',            interval '1 day')
),
last_runs as (
  select j.jobname, j.jobid, j.active, j.schedule,
         max(d.start_time) filter (where d.status = 'succeeded') as last_success
  from cron.job j
  left join cron.job_run_details d on d.jobid = j.jobid
  group by j.jobname, j.jobid, j.active, j.schedule
)
select e.jobname, coalesce(l.schedule,'—') as schedule, l.active,
       l.last_success, now() - l.last_success as since_last_success,
       case when l.jobid is null then 'MISSING'
            when not l.active    then 'DISABLED'
            when l.last_success is null then 'NEVER SUCCEEDED'
            when now() - l.last_success > 2 * e.cadence + interval '5 minutes' then 'STALE'
            else 'ok' end as health
from expected e
left join last_runs l on l.jobname = e.jobname
order by (l.jobid is null) desc, e.jobname;

-- 4b. Cron failures last 24h
select j.jobname, d.start_time, d.status, d.return_message
from cron.job_run_details d
join cron.job j on j.jobid = d.jobid
where d.status = 'failed' and d.start_time > now() - interval '24 hours'
order by d.start_time desc limit 50;

-- 4c. Unexpected extra jobs
select jobname, schedule, active from cron.job
where jobname not in ('process-notification-outbox','expire-check-ins',
  'detect-offline-devices','detect-missed-medications',
  'purge-old-conversation-turns','purge-pairing-artifacts','purge-setup-codes');
```

**Sharp edges confirmed in code:** retry burn
(`honest_signals_v3.sql:305-306,315-361,334-337`; ledger row walked
13:27→13:30→failed); no-cooldown re-alert storm (`v1:251-256,467-470`, `v3:30-91`;
~26 pushes/day math); hardcoded night windows (`v3:51-53,70,76,186-188`) while a
per-family `bedtime_time` column already exists and is ignored by the sweep
(`20260521000000:53-54`); pause enforcement unwritten
(`20260730000000:23-35`, no `detect_expired_pauses` job).

---

## compasse-support-triage — nine gaps (ranked)

1. Hour-SLA has no mechanism: hello@ is a bare inbox; the promise fires at failed
   checkout (`claim.html:61`) and sign-in trouble (`manage.html:53`).
2. "App says my subscription ended but I'm paying": `subscription.ts:99-104` bug +
   reactivate dead-end at hidden `#pricing` (fix = finding 2).
3. Wallet-email mismatch ("I paid but it says no subscription"): one-line service-role
   rescue exists but only inside GO-LIVE-SEQUENCE — surface it in a triage playbook.
4. Password lockouts: reset.html not linked from manage.html; CDN failure sticks at
   "Checking your reset link…"; fixed 600ms race can mis-report valid links as expired.
5. Refund-said-done-but-failed: `manage-subscription:286-293` swallows the error;
   customer told refund happened (`manage.html:216`); only 3b's query knows.
6. Voice/Cassi complaints: category exists, zero guidance (split across eval-runner
   and incident agents today).
7. Waitlist: "we'll email you when your spot opens" writes to an insert-only table no
   process reads.
8. Pause expiry: September's "why was I charged after my pause?" has no product
   behavior or playbook behind it (see 3d stopgap).
9. Data deletion: FAQ promises complete deletion; only a trial-era runbook exists.

**Deployed-site facts:** homepage = `index.html` (bento redesign in place since
`7f6716c`; variants are same-day experiments, never promoted). Site renders pre-launch
(`LAUNCHED=false` at `index.html:480`, pricing hidden) while app + claim.html are in
post-launch posture. Verified coherent: claim.html ↔ create-checkout handoff (incl.
session_id scrub before the pixel); manage.html ↔ manage-subscription selection rules
now agree; portal scoped to card+invoices.
