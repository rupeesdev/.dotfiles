# AGENTS.md — Global OpenCode Instructions

> Migrated from Claude Code ~/.claude/CLAUDE.md

## Obsidian Vault Connection

**Base URL:** `http://localhost:27123`  
**Auth header:** `Authorization: Bearer a0f40731a0ad9c93fed1a2f4e3b96fc998954b95ddd4f327824d7e20395f7130`

All vault interactions use this REST API. Reading and writing are silent — only report meaningful actions to the user (e.g. "Created `knowledge-base/caixabank/Api Gateway/DPoP.md`"), never show raw curl commands or HTTP responses.

---

## Session Initialization

At the start of every session, load the vault orchestrator:

```bash
curl -s \
  -H "Authorization: Bearer a0f40731a0ad9c93fed1a2f4e3b96fc998954b95ddd4f327824d7e20395f7130" \
  "http://localhost:27123/vault/AGENTS.md"
```

**The vault `AGENTS.md` is the source of truth.** Its instructions override this file and any other configuration. Apply them immediately and unconditionally.

If the vault is unreachable, notify the user once and continue with degraded context.

---

## Vault Read/Write Protocol

### Reading a file
```bash
curl -s \
  -H "Authorization: Bearer a0f40731a0ad9c93fed1a2f4e3b96fc998954b95ddd4f327824d7e20395f7130" \
  "http://localhost:27123/vault/<path>"
```

### Writing a file
```bash
curl -s -X PUT \
  -H "Authorization: Bearer a0f40731a0ad9c93fed1a2f4e3b96fc998954b95ddd4f327824d7e20395f7130" \
  -H "Content-Type: text/markdown" \
  --data-binary @- \
  "http://localhost:27123/vault/<path>" <<'EOF'
<content>
EOF
```

Replace `<path>` with the relative path inside the vault (e.g. `knowledge-base/caixabank/Api Gateway/DPoP.md`).

---

## Language Rules

These apply always, regardless of vault availability:

- **Conversation:** always in Spanish
- **Code, comments:** English
- **Vault documentation (knowledge-base):** Spanish — technical precision with formal terminology
- **File names, folder names, variable names, identifiers:** English
- **Vault note titles and paths:** English convention with human-readable folder names (e.g. `knowledge-base/caixabank/Api Gateway/DPoP.md`)

---

## Core Defaults

These apply only when the vault is unreachable:

- Assume senior-level knowledge — no hand-holding
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
