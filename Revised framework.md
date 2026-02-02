  



  

  

What changed from your prior “FROZEN” master framework spec:

  

1. Removed “frozen” language  
    

- Spec is now a living “baseline doctrine” that can evolve via PRs.

3.   
    
4. DB placement clarified + updated  
    

- Updated wording: “Database is self-hosted within the baseline stack (may be separate VM).”
- Baseline default now assumes DB runs on an external VM (still self-hosted).

6.   
    
7. Tailscale tightened  
    

- Admin access is Tailscale-only (no public admin fallback).
- DB is reachable only over Tailscale from baseline + admin.

9.   
    
10. Infra spec merged into the master spec  
    

- The platform structure (domain, reverse proxy, repos, deploy model, workers, budgets) is now first-class inside the same master spec so there’s no “dual SSOT.”

12.   
    

  

  

  

  

# FUTILITY’S — MASTER BASELINE SPEC

Version: v0.2

Purpose: A rollbackable, self-hosted baseline platform that is “ready for bots” and supports

the full information-flow architecture (capture → evaluate → propose → approve → publish),

with strict auditability, deterministic rollback, and grumpy-mechanic-safe UX.

  

========================================================

0) PRIME DIRECTIVES (NON-NEGOTIABLE)

========================================================

D0.1  SSOT is sacred.

      Authoritative SSOT is never edited/published without human approval,

      except when auto-promotion rules (defined below) are met.

      Even then: an SSOT patch + audit record is produced and remains reviewable.

  

D0.2  Conversation is not truth.

      All conversational outputs are untrusted unless explicitly SSOT-backed.

  

D0.3  Truth is compiled.

      Bots may propose, score, contradict, and cite — but SSOT publication is gated.

  

D0.4  Change control is mandatory.

      Every change (code/config/pipeline rules) must go through a PR before it can affect live system.

  

D0.5  Everything is reproducible.

      Inputs, model versions, configs, outputs, approvals, and promotions must be logged.

  

D0.6  Rollback is first-class.

      Known-good tags, deploy/rollback procedures, and full audit trail must exist and be testable.

  

========================================================

1) WHAT “BASELINE” MEANS

========================================================

The baseline is the stable framework you can always return to when future work breaks things.

  

Baseline guarantees:

- Services run reliably 24/7.

- Bots have a home (endpoints, queues, DB schema, repos, toggles).

- The full information flow is implemented structurally (bots may be stubs initially).

- Governance gates and trace/rollback are enforceable.

- A rebuild-from-scratch procedure exists (infra.git) and is tested.

  

This spec is the doctrine for the platform structure and trust boundaries.

Future expansions must be implemented via PRs and must not violate the prime directives.

  

========================================================

2) GIT REPOS (SOURCE OF RECOVERY)

========================================================

R2.1  infra.git

  Contains:

  - docker compose stacks

  - reverse proxy config

  - deployment scripts + rollback scripts

  - dashboards UI (mechanic/manager/admin)

  - queue/orchestrator + worker provisioner

  - authentication + policy configs + budgets

  - bot service stubs and service contracts

  Tags:

  - infra-vX.Y.Z (known-good baseline points)

  

R2.2  ssot.git (Authoritative SSOT)

  Contains:

  - only approved truth content

  - Obsidian vault output (SSOT view)

  - published SSOT pages rendered from SSOT

  Tags:

  - ssot-vX.Y.Z

  

R2.3  proposed.git (Proposed Truth)

  Contains:

  - proposed truth overlays/patches (NOT authoritative)

  - confidence + why reports

  - versioned proposals produced by pipeline

  Tags:

  - proposed-vX.Y.Z

  

R2.4  book.git (SSOT “Book / Manual / Wiki”)

  Contains:

  - traditional wiki/manual site derived ONLY from SSOT

  - macro→micro explanation + troubleshooting guides

  - system operation docs (only if sourced from SSOT)

  Tags:

  - book-vX.Y.Z

  

Rule: No PR-free changes to any repo used by the live system. All changes must be PR’d.

  

========================================================

