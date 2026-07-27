# Workflow integration analysis — brief for the 8:00 AM run

**Status:** blocked on source material. Everything below is ready to go the moment
the two posts are pasted in.

Kept in `.claude/` on purpose: this repo is served by GitHub Pages (see `CNAME`),
and dotfolders are not published. A root-level `.md` would have gone live on the
site.

---

## The two sources

- https://x.com/0xcodila/status/2079597821511020996
- https://x.com/0xmovez/status/2079985963862786352

## Why they aren't already summarized here

X returned HTTP 403 to every route reachable from the cloud container:
direct `x.com`, `r.jina.ai`, `xcancel.com`, `fixupx.com`. The last two are also
refused at the network-policy layer (the agent proxy answers 403 to CONNECT for
non-allowlisted hosts). Web search surfaced neither post's text — only that
@0xCodila posts on AI agent and loop topics, which is too thin to build on.

**This is a container/network limitation, not a dead end.** Running from a
personal machine with a logged-in browser sidesteps it entirely.

## What to bring to the 8:00 AM session

1. **Full text of both posts.** Screenshots work — images are readable. Whole
   threads, not just the first post.
2. **Any links the posts point to** (repos, docs, blogs). Non-X domains usually
   fetch fine, and the real tooling detail is normally there rather than in the
   post itself.
3. **What LTP stands for and what those workflows do day to day.** Nothing in
   this repo refers to it, so that half of the report can't be scoped without it.

## What gets produced

1. **Extraction** — every tool, model, protocol, and technique named, with what
   it does and whether it's production-ready or a demo.
2. **Signal vs. noise** — genuinely new capability vs. rebranding of something
   already in use. Claims verified against primary sources (docs, repos), not
   taken at face value from the posts.
3. **LTP workflow deltas** — which step of which workflow changes, what it
   replaces, what it costs, and the failure mode when it breaks.
4. **Compasse workflow deltas** — same, scoped to the product.
5. **Adoption order** — ranked by effort against payoff, with a "not yet, here's
   the trigger" bucket for things that aren't ready.

## Compasse context already gathered

Product: an iPad companion for families living with cognitive decline; answers a
parent's questions in a family member's recorded voice. Site is a single-page
build (`index.html`) plus `claim.html`, a `film/` walkthrough, and PDF guides
under `guides/`.

**One standing constraint to carry into the recommendations.** `index.html` loads
the Meta pixel with `autoConfig` set to `false` and deliberately fires no
`PageView` — only explicit conversion events. The comment in the source calls
autoConfig "the email-leak vector." That is a deliberate privacy posture, and
several currently-fashionable tooling trends contradict it directly: session
replay, behavioral analytics, third-party agent SDKs running client-side. Anything
in the two posts that pulls that direction gets flagged as conflicting rather than
quietly recommended.

Given the user base — families managing a parent's cognitive decline — this is
worth treating as a hard constraint rather than a preference.
