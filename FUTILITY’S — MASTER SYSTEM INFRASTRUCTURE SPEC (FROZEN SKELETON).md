# FUTILITY’S — MASTER SYSTEM INFRASTRUCTURE SPEC (FROZEN SKELETON)
Version: v0.1-frozen
Scope: DigitalOcean + GitHub + Tailscale + Reverse Proxy + DB + Workers (NO Proxmox)
Goal: A rollbackable, always-available baseline platform where Futility’s bots have a “home” and
the full capture→propose→approve→publish workflow can run and evolve safely via PRs.

========================================================
0) HARD REQUIREMENTS (LOCKED)
========================================================
H0.1  Always-on baseline is REQUIRED.
      Reason: mechanics chat + websites + queue + DB must be reachable 24/7.
H0.2  Fully self-hosted runtime. You control VMs and model weights. No SaaS LLM dependency.
H0.3  PR is the mandatory doorway for all system changes affecting live behavior.
H0.4  Tailscale is used for admin access and for private worker<->baseline traffic.
H0.5  Public web: SSOT + Book + Proposed + Chat UI are reachable from the internet, but gated by pins.
H0.6  DB is Postgres + pgvector. Raw capture text archives after 90 days; derived objects persist.
H0.7  RunPod (or equivalent GPU provider) is used only for “hard question” escalation; gated by budgets+consent.

========================================================
1) STRUCTURE AT A GLANCE (COMPONENT MAP)
========================================================
Internet (Public)
  └── circlescorner.xyz → Reverse Proxy (Caddy) → Static sites + Web App

Private (Tailscale)
  ├── Admin access (SSH, dashboards, DB admin, logs)
  └── Ephemeral Workers (up to 8) connect privately to baseline to fetch jobs / push results

GitHub (Source of Recovery)
  ├── infra.git     (platform + deploy + policies)
  ├── ssot.git      (authoritative truth vault + published SSOT)
  ├── proposed.git  (proposed truth overlays + reports)
  └── book.git      (SSOT-only manual/wiki site)

========================================================
2) DEPLOYMENT TOPOLOGIES (INDECISION IS EXPLICIT)
========================================================
This skeleton supports multiple baseline layouts. Choose one at any time; migration paths are built in.

TOPOLOGY A (Simplest — single baseline VM)
  - 1 always-on VM hosts: reverse proxy + web app + queue + bot services + Postgres/pgvector + lightweight model
  - Pros: lowest complexity, fastest to bootstrap
  - Cons: DB shares resources; heavy jobs can threaten baseline without strict limits

TOPOLOGY B (Recommended — split DB for stability)
  - Baseline VM hosts: reverse proxy + web app + queue + bot services + lightweight model
  - Separate DB VM hosts: Postgres + pgvector
  - Pros: baseline stays stable; DB protected; easier scaling
  - Cons: second VM cost + slightly more networking setup

TOPOLOGY C (Baseline on cheaper provider + DO for burst)
  - Baseline VM runs at a provider chosen for lower monthly cost (still self-hosted)
  - DigitalOcean droplets are used only as ephemeral workers (or not at all)
  - Pros: lowers always-on bill while keeping burst flexibility
  - Cons: slightly more cross-provider networking consideration (solved via Tailscale)

DEFAULT FOR THIS SPEC:
- Implement TOPOLOGY A first (bootstrap + working skeleton).
- Design and document TOPOLOGY B as the near-term upgrade (DB separation).
- Keep TOPOLOGY C as an allowed future relocation without changing architecture.

========================================================
3) DIGITALOCEAN (OR BASELINE VM) HOST CONVENTIONS
========================================================
Host naming:
- baseline-1         (always-on)
- db-1               (optional, for topology B)
- worker-ephemeral-* (created/destroyed per job)