3) HOSTING MODEL (VMs + NETWORK)

========================================================

Baseline components are split into:

- Public baseline VM (always-on)

- Private DB VM (always-on, self-hosted)

- Optional ephemeral worker VMs (on-demand)

- Optional GPU escalation provider (on-demand)

  

3.1 Baseline VM (always-on)

Runs:

- reverse proxy + TLS termination

- web app (chat UI + viewers + APIs)

- queue/orchestrator + scheduler

- bot services (frontdesk + pipeline services)

- monitoring/logging/audit endpoints

Does NOT expose admin services publicly.

  

3.2 DB VM (always-on, external to baseline VM)

Runs:

- PostgreSQL + pgvector

Exposed only over Tailscale to:

- baseline VM

- admin devices

  

3.3 Workers (on-demand, up to N)

- provisioned by orchestrator for batch jobs

- join Tailscale

- pull job bundles, compute, push results

- destroyed automatically after completion or timeout

  

3.4 GPU Escalation (on-demand)

- used only for “hard question” escalation (budgeted + consented)

- receives structured Case Files only

- returns results into capture/proposed pipeline (never directly into SSOT)

  

========================================================

4) TAILSCALE (PRIVATE PLANE)

========================================================

T4.1 Admin access is Tailscale-only.

- SSH, dashboards, DB admin, internal logs, and internal APIs are not publicly exposed.

  

T4.2 DB access is Tailscale-only.

- Postgres listens only on Tailscale interface.

- baseline VM connects via Tailscale IP/hostname.

  

T4.3 Worker networking uses Tailscale.

- workers have no public inbound ports

- workers call baseline/DB privately

  

T4.4 Keys and auth

- admin devices are manually enrolled

- workers use ephemeral join keys

- secrets stored on baseline VM (root-only) and never committed to git

  

========================================================

5) DOMAIN + REVERSE PROXY (PUBLIC SURFACE)

========================================================

Domain: circlescorner.xyz

  

Reverse proxy + TLS:

- Caddy (or equivalent) terminates HTTPS for public pages.

  

Public routes (all require mechanic weekly code login at minimum):

  /            → SSOT site (read-only)

  /book        → SSOT Book/manual site (read-only)

  /proposed    → Proposed overlay viewer (requires mechanic code; some actions require manager PIN)

  /chat        → Mechanic chat UI (requires mechanic code)

  

Admin routes:

  /admin       → Manager dashboards (MUST be Tailscale-only; no public access)

  /admin/sys   → Admin-only controls (Tailscale-only)

  

Rule: Public pages are read-only; privileged actions are protected and audited.

  

========================================================

6) DATABASE (SELF-HOSTED WITHIN BASELINE STACK)

========================================================

Definition:

- “Self-hosted within the baseline stack” means: Futility’s controls the DB on a VM you control.

- DB may be on the baseline VM or (recommended) a separate DB VM.

  

Baseline default:

- DB on separate VM (stability + protection), connected via Tailscale.

  

DB tech:

- PostgreSQL + pgvector

  

DB stores:

- captures

- candidate claims

- votes (bots + mechanics)

- conflicts

- citations

- proposals and promotion records

- audit logs (deploys, PRs, approvals, escalations)

- budgets and rate limits

- user codes (mechanic weekly codes), manager PIN records, admin auth metadata

  

Archive policy:

- raw capture text archived after 90 days (compressed, hashed, retrievable)

- derived objects persist indefinitely

  

========================================================

7) QUEUE + ORCHESTRATOR (ALWAYS-ON)

========================================================

The orchestrator is responsible for:

- ingest scheduling

- evaluation scheduling (parallel)

- compilation to proposed + SSOT PR

- book build triggers

- worker provisioning and teardown

- budget enforcement and escalation gating

- reprioritizing queue when budgets are tight

  

Rate limiting and budgets:

- per-user (mechanic code) throttles

- system-level caps per hour/day/week

- escalation budgets tracked as hybrid:

  - GPU minutes

  - escalation count/day

  

========================================================

8) BOT SERVICES (CONTAINERIZED; ENABLE/DISABLE)

