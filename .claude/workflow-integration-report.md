# Graph Engineering — integration report

**Sources:** two X long-posts, pasted 2026-07-27.
- @0xCodila — *"Loop Engineering's successor…"* (5-step guide)
- @0xMovez — *"14-step roadmap"* (same thesis, more code)

**Scope:** what to adopt for Linville Team Partners (LTP) and for Compasse.

**Verification note.** Claims below are marked **[verified]** against a primary
source, **[confirmed-by-tooling]** where the running Claude Code environment's own
workflow tool documentation states the same thing, or **[unverified]** where
neither was possible. X and several doc domains are blocked at this container's
network policy; those are marked.

---

## 1. Extraction — everything the two pieces name

### The one product being described

Both articles are about a single feature: **dynamic workflows in Claude Code**.
Everything else is technique layered on it. Stripped of framing, the feature is:
Claude writes a JavaScript orchestration script, and that script spawns and
coordinates a fleet of subagents.

| Primitive | What it does | Status |
|---|---|---|
| `agent(prompt, opts)` | One subagent, one bounded job | [confirmed-by-tooling] |
| `parallel(thunks)` | Fan out concurrently; **barrier** — waits for all | [confirmed-by-tooling] |
| `pipeline(items, ...stages)` | Streams each item through all stages, **no barrier** | [confirmed-by-tooling] |
| `schema:` option | Forces validated structured JSON out of a subagent | [confirmed-by-tooling] |
| `isolation: 'worktree'` | Each agent in its own git worktree | [confirmed-by-tooling] |
| `model:` option | Route one node to a cheaper/costlier model | [confirmed-by-tooling] |
| `phase()` / `log()` | Progress grouping and narration | [confirmed-by-tooling] |
| `/workflows` | Watch a run live | [unverified] |
| `s` to save | Persist a run's script for re-use by name | [conflicting — see §2] |
| `/deep-research` | A shipped, production graph | [unverified] |
| `ultracode` | Session mode: plan a workflow for every substantial task | [confirmed-by-tooling] |

### Techniques named

1. **Node/edge discipline** — an edge exists only when data actually crosses. "And
   then" is not an edge.
2. **The contract** — bounded input, validated output, one job per node.
3. **The diamond** — fan out → reduce (plain code) → synthesize.
4. **Edges are free** — flatten/dedupe/filter is `flatMap` and a `Set`, not an agent.
5. **Runtime routing** — an agent classifies, code picks the branch.
6. **Verifier on the edge**, in three flavors: adversarial (N skeptics prompted to
   refute), perspective-diverse (distinct lenses), judge panel (N attempts, scored).
7. **Fresh context for the verifier** — Codila's sharpest point: a verifier sharing
   the executor's context "is agreeing with itself in a different font."
8. **Failure containment** — a thrown thunk resolves to `null`; `.filter(Boolean)`.
9. **Loop-until-dry** — stop after K empty rounds; **dedupe against everything seen,
   not against confirmed**.
10. **Model tiering** — cheap models on repetitive nodes, expensive on judgment.
11. **Anchors** — tests that actually ran, verifiers on evidence, frozen rules.
12. **When *not* to build a graph** — small/isolated tasks, work needing tight
    oversight, exploratory work, genuinely sequential chains.

### Named people / cases

- Peter Steinberger — "Are we still talking loops or did we shift to graphs yet?"
- Andrej Karpathy — via Codila's earlier "Loop Engineering: The Karpathy Method"
- The Bun Zig→Rust port — the load-bearing case study in both. See §2.

---

## 2. Signal vs. noise

### Verified and materially true

**The Bun port happened, and the numbers are real.** [verified]
535,000 lines of Zig → over 1,000,000 lines of Rust, 11 days, ~$165,000 in usage,
50+ workflows, 6,502 commits, peak ~1,300 lines/minute.

**But both articles mis-frame the concurrency, and it matters.**
Codila writes "a peak of 64 agents in parallel" directly after stating the ceiling
is "up to 16 working at once." A reader concludes one workflow fans out to 64. The
primary sources say otherwise: **4 workflows at once, each in its own worktree, 16
agents per workflow = 64.** The 16 cap is *per workflow*. Getting to 64 meant
running four separate workflows concurrently — an orchestration decision a human
made, not a dial inside one run. If you plan capacity off the articles you will
plan it wrong.

