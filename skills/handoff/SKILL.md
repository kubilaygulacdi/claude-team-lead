---
name: handoff
description: Before the lead resets or ends a session (/clear, a new session, closing the terminal), check that the handoff file holds the current state, add what is missing, and say whether clearing is safe now. Use when the lead asks "handoff", "can I clear", "is it safe to clear", "clear için uygun mu", "session sıfırlayabilir miyim", or before you suggest /clear yourself. Works in any project, with or without the team-lead playbook.
---

# Handoff check before /clear

A `/clear` drops everything that lives only in this conversation. Before it, make sure a fresh session can pick up from the handoff file alone, then tell the lead whether clearing is safe now.

You can't run `/clear` yourself. The lead runs it after your verdict.

## 1. Find the handoff file

- Look in this order: `.pm/HANDOFF.md` (the team-lead convention), then `HANDOFF.md` at the repo root, then whatever the project's `CLAUDE.md` names.
- If there is none, create `.pm/HANDOFF.md` from `../claude-team-lead/templates/HANDOFF.md` (relative to this skill's directory), and make sure `.pm/` is gitignored.
- Read the file fully before checking it.

## 2. Collect the current state

**From the machine** (skip what doesn't apply to this project):
- **Git:**
  - `git status -sb` in the main checkout;
  - `git worktree list`, and for each worktree any uncommitted or unpushed work;
  - open PRs (`gh pr list`).
- **Agents:** list the running agents with the backend in use (herdr, tmux, or the `Agent` tool's background tasks). For each: name, model, worktree, task, and state (working, waiting on a question, done with an unread report).
- **Servers and previews:** each port, the PID that listens on it (`ss -ltnp 'sport = :<port>'`), its log, and how to restart it.

**From this conversation** (only you can see these; they are what `/clear` loses):
- **The lead's decisions:** their own words, quoted verbatim, with the date.
- **Open questions:** each proposal or question waiting on the lead's answer, with the exact text you proposed, so a fresh session can ask the same thing.
- **Promises:** work you said you would do next or after something else finishes.
- **Your background work:**
  - background commands, monitors and watchers;
  - background sub-agents;
  - scheduled wake-ups or cron jobs;
  - the address of an agent that replies to this session.
  Their results come back to this session only.
- **Half-done work:** a file partly edited, a merge or rebase in progress, a command whose result you haven't read.
- **Scratch files:** anything needed later that lives in the session's scratchpad or a temp dir. The scratchpad belongs to this session, and a new session gets a new one.
- **Durable preferences:** rules or preferences the lead gave that should outlive the project's current state.

## 3. Compare and fix

Go through the items above and check each against the handoff file. Fix what you can yourself:
- **The handoff file:**
  - Write what is missing and correct what is stale. Remove agents you closed, PRs that merged and questions the lead answered.
  - Keep the template's sections. It holds the current state, not a diary.
  - Update the "Updated:" line.
- **Durable preferences** go to memory, not the handoff file.
- **Durable project knowledge** goes to the area READMEs (via an agent in a team-lead project), not the handoff file.
- **Scratch files the next session needs:** move them next to the handoff file (for example `.pm/research/`), or note how to rebuild them.
- **Secrets:** never write keys or tokens into the handoff file. Name where they live (for example "`OPENAI_API_KEY` in `.env`").

## 4. Verdict

Clearing is **safe** when all of these hold:
- the handoff file covers every item from step 2, and nothing in it is stale;
- no background command, sub-agent, monitor or wake-up of this session is still running with a result you are waiting for, unless the handoff file says how to check that result without this session;
- nothing is half done;
- every open question to the lead is written in the handoff file with its full context;
- nothing needed lives only in the scratchpad;
- durable preferences are saved to memory.

Otherwise it is **not safe yet**. List each blocker with what removes it: wait for an agent's report, let a command finish, or ask the lead for an answer. After step 3, only things you can't fix yourself should be left.

## 5. Report to the lead

Use the lead's language (from memory or `CLAUDE.md`). Keep it short:
1. **The verdict, first:** "safe to clear" or "not yet", in the lead's language.
2. **What you added or changed** in the handoff file and memory, 2-5 bullets.
3. **Blockers,** if any, each with what removes it.
4. **The first prompt for the fresh session,** in a code block so it copies cleanly. For example: `Read .pm/HANDOFF.md, then memory, and continue from there.`