========================================================

All bots run as containerized services (or stubs) with explicit toggles.

  

Core bots:

- frontdesk (single user chat intake; produces Helpfulness + Capture)

- ingestor (normalize captures)

- evaluators (2–4 parallel truth evaluators)

- contradiction hunter

- citation maker

- compiler (produces proposed truth + SSOT patch candidates)

- author (builds SSOT-only book/wiki output)

  

Governance bots (you only talk to Coach):

- coach (only conversational governance interface)

- philosopher (silent gate)

- red team (silent challenger)

- architect (builder that generates PRs)

- code manager (executor: tests/deploy/rollback)

  

Rule: A disabled bot must respond “not enabled” and log that status.

  

========================================================

9) ACCESS CONTROL (MECHANICS / MANAGERS / ADMINS)

========================================================

Mechanics:

- Each mechanic has an INDIVIDUAL weekly code (no names required).

- Identity = weekly code + internal ID.

- Mechanic code required to:

  - chat

  - view proposed overlay

  - cast votes

  

Managers:

- Separate manager PIN required to:

  - view dashboards (Tailscale-only)

  - approve SSOT patches

  - override escalation ceiling

  - issue/revoke mechanic weekly codes

  - approve promotions (when required)

  

Admins:

- Admin access is Tailscale-only + strong auth.

- Can:

  - direct authorize auto-publish events (explicit)

  - manage budgets and system policy

  - approve/override philosopher/redteam gates (explicit + audited)

  - emergency rollback

  

========================================================

10) SINGLE CHAT (TWO OUTPUT CHANNELS)

========================================================

Users talk to ONE chat interface (frontdesk). Every assistant response contains:

  

10.1 Helpfulness channel (“Answer — Untrusted”)

- natural language

- may advise/plan/hypothesize

- may only assert facts about the system if SSOT-backed

- must label opinions/predictions clearly

  

10.2 Capture channel (“Captured items — Unverified”)

- structured logs + IDs (CAP, CAND-CLAIM, Q, TASK)

- preserves raw user text verbatim (hash + timestamp + user_code)

- never decides truth

- all candidates unverified by default

  

========================================================

11) QUESTION-ASKING UX (GRUMP MECHANIC SAFE)

========================================================

Clarifying questions only if ALL gates pass:

- human-observable now

- decision-changing

- low effort

  

Budget:

- max 1–2 questions per exchange

- max one follow-up round

If user signals “just noticed / don’t know” → do not ask; proceed via inference or escalation.

  

========================================================

12) INFORMATION FLOW (CAPTURE → PROPOSE → PUBLISH)

========================================================

12.1 Capture ingestion

- every user message creates CAP-… stored in DB

- system extracts candidates (CAND-CLAIM, Q, TASK)

  

12.2 Ingestor

- normalizes captures into structured records

  

12.3 Evaluator swarm (2–4)

- produces vote objects (confidence, rationale, evidence pointers)

  

12.4 Contradiction hunter

- produces conflict objects, never silently resolves

  

12.5 Citation maker

- builds citation chains claim→capture/source

  

12.6 Compiler (sacred)

Produces:

  (a) Proposed Truth overlay + report → proposed.git

  (b) SSOT patch candidate PR → ssot.git (PR gated)

Compiler must:

- never guess

- refuse if insufficient evidence

- output provenance: inputs/hashes/model versions/configs/citations

  

12.7 Author (SSOT-only book/wiki)

- consumes ONLY SSOT content

- generates book.git output (polished, navigable)

- never invents content; only organizes/summarizes SSOT

- build triggered on SSOT publish (or scheduled) and is auditable

  

========================================================

13) VIEW LAYER (SSOT + PROPOSED TOGGLE)

========================================================

Single viewer:

- default shows SSOT (authoritative)

- toggle: show proposed overlay in context (clearly labeled + confidence)

- toggle: show full proposed report (why + evidence)

  

Voting:

- from viewer mode, mechanic can vote per proposed item:

  OBSERVED / HEARD / GUESS / FALSE

- votes adjust proposed confidence/priority and can trigger review

