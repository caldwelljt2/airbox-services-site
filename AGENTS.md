<!-- AI:SKIP-START -->

This file, AGENTS.md, is designed to be the first thing any non-human agent should read before any discussion or work is performed. It follows the convention outlined here: (url)

Human-readable walkthrough (for people; AI should skip to "Agent Instructions")

codex follows this path:
1. Open the repo at its root.
2. Look for a `.ai-vault` file. If it exists, it contains the absolute path to the project’s external AI Vault.
3. If `.ai-vault` is missing, run `~/AI-Vault/bin/vault-bootstrap` from the project root. This creates the project vault folder under `~/AI-Vault/projects/<project>/`, writes `.ai-vault`, and adds a convenience symlink `external-docs/` (ignored by git).
4. Acquire a working lock to avoid concurrent writes: `~/AI-Vault/bin/vault-with-lock $(pwd) <your-command>` (or just hold the lock in a separate shell while working).
5. Read the vault’s `CONTEXT.md` and `DECISIONS.md`, then skim the most recent file in `TRANSCRIPTS/`.
6. Start a new transcript for the session (people can run): `~/AI-Vault/bin/vault-new-session <project-slug>`.
7. Do the work. Keep changes minimal and focused; avoid network/destructive actions without confirmation.
8. Record any choices in `DECISIONS.md` (project vault). Update `CONTEXT.md` if architecture/deploy changes.
9. End the session by summarizing what changed in the transcript. Include file paths and next steps.
10. Release the lock (Ctrl+C if you held it) and push/PR per repo norms.

<!-- AI:SKIP-END -->

**Agent Instructions**

Quick start
- Run `scripts/ai-vault-session.sh` from the repo root.
  - It locates the AI‑Vault path (via `AI_VAULT_DIR`, `.ai-vault`, or prompt), writes `.ai-vault` if needed, and creates a temporary symlink `external-docs.session` to the project folder in the vault.
  - It starts a new transcript and launches terminal recording. Type `exit` to finish; it cleans up the symlink and syncs the vault. It can optionally push website changes.

- Run `~/AI-Vault/bin/vault-pull` then `~/AI-Vault/bin/vault-check-version` at session start to pick up ops changes.

- **Purpose:** Provide clear, repeatable startup steps for agents and point to persistent context stored outside this repo (AI Vault).

- **Locate Vault Pointer:**
  - Preferred: `scripts/ai-vault-session.sh` will prompt for the AI‑Vault path if it cannot be auto‑detected and will write `.ai-vault` for future sessions.
  - Manual: Read `.ai-vault` at repo root (absolute path to `~/AI-Vault/projects/airbox-services-site`). If missing, run `~/AI-Vault/bin/vault-bootstrap` and re‑read `.ai-vault`.

- **Concurrency Lock:**
  - Before writing files, ensure only one agent is active in this repo.
  - Preferred: run work under `~/AI-Vault/bin/vault-with-lock $(pwd) <command>` or hold a lock separately. This uses an atomic `.codex.lock` directory.

- **Load Context (read in this order):**
  - Vault `CONTEXT.md`: project overview, stack, deploy, domains, branching.
  - Vault `DECISIONS.md`: project-specific decisions and rationale.
  - Latest vault `TRANSCRIPTS/<YYYY-MM-DD>_session-XX.md` for recent work.
  - In-repo `README.md` or other local docs if referenced by the context above.

- **Session Hygiene:**
  - Start/append a transcript (user may run): `~/AI-Vault/bin/vault-new-session <slug>` and capture: goals, files touched, summary, next steps.
  - Record important choices in `DECISIONS.md` using the template (what/why/alternatives/impact).
  - Keep `CONTEXT.md` updated when deployment, domains, secrets handling, or branching policies change.

- **Repo Rules:**
  - Do not commit secrets or tokens. Respect existing `.gitignore` (includes `/external-docs/`).
  - Keep changes minimal, targeted, and aligned with existing style.
  - Prefer root-cause fixes over surface patches when scope allows.

- **Deploy Overview (read-only unless asked):**
  - Static site built by Hugo; GitHub Actions deploys `public/` to `gh-pages` on pushes to configured branches.
  - Custom domain via `static/CNAME` of `www.airboxinc.com`.

- **Key Paths & Tools:**
  - Repo pointer: ``.ai-vault``
  - Ephemeral session symlink (auto‑cleanup, ignored): ``external-docs.session`` → project vault folder
  - Vault helper commands (human-run):
    - New transcript: ``~/AI-Vault/bin/vault-new-session <slug>``
    - Quick note: ``~/AI-Vault/bin/vault-note <slug> "text"``
    - Open folder: ``~/AI-Vault/bin/vault-open <slug>``
    - Version check: ``~/AI-Vault/bin/vault-check-version`` (run at session start)
    - Locking: ``~/AI-Vault/bin/vault-with-lock $(pwd) <command>``

- **When Unsure:**
  - Ask the user before running networked or potentially destructive commands.
  - If vault pointer looks invalid, pause and request confirmation of the correct path.
