import { existsSync, readFileSync } from "node:fs"
import { dirname, join, resolve } from "node:path"
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"

function findEditorconfig(startDir: string): string | undefined {
	let currentDir = resolve(startDir)

	while (true) {
		const editorconfigPath = join(currentDir, ".editorconfig")
		if (existsSync(editorconfigPath)) {
			return editorconfigPath
		}

		const parentDir = dirname(currentDir)
		if (parentDir === currentDir) {
			return
		}

		currentDir = parentDir
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", async (event, ctx) => {
		const editorconfigPath = findEditorconfig(ctx.cwd)
		if (!editorconfigPath) {
			return
		}

		const editorconfig = readFileSync(editorconfigPath, "utf8").trim()
		if (!editorconfig) {
			return
		}

		const editorconfigContext = `
## Project EditorConfig
A project \`.editorconfig\` file was found at \`${editorconfigPath}\`.

Follow it for formatting and indentation in this project. If it conflicts with the general tab preference, \`.editorconfig\` wins.

[begin .editorconfig]
${editorconfig}
[end .editorconfig]
`.trim()

		return {
			systemPrompt: event.systemPrompt + "\n\n" + editorconfigContext,
		}
	})
}
