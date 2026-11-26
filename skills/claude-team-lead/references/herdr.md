# Backend: herdr

The six operations of SKILL.md §2 with [herdr](https://herdr.dev). Each task gets herdr's own **worktree workspace**, linked under the repo's workspace in the sidebar, so the lead sees every agent as an entry under the TL's space. The TL's own tab stays a single pane.

**Run the TL in the repo's workspace** (a herdr workspace whose folder is the repo). herdr links worktree workspaces only under a workspace inside a git work tree. A TL started elsewhere (e.g. the parent folder of several repos) still gets its agents linked under the repo's primary workspace, which herdr creates when it is missing. They then sit under that workspace, not under the TL's.

| Operation | Command |
|---|---|
| Open (branch) | `git fetch -q origin` → `herdr worktree create --cwd <repo> --branch <feat/slug> --base origin/dev --path ../<repo>.worktrees/<slug> --label "<name> · <Model name>" --no-focus` → read the workspace and root pane id from the JSON reply → `herdr agent start <name> --kind claude --pane <root pane> -- --model <model-id> --permission-mode auto` |
| Open (review / research, no branch) | `git worktree add --detach ../<repo>.worktrees/<slug> origin/<branch or dev>` → `herdr worktree open --cwd <repo> --path <it> --label "<name> · <Model name>" --no-focus` → `herdr agent start …` as above |
| Name | the workspace `--label` carries the model (herdr doesn't show it) |
| Prompt | copy the brief into `<worktree>/.pm/`, then `herdr agent prompt <name> "Brief: .pm/<slug>-001.md (in this worktree) — read it and carry it out. Report in English when done."`; a revision: `"Revision: read .pm/<slug>-002.md …"` (agents message each other the same way) |
| Read | `herdr agent read <name>` (the screen's tail; the report is the last message) |
| Watch | `bash <skill-dir>/scripts/agent-watch.sh --once 15 <name>…` as a background command (timeout up to 2 h): exits when one of the named agents leaves `working` (done, idle, blocked, gone); re-run while agents still work. Pass the names so other TLs' agents in the same herdr session don't wake it. For one agent right after a prompt, as one background command: first wait until it reports `working` (poll `herdr agent get <name>` for `"agent_status":"working"`, with a timeout), then `herdr agent wait <name> --until done --until blocked --timeout 7200000`. Skip the first step and `herdr agent wait` returns at once, because the agent is still `done` from its last task |
| Close | `herdr workspace close <id>` in the same turn as the merge or reading the report (the session never exits by itself; check `gh pr view <n> --json state` is `MERGED` and `git -C <worktree> status --porcelain` is empty first); the checkout is removed by `scripts/cleanup-worktrees.sh` |
| List / resume | `herdr agent list`; after a reboot: `herdr worktree open --cwd <repo> --path <worktree>` if the workspace is gone, then `herdr agent start <name> --kind claude --pane <id> -- --model <id> --permission-mode auto --continue` |

- `herdr pane list`, `herdr tab list` and `herdr workspace list` give ids. `idle` and `done` both mean ready for input; `blocked` means a permission or question prompt.
- Never open an agent as a tab or pane in the TL's workspace, or with a bare `herdr workspace create` (an unlinked top-level workspace). The lead expects agents in the sidebar under the TL's space.
- **A new worktree folder** may stop at Claude Code's "trust this folder?" the first time, and `agent start` then fails with `agent_not_ready`. Check with `herdr pane read <pane>`. For the lead's own repo, choose Yes (`herdr pane send-keys <pane> down enter`) and wait until the agent is `idle` before the first prompt.
- `--trust-repository` is herdr's Git trust, not Claude Code's folder trust. Don't pass it routinely; use it only for a repository the lead has verified.