- votes do not directly edit SSOT; they influence promotion gates

  

========================================================

14) AUTO-PROMOTION (PROPOSED → SSOT)

========================================================

SSOT normally requires human approval. Auto-promotion is allowed only under strict gates:

  

Condition A: Admin direct authorization at the time of event (explicit)

OR

Condition B: Proposed truth exists + Manager approves

OR

Condition C: Proposed truth exists + 5 trusted mechanics vote it true

  

Trusted mechanic scoring:

A mechanic becomes “trusted” when BOTH thresholds are met:

(1) reliability threshold:

    - >= 20 historical votes

    - >= 90% agreement with later-approved SSOT outcomes

(2) contribution threshold:

    - their submitted claims/captures have resulted in SSOT acceptance at a meaningful rate

  

Auto-promotion still produces:

- an SSOT patch PR

- provenance record

- record of which condition triggered promotion

  

========================================================

15) ESCALATION (GPU / HEAVY MODEL) WITH CONSENT + BUDGETS

========================================================

Hard-question detection triggers a Case File:

- asset_id

- symptoms (verbatim + normalized)

- user answers (if any)

- retrieved history

- constraints

- unknowns

- requested output

  

Consent + ceiling:

- if expected cost > 1.5× average escalation cost: user Yes/No

- if ceiling exceeded: manager PIN required

  

Budgets:

- hybrid budget: GPU minutes + escalation count/day

- per hour/day/week limits

- reprioritizer can defer/bundle/attempt internal solve first

  

Reporting:

- humans receive periodic reports on usefulness + why useless calls occurred

  

========================================================

16) GOVERNANCE (YOU TALK TO COACH ONLY)

========================================================

Coach is your only governance conversation interface.

  

Philosopher + Red Team:

- silent gatekeepers; approve/reject based on philosophy and adversarial challenge

  

Architect:

- implements approved proposals by generating PRs (no direct chat with you)

  

Code Manager:

- runs tests, deploys staging, deploys prod (manual approval), rolls back

  

========================================================

17) CHANGE CONTROL (PR IS THE DOORWAY)

========================================================

All live-impacting changes must:

- start as a Change Proposal (created by Coach)

- be gated by Philosopher + Red Team

- be implemented as a PR (by Architect)

- be tested (by Code Manager)

- be merged before affecting live system

  

No hot edits to production code/config.

  

========================================================

18) DEPLOY / ROLLBACK (STAGING + PROD)

========================================================

Staging:

- GitHub Actions deploys on merge to main (infra + app)

- staging may be separate compose project or separate VM

  

Production:

- manual deploy is pull-based and tag-driven

- deploy selects tags: infra-vX, ssot-vY, proposed-vZ, book-vW

- runs smoke checks; records deploy event

  

Rollback:

- checkout last known-good tags

- redeploy

- restore DB from pre-deploy dump if required

- record rollback event

  

========================================================

19) RESOURCE PROTECTION (BASELINE INTACT)

========================================================

Baseline must remain stable under load:

- systemd slices/cgroups:

  - baseline.slice: reverse proxy + webapp + queue/orchestrator (and DB if co-located)

  - batch.slice: heavy local jobs

  - dev.slice: optional dev tooling

- memory/CPU priorities protect baseline

- controlled swap enabled to prevent catastrophic collapse

  

========================================================

20) SUCCESS CRITERIA (BASELINE COMPLETE)

========================================================

Baseline is “complete” when:

- baseline VM can be rebuilt from infra.git with one documented procedure

- domain + TLS + reverse proxy routes work

- chat UI works behind mechanic weekly code

- SSOT/proposed/book viewers work (proposed may be empty initially)

- Postgres+pgvector runs on DB VM over Tailscale; backups run; restore tested

- orchestrator queue works; worker provisioning works (even if disabled by default)

- budgets + escalation consent + manager override work

- PR-based change control is enforced

- audit logs exist for: captures, votes, promotions, PR merges, deploys, rollbacks, escalations

- rollback to known-good tags works and is tested

  

END OF MASTER BASELINE SPEC