Filesystem layout (canonical on host; easiest from iPhone SSH):
/opt/futilitys/
  infra/        (infra.git clone)
  ssot/         (ssot.git clone)
  proposed/     (proposed.git clone)
  book/         (book.git clone)
  secrets/      (root-only .env and secrets)
  artifacts/    (job bundles, exports, archives staging)
  backups/      (db dumps, snapshot manifests)
  logs/         (structured logs, audit exports)

/var/www/
  ssot/         (built site output from ssot.git)
  proposed/     (built overlay/report output)
  book/         (built manual/wiki output)

========================================================
4) GITHUB (SOURCE OF RECOVERY + ROLLBACK)
========================================================
4.1 Repos
- infra.git: docker compose, caddy config, bot service stubs, scheduler/orchestrator, auth, budgets, UI
- ssot.git: authoritative vault + SSOT pages (only approved truth)
- proposed.git: proposed truth overlays and why-reports
- book.git: SSOT-only manual/wiki

4.2 Branching + environments
- main: staging (auto-deploy)
- tags: production deploy candidates
- production deploy is pull-based + manual

4.3 Mandatory PR rules
- All live-impacting changes require PR review.
- Coach is the only conversation interface; Architect produces PRs; Code Manager executes.

========================================================
5) TAILSCALE (PRIVATE PLANE)
========================================================
5.1 Purposes
- Admin-only access: SSH, dashboards, DB admin, logs, internal APIs
- Worker networking: ephemeral workers join tailnet, fetch jobs, return results privately

5.2 ACL intent (policy)
- baseline-1 exposes private ports only to:
  - admin devices
  - worker nodes
- db-1 (if present) exposes Postgres only to baseline-1 and admin
- workers expose no inbound ports (outbound-only)

5.3 Auth keys
- ephemeral auth key for workers (short-lived)
- admin devices are manually enrolled
- keys stored in /opt/futilitys/secrets with strict permissions

========================================================
6) DNS + REVERSE PROXY (PUBLIC SURFACE)
========================================================
Domain: circlescorner.xyz
DNS points A/AAAA to baseline public IP.
TLS via Caddy automatic cert management.

Public routes (pin-gated where required):
- /           → SSOT site (read-only)
- /book       → SSOT Book/manual site (read-only)
- /proposed   → proposed overlay viewer (requires mechanic code at minimum; management for some views)
- /chat       → mechanic chat UI (requires mechanic weekly code)
- /admin      → dashboards (requires manager PIN or admin auth; ideally Tailscale-only)

Important:
- Admin endpoints should be Tailscale-only whenever possible.
- If /admin must be public, enforce strong auth + rate limits + IP throttles.

========================================================
7) CORE SERVICES (DOCKER COMPOSE ON BASELINE)
========================================================
Services (baseline):
- caddy            (reverse proxy + static)
- webapp           (chat UI + APIs; pin entry; session mgmt)
- orchestrator     (queue scheduler; worker provisioner; budget enforcer)
- queue            (redis or equivalent)
- bots-frontdesk   (intake; helpfulness + capture)
- bots-ingestor    (normalize captures)
- bots-evaluators  (2–4 parallel evaluation services)
- bots-contradict  (contradiction hunter)
- bots-cite        (citation maker)
- bots-compiler    (proposed outputs + SSOT patch PR generator)
- bots-author      (book/manual generator from SSOT only)
- audit/logs       (structured log sink; optional lightweight UI)
- postgres         (topology A only; otherwise runs on db-1)
- pgvector         (extension within postgres)

All bots must support ENABLE flags:
- ENABLE_<BOT>=0/1 in env config
- when disabled, bot returns “not enabled” but logs calls.

========================================================
8) STORAGE + BACKUP + ARCHIVE (SSOT DISCIPLINE)
========================================================
8.1 DB backups
- daily pg_dump (encrypted if possible)
- pre-deploy snapshot dump for production deploys
- restore procedure documented and tested

8.2 Capture archive
- raw capture text archived after 90 days
- derived objects persist
- archive bundles stored with hashes + manifest in /opt/futilitys/artifacts

8.3 Git is not a backup of DB
- git backs configuration + SSOT/proposed/book content
- DB must be backed up separately

