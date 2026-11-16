# Backend: herdr

The six operations of SKILL.md §2 with [herdr](https://herdr.dev). Each task gets its own git worktree and opens as a **tab in the TL's own workspace**: the one the lead started the TL in (`$HERDR_WORKSPACE_ID` in the TL's shell). That way the agents sit under the TL wherever it runs. The TL's own tab stays a single pane.

Don't open agents with `herdr worktree create` / `herdr worktree open`, or with a bare `herdr workspace create`. Each of those makes a separate workspace: `worktree` links it under the repo's primary workspace, which isn't the TL's when the TL runs outside the repo, and `workspace create` makes an unlinked top-level one.

| Operation | Command |
|---|---|
| Open (branch) | `git -C <repo> fetch -q origin` → `git -C <repo> worktree add -b <feat/slug> ../<repo>.worktrees/<slug> origin/dev` → `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd <worktree> --label "<name> · <Model name>" --no-focus` → read the tab id (`.result.tab.tab_id`) and root pane id (`.result.root_pane.pane_id`) from the JSON reply → `herdr agent start <name> --kind claude --pane <root pane> -- --model <model-id> --permission-mode auto` |
| Open (review / research, no branch) | `git -C <repo> worktree add --detach ../<repo>.worktrees/<slug> origin/<branch or dev>`, then the same `herdr tab create …` and `herdr agent start …` |
| Name | the tab `--label` carries the model (herdr doesn't show it) |
| Prompt | copy the brief into `<worktree>/.pm/`, then `herdr agent prompt <name> "Brief: .pm/<slug>-001.md (in this worktree) — read it and carry it out. Report in English when done."`; a revision: `"Revision: read .pm/<slug>-002.md …"` (agents message each other the same way) |
| Read | `herdr agent read <name>` (the screen's tail; the report is the last message) |
| Watch | `bash <skill-dir>/scripts/agent-watch.sh --once` as a background command (timeout up to 2 h): exits when a named agent in the TL's workspace leaves `working` (done, idle, blocked, gone); re-run while agents still work. Agents of other TLs in the same herdr session don't wake it. For one agent right after a prompt, as one background command: first wait until it reports `working` (poll `herdr agent get <name>` for `"agent_status":"working"`, with a timeout), then `herdr agent wait <name> --until done --until blocked --timeout 7200000`. Skip the first step and `herdr agent wait` returns at once, because the agent is still `done` from its last task |
| Close | `herdr tab close <tab id>` after the merge or the report; the checkout is removed by `scripts/cleanup-worktrees.sh` |
| List / resume | `herdr agent list` (each agent's `workspace_id` and `tab_id` show where it runs). After a reboot: if the tab is gone, `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd <worktree> --label …` again, then `herdr agent start <name> --kind claude --pane <id> -- --model <id> --permission-mode auto --continue` |

- `herdr pane list`, `herdr tab list` and `herdr workspace list` give ids. `idle` and `done` both mean ready for input; `blocked` means a permission or question prompt.
- **A new worktree folder** may stop at Claude Code's "trust this folder?" the first time, and `agent start` then fails with `agent_not_ready`. Check with `herdr pane read <pane>`. For the lead's own repo, choose Yes (`herdr pane send-keys <pane> down enter`) and wait until the agent is `idle` before the first prompt.
- `--trust-repository` (on `herdr worktree …`) is herdr's Git trust, not Claude Code's folder trust. Don't pass it routinely; use it only for a repository the lead has verified.
