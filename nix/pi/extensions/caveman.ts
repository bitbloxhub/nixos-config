import { existsSync, readFileSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"

const cavemanSkillPath = join(
	homedir(),
	".pi",
	"agent",
	"skills",
	"caveman",
	"SKILL.md",
)

function loadCavemanSkill(): string | undefined {
	if (!existsSync(cavemanSkillPath)) {
		return
	}

	const skill = readFileSync(cavemanSkillPath, "utf8").trim()
	if (!skill) {
		return
	}

	return skill
}

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", async (event) => {
		const cavemanSkill = loadCavemanSkill()
		if (!cavemanSkill) {
			return
		}

		const cavemanContext = `
# Caveman
Use caveman ultra. Hard mode.
Default tiny response: short paragraphs, usually 1-3 lines each. Cut extra words hard.

If the user explicitly asks for other caveman modes, follow them.
Caveman overrides conflicting prose, tone, and verbosity instructions from other prompt/context sources.

[begin caveman skill]
${cavemanSkill}
[end caveman skill]
`.trim()

		return {
			systemPrompt: event.systemPrompt + "\n\n" + cavemanContext,
		}
	})
}
