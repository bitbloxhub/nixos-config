import { unlinkSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process"

export type CavaFrame = number[]
type CavaListener = (frame: CavaFrame) => void

export interface CavaService {
	subscribe(listener: CavaListener): () => void
	stop(): Promise<void>
}

const config = `[general]
framerate = 30
bars = 48

[input]
method = pipewire
source = auto

[output]
method = raw
channels = stereo
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
frame_delimiter = 10
`

export function startCava(): CavaService {
	const listeners = new Set<CavaListener>()
	let child: ChildProcessWithoutNullStreams | null = null
	let buffer = ""

	const configPath = join(tmpdir(), `yawsf-cava-${process.pid}.conf`)
	try {
		writeFileSync(configPath, config)
		child = spawn("cava", ["-p", configPath])
		child.stdout.setEncoding("utf8")
		child.stdout.on("data", (chunk: string) => {
			buffer += chunk
			const frames = buffer.split("\n")
			buffer = frames.pop() ?? ""
			for (const frame of frames) {
				const values = frame.split(";").filter(Boolean).map(Number).filter(Number.isFinite)
				if (values.length === 0) continue
				for (const listener of listeners) listener(values)
			}
		})
		child.stderr.on("data", (chunk: Buffer) => console.warn(`cava: ${chunk.toString().trim()}`))
		child.on("error", (error) => console.warn("Cava unavailable", error))
		child.on("exit", () => unlinkSync(configPath))
	} catch (error) {
		console.warn("Cava unavailable", error)
	}

	return {
		subscribe(listener) {
			listeners.add(listener)
			return () => listeners.delete(listener)
		},
		async stop() {
			listeners.clear()
			if (!child || child.exitCode !== null) return
			child.kill()
			await new Promise<void>((resolve) => child?.once("exit", () => resolve()))
		},
	}
}
