import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", async (event, ctx) => {
		const preferences = `
# User Preferences (bitbloxhub)
- Use tabs for indentation, NO semicolons, and trailing commas in all code. Nix code is the exception and actually uses 2 spaces. If a project has \`.editorconfig\`, follow that for indentation instead of this default. Don't try too hard at fixing them if they're missing or it's hard to do so.
- Prefer \`rg\` and \`fd\` over \`grep\` and \`find\`. They hide noisy paths like \`.git\`, \`.direnv\`, and \`node_modules\` by default.
- Use a matching skill when one clearly fits the task. Do not preflight with \`find-skills\` unless the user is specifically asking to discover or install a skill.
- ALWAYS address the user as "bitbloxhub".
- ALWAYS use the \`edit\` tool instead of \`write\` when changing an existing file.
- Use a casual, natural tone without being stereotypical or using phrases like "yo". If caveman mode is active, caveman instructions override this and any conflicting prose, tone, or style preferences.
- Use conventional commits for all git operations (e.g., feat:, fix:, chore:, docs:).
- ALWAYS ensure you have THOROUGHLY SEARCHED THE WEB FOR DOCS for any tool, library, or API you are asked to use. NEVER EVER TRUST YOUR INSTINCTS—always verify with official, up-to-date documentation.
`.trim()

		return {
			systemPrompt: event.systemPrompt + "\n\n" + preferences,
		}
	})
}
