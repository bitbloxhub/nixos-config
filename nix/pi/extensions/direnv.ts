import { execFile } from "node:child_process"
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"

type DirenvExport = Record<string, string | null>

type EnvSnapshot = Record<string, string | undefined>

type DiffEntry = {
	key: string
	before: string | undefined
	after: string | undefined
}

function run(command: string, args: string[], cwd: string): Promise<string> {
	return new Promise((resolve, reject) => {
		execFile(
			command,
			args,
			{ cwd, env: process.env },
			(error, stdout, stderr) => {
				if (error) {
					reject(new Error(stderr.trim() || error.message))
					return
				}
				resolve(stdout)
			},
		)
	})
}

function snapshotEnv(): EnvSnapshot {
	return { ...process.env }
}

function diffEnv(before: EnvSnapshot, after: EnvSnapshot): DiffEntry[] {
	const keys = new Set([...Object.keys(before), ...Object.keys(after)])
	const diff: DiffEntry[] = []

	for (const key of keys) {
		const previous = before[key]
		const next = after[key]
		if (previous !== next) {
			diff.push({ key, before: previous, after: next })
		}
	}

	return diff.sort((a, b) => a.key.localeCompare(b.key))
}

function formatInlineDiff(diff: DiffEntry[]): string {
	if (diff.length === 0) {
		return ""
	}

	const parts: string[] = []

	for (const entry of diff) {
		if (entry.before === undefined) {
			parts.push(`+${entry.key}`)
			continue
		}
		if (entry.after === undefined) {
			parts.push(`-${entry.key}`)
			continue
		}
		parts.push(`~${entry.key}`)
	}

	return parts.join(" ")
}

function applyDirenvExport(raw: string) {
	const changes = JSON.parse(raw) as DirenvExport

	for (const [key, value] of Object.entries(changes)) {
		if (value === null) {
			delete process.env[key]
			continue
		}

		process.env[key] = value
	}
}

async function exportDirenv(cwd: string) {
	const before = snapshotEnv()

	const output = await run(
		"direnv",
		["exec", "/", "direnv", "export", "json"],
		cwd,
	)
	applyDirenvExport(output)

	const after = snapshotEnv()
	const diff = diffEnv(before, after)
	const details = formatInlineDiff(diff)
	return { method: "exec/export-json" as const, details }
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (event, ctx) => {
		if (event.reason !== "resume") {
			return
		}

		try {
			const result = await exportDirenv(ctx.cwd)
			const text = result.details
				? `direnv: ${result.method} ${result.details}`
				: `direnv: ${result.method} (no changes)`
			ctx.ui.notify(text, "info")
		} catch (error) {
			const message =
				error instanceof Error ? error.message : String(error)
			ctx.ui.notify(message, "error")
		}
	})

	pi.registerCommand("direnv-export", {
		description:
			"Export direnv for current cwd and show full one-line env diff",
		handler: async (_args, ctx) => {
			try {
				const result = await exportDirenv(ctx.cwd)
				const text = result.details
					? `direnv: ${result.method} ${result.details}`
					: `direnv: ${result.method} (no changes)`
				ctx.ui.notify(text, "success")
			} catch (error) {
				const message =
					error instanceof Error ? error.message : String(error)
				ctx.ui.notify(message, "error")
			}
		},
	})
}