========================================================
9) WORKERS (UP TO 8 EPHEMERAL DROPLETS)
========================================================
9.1 Worker lifecycle
- orchestrator provisions N workers when job requires it
- workers join Tailscale
- workers pull job bundle from baseline via private API
- run containerized job
- push results back (DB write + artifact upload + optional git branch commit)
- self-destruct (or baseline destroys them)

9.2 Worker isolation
- no public inbound ports
- strict timeouts
- kill-switch if exceeded

========================================================
10) ESCALATION TO GPU (RUNPOD) WITH CONSENT + BUDGETS
========================================================
10.1 “Hard question” detection
- frontdesk classifies: lookup vs troubleshoot vs safety vs conflict vs low-confidence
- only hard questions create a Case File and request escalation

10.2 Consent
- if expected cost > 1.5x average: user is asked Yes/No
- if ceiling exceeded: manager PIN required

10.3 Budgets
- hybrid budget: GPU minutes + max escalations/day
- throttles: per-hour/per-day/per-week
- reporting: humans receive usefulness report + why useless calls happened

========================================================
11) AUTH MODEL (PINS, NO NAMES)
========================================================
Mechanics:
- individual weekly code (no names)
- used for: chat, proposed viewing, voting, rate limiting, trust scoring

Managers:
- manager PIN for dashboards + approvals + ceiling override

Admins:
- real admin auth (Tailscale + strong creds)
- can override gates explicitly (audited)

========================================================
12) GOVERNANCE WORKFLOW (COACH-ONLY CHAT)
========================================================
You talk ONLY to Coach.

Change pipeline:
1) You propose change to Coach
2) Coach generates Change Proposal
3) Philosopher reviews for philosophy/workflow integrity (silent)
4) Red Team challenges and stress-tests (silent)
5) If approved: Architect generates PR(s)
6) Coach shows you PR summary and options
7) Code Manager runs tests and deploys staging automatically
8) Production deploy is manual, pull-based, tag-driven
9) Rollback is always available and logged

========================================================
13) DEPLOYMENT MODEL (STAGING AUTO, PROD MANUAL)
========================================================
Staging:
- GitHub Actions deploys on merge to main (infra + app)
- staging can be same host with a separate compose project, or a small second VM
- staging is allowed to break; prod is not

Production:
- manual deploy from admin UI (or CLI) that:
  - selects a tag set (infra-vX, ssot-vY, proposed-vZ, book-vW)
  - pulls those tags
  - restarts services
  - runs smoke checks
  - records deploy event

Rollback:
- one-click revert to previous known-good tags
- restore DB from last pre-deploy dump if required
- record rollback in audit log

========================================================
14) DECISIONS LEFT OPEN (INTENTIONAL) + HOW SKELETON HANDLES THEM
========================================================
O14.1 Baseline provider and size
- skeleton works on DO or another VM provider
- size selection depends on whether DB is split and whether local inference runs

O14.2 DB location
- default start: DB on baseline (Topology A)
- upgrade path: DB on db-1 VM (Topology B) with Tailscale private connection

O14.3 Repo serving model
- default: host filesystem canonical (best for iPhone ops)
- upgrade: container-owned volumes optional later

These indecisions are not “unknowns” — they are supported choices with documented paths.

========================================================
15) “DONE” CRITERIA FOR SYSTEM INFRASTRUCTURE SKELETON
========================================================
Infrastructure skeleton is complete when:
- baseline VM can be rebuilt from scratch using infra.git
- DNS + TLS + reverse proxy routes work
- chat UI works behind mechanic code
- SSOT + proposed + book sites serve correctly
- Tailscale admin + worker networking works
- Postgres+pgvector runs and is backed up
- orchestrator can provision and destroy workers
- staging auto deploy works; prod manual deploy works; rollback works
- audit logs capture: who/what/why/how for changes, escalations, votes, promotions, deploys

END OF MASTER SYSTEM INFRA SPEC