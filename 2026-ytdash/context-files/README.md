# Context files used in the 2026 round

The instruction file each agent was given alongside the spec, one per stack. Same content across agents, only the file name changes to what each tool reads:

| Stack | Claude Code | Gemini CLI | Codex |
|---|---|---|---|
| Android | [CLAUDE_android.md](CLAUDE_android.md) | [GEMINI_android.md](GEMINI_android.md) | [Agents_android.md](Agents_android.md) |
| Flutter | [CLAUDE_flutter.md](CLAUDE_flutter.md) | [GEMINI_flutter.md](GEMINI_flutter.md) | [Agents_flutter.md](Agents_flutter.md) |
| React Native | [CLAUDE_rn.md](CLAUDE_rn.md) | [GEMINI_rn.md](GEMINI_rn.md) | [Agents_rn.md](Agents_rn.md) |

They were placed at the project root as `CLAUDE.md`, `GEMINI.md`, or `AGENTS.md` before the first prompt.