**The "zero tokens" claim splits the two authors.**
Movez asserts it twice, flatly: *"the coordination itself costs zero model tokens."*
Codila explicitly corrects it: *"the agents still cost usage. A workflow costs
meaningfully more than a normal session. The saving is in coordination, not the
work."* Codila is right. Movez's framing is the single most expensive
misunderstanding available in these two documents — at LTP scale it's the
difference between a $40 run and a $400 one.

**The criticism is real and both soft-pedal it.** [verified]
Codila says the Bun port "drew public criticism over whether that much AI-authored
code can be safely reviewed." What actually happened: Zig's creator publicly called
it **"unreviewed slop."** Movez omits the criticism entirely while using Bun as an
aspirational ceiling. Treat Bun as a *cautionary* case study, not a target.

**What the case study actually teaches, and neither article mentions:** the port ran
on a **300-rule guide** that translated line-by-line first and refined into
idiomatic Rust in later passes. The rules were the anchor — closer to Codila's
"frozen nodes" point than to anything about fan-out width. That's the transferable
lesson, and it's absent from both.

### Technically accurate

The mechanical claims check out against the tooling: `parallel()` as a barrier,
null-on-throw plus `.filter(Boolean)`, schema-forced structured output validated at
the tool-call layer, worktree isolation for parallel writers, and the
pipeline-over-parallel default (including Movez's "smell test" for
parallel→transform→parallel). Movez's §13 in particular reads as though written
from the actual tool documentation — it is the most reliable section across both
pieces.

The loop-until-dry warning — **dedupe against `seen`, not against `confirmed`** — is
correct and is the kind of bug that silently burns budget forever. Worth internalizing.

### Noise

- **"1000+ agent loops in one window."** Technically the lifetime cap exists, but in
  the tooling it is described as a runaway-loop backstop set far above any real
  workflow — not a target. Codila calls it "the feature's actual ceiling… and the
  scale is the point." It isn't the point. Real guidance runs to roughly **15 agents**
  per workflow.
- **"9/10 notice that half those steps never needed to wait"** (Movez) — invented
  precision. Codila makes the same observation without the fake statistic.
- **Save location conflicts.** Codila says `~/.claude/workflows` (user-global);
  Movez says `.claude/workflows/` (repo-local, version-controlled, "anyone who
  clones the repo can launch"). These are different things. The repo-local form is
  what the tooling references. Movez is likely right; verify before building process on it.
- **Version/plan specifics** — "v2.1.154+", Pro-vs-Max gating — [unverified], and
  the kind of detail that rots fast.
- Presentation tells: Movez's code blocks are labeled `python` but contain
  JavaScript, and two contain prose rather than code. Codila's piece carries an
  unedited template placeholder ("How far this scales (article name)"). Neither
  undermines the substance; both suggest speed over review.

### Gaps — real capability neither article covers

1. **Resume.** A workflow can be resumed from a prior run ID; unchanged agent calls
   return cached results and only the edited call onward re-runs. For expensive
   runs this is the single most valuable operational feature that exists, and
   neither piece mentions it.
2. **Budget control.** A token target can be read inside a script to scale fan-out
   dynamically or stop.
3. **`Date.now()`, `Math.random()`, and `new Date()` are unavailable inside workflow
   scripts** — they break resume. Anyone following Movez's "write your own script"
   advice hits this immediately with no warning.
4. **The 4096-item cap** per `parallel()`/`pipeline()` call.
5. **Worktree isolation is expensive** (~200–500ms plus disk per agent). Movez says
   "not a default tax" but never says why.
6. **Model tiering is over-sold.** Movez's §12 pushes it as a headline lever; actual
   guidance is to *omit* the model option by default and override only with high
   confidence.

**Net:** roughly 70% signal. The node/edge discipline, the fresh-context verifier,
the diamond, loop-until-dry, and the "when not to build a graph" section are
genuinely useful and correctly stated. The scale rhetoric is marketing. Read
Codila for judgment, Movez for mechanics.

---

## 3. LTP deltas — Linville Team Partners

LTP is commercial brokerage across office, industrial, retail, medical,
multifamily, land, investment and development, plus investment advisory,
development advisory and tenant/landlord representation. That work is
**document-heavy and research-heavy over many independent items** — which is
exactly the shape that pays for a graph. This is where the articles apply.

The test from Step 1, applied to LTP: *do these two items read each other's output?*
Fifty lease abstracts don't. Twenty comps don't. Eight submarkets don't. Every one
of those is a fan-out that's currently being run as a line — or by hand.

### 3.1 Lease / document abstraction — highest value

**Shape:** diamond. One node per document → schema-validated extraction → code
reduce → one synthesis node.

**What changes:** abstracting a stack of leases or LOIs one at a time becomes one
fan-out with a fixed output contract per document. The `schema` option is the
critical piece — it forces every abstract into the same validated shape (dates,
escalations, options, CAM treatment, assignment/sublease language), so results land
as a clean table rather than prose someone has to re-key.

**Verifier:** mandatory, and on **fresh context**. An extraction agent that misreads
a renewal option and then checks its own work will confirm the error. A second node
that never saw the first one's reasoning, given only the source clause and the
claimed value, will not.

**Failure mode:** a confidently wrong extracted date or dollar figure flowing into a
client deliverable. Mitigation: extract a **page/clause citation alongside every
field** and make the verifier check the citation, not the summary. This is Codila's
"anchors" point translated into brokerage terms.

**Not negotiable:** client documents under NDA go into a tool that transmits them.
Confirm that's permitted before the first run, not after.

### 3.2 Market / comp research — high value

**Shape:** the same skeleton as `/deep-research` — scope → parallel search →
verify → synthesize.

**What changes:** a submarket scan (rent comps, sale comps, absorption, deliveries,
vacancy) currently runs serially per source. Fan out one agent per source, reduce in
code, synthesize once. Weekly Triad market scans become a **saved workflow re-run by
name** rather than rebuilt each time.

**Failure mode:** the graph agreeing with itself — several agents citing the same
syndicated listing and reading it as three data points. Mitigation: dedupe on
property identity at the reduce step (code, not an agent), and require a source URL
per comp so the verifier can check provenance.

**Caveat:** CoStar and similar are licensed, authenticated sources. Automated
retrieval may violate terms. Verify per-source before wiring anything.

### 3.3 Offering memoranda / pitch materials — medium value

**Shape:** fan out per section, synthesize once, human edits last.

Sections of an OM are largely independent — property description, market overview,
demographics, financial summary, tenant profile. That's a genuine fan-out. But
positioning and narrative are the judgment layer and shouldn't be graph output.
Use it to eliminate the blank page, not to produce the document.

### 3.4 Site selection / tenant rep — medium value

**Shape:** router. Classify the requirement, branch to the right search depth. A
straightforward 3,000 SF retail requirement gets one pass; a multi-market industrial
search gets the full parallel treatment. This is Movez's §08 and it maps cleanly.

### 3.5 Where LTP should *not* use this

Applying the articles' own exclusion list honestly:

- **A single lease review, one property, one question.** Pure overhead — a single
  agent is faster and cheaper.
- **Anything client-facing without a human gate.** Non-negotiable in a licensed
  brokerage. Graphs produce drafts. A broker signs.
- **Negotiation strategy and pricing judgment.** Exploratory, sequential, and the
  place your actual expertise lives. The articles say it themselves: exploratory
  work wants one agent you can steer.
- **Anything where the underlying data is thin.** Fanning out over three usable
  comps produces confident-sounding output built on nothing.

### 3.6 Cost discipline

Bun cost $165,000 and needed a human designing and monitoring throughout. Nothing at
LTP is that shape. Start each new workflow **capped at ~20 items**, read the usage,
then widen — Codila's advice, and it's right. Expect a workflow to cost
meaningfully more than a normal session; Movez's "zero tokens" line does not apply
to the work, only to the coordination.

---

## 4. Compasse deltas

**Direct answer: almost none of this applies, and the articles explain why.**

Compasse is a single 30KB `index.html`, a 6KB `claim.html`, a film page, and two
PDF guides. Codila's exclusion list — *"the task is small or isolated… a workflow is
pure overhead here"* — describes this codebase precisely. There is no fan-out to
find. Applying a graph to a one-page marketing site would be building the machinery
in order to have built it.

Three narrow exceptions, all genuinely independent work:

**4.1 Pre-launch verification sweep — worth it.**
One agent per check, run wide, verified: copy claims vs. what the product actually
does; every link and asset resolving; the film page and setup walkthrough loading;
PDF guides matching on-page instructions; accessibility and contrast on the target
device. These are independent — that's a real fan-out — and the target audience is
families under stress on an iPad, where a broken link costs a customer.

**4.2 Claims audit — worth it, and highest-stakes.**
Compasse sells to families living with cognitive decline. Every claim on the page is
a claim made to a vulnerable buyer, and the repo history already shows a
claims-safe pass replacing an absolute privacy claim with named-processors framing.
A perspective-diverse verifier — one lens for medical/therapeutic overreach, one for
privacy and data handling, one for pricing and trial terms — is the correct tool.
The lenses catch different failures; three identical checkers would not.

**4.3 Analytics integrity check — worth it, narrowly.**
`index.html` deliberately sets `autoConfig` to `false`, fires **no** `PageView`, and
sends only explicit conversion events (`Lead`, `InitiateCheckout`, `StartTrial`)
through `metaEvent()`, mirrored server-side to a Supabase CAPI function with an
`eventID` for deduplication. That is a deliberate, documented privacy posture and it
is fragile — one careless edit reintroduces automatic form scraping, the exact
email-leak vector the source comment names. Worth a **frozen rule** in Codila's
sense: a check that runs on every change and is never allowed to be "optimized."

That check does not need a graph. It needs to be automatic. A single agent, or a
plain grep in CI, does it better and costs nothing.

**Everything else about Compasse — copy, design, positioning — is exploratory work
on a small surface. Keep it a conversation.**

---

## 5. Adoption order

Ranked by payoff against effort. Each step is small enough to abandon.

**1. Run one workflow on a real LTP task, capped at 20 items.** *(this week, ~1 hour)*
Lease abstraction across one stack of documents. Read the usage number before
widening. You will learn more from one scoped run than from re-reading either article.

**2. Add a fresh-context verifier to whatever you built in step 1.** *(same session)*
This is the highest-leverage idea in either piece and it's one extra node. Without
it a graph is a single loop wearing a costume.

**3. Adopt the Step 1 habit everywhere, with no tooling at all.** *(free, permanent)*
For every "and then," ask whether the next step reads the previous step's output.
This changes how work gets scoped whether or not a single workflow ever runs. It is
the most valuable thing in both documents and it costs nothing.

**4. Compasse claims audit + analytics integrity check.** *(this week, ~30 min)*
Not because it needs a fleet, but because the pixel posture is fragile and the
audience is vulnerable. Make it automatic and frozen.

**5. Save one LTP workflow and re-run it by name.** *(week two)*
The weekly Triad market scan is the natural candidate. Confirm the save location
first — the two articles disagree.

**6. Market/comp research fan-out.** *(week two–three, gated)*
Blocked until data-source terms are checked. Do not wire authenticated licensed
sources into automated retrieval on the strength of a blog post.

**7. Model tiering.** *(later, if cost becomes the binding constraint)*
Movez oversells this. Default guidance is to leave the model alone. Revisit only
when you have real usage numbers from steps 1–6 showing where spend concentrates.

### Not yet — with triggers

| Item | Trigger to revisit |
|---|---|
| Fan-outs beyond ~20 items | A scoped run completes with usage you find acceptable |
| Worktree isolation | You have agents that actually write files in parallel — not before |
| `ultracode` mode | You've run 5+ workflows and can predict their cost |
| Anything client-deliverable without a human gate | Never |
| Bun-scale ambition | Never; that project produced ~1M lines its own ecosystem called unreviewable |

---

## Appendix — verification status

| Claim | Status |
|---|---|
| Bun: 535K Zig → 1M+ Rust, 11 days, ~$165K, 50+ workflows, 6,502 commits | verified |
| Bun peak 64 = 4 workflows × 16 agents, not 64-in-one | verified; **both articles mis-frame** |
| Zig creator called it "unreviewed slop" | verified; both articles soften or omit |
| 300-rule translation guide underpinned the port | verified; **both articles omit** |
| 16 concurrent per workflow; 1000 lifetime cap | confirmed-by-tooling; 1000 is a backstop, not a target |
| `parallel()` barrier, null-on-throw, `.filter(Boolean)` | confirmed-by-tooling |
| `pipeline()` default over `parallel()` | confirmed-by-tooling |
| schema → validated structured output | confirmed-by-tooling |
| worktree isolation | confirmed-by-tooling; cost caveat omitted by both |
| Orchestration "costs zero tokens" | misleading as stated by Movez; Codila corrects it |
| Save path `~/.claude/workflows` vs `.claude/workflows/` | conflicting; repo-local likely correct |
| Claude Code v2.1.154+, Pro/Max/Team gating | unverified — claude.com blocked at network policy |
| `/workflows`, `/deep-research`, `s`-to-save | unverified |
| Steinberger and Karpathy attributions | unverified |

Blocked at this container's network policy: `x.com`, `claude.com`,
`simonwillison.net`, `movez.substack.com`, and the X mirrors. Bun figures were
verified through secondary reporting (Bun's own blog, The Register, developer press)
rather than the primary post.
