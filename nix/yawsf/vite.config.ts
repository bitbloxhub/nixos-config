import tailwindcss from "@tailwindcss/vite"
import adapter from "@sveltejs/adapter-node"
import { sveltekit } from "@sveltejs/kit/vite"
import { resolve } from "node:path"
import { defineConfig, normalizePath, type Plugin } from "vite"

function yawsfServicesHmr(): Plugin {
	let entry: string
	let servicesDir: string
	let reload = Promise.resolve()

	return {
		name: "yawsf-services-hmr",
		apply: "serve",

		configResolved(config) {
			entry = normalizePath(resolve(config.root, "src/lib/server/services.ts"))
			servicesDir = normalizePath(resolve(config.root, "src/lib/server/services"))
		},

		handleHotUpdate({ file, server }) {
			file = normalizePath(file)

			if (file !== entry && !file.startsWith(`${servicesDir}/`)) return

			reload = reload.then(async () => {
				const module = server.moduleGraph.getModuleById(entry)

				if (module) server.moduleGraph.invalidateModule(module)

				await server.ssrLoadModule("/src/lib/server/services.ts")
			})

			return reload.then(() => [])
		},
	}
}

export default defineConfig({
	server: {
		host: "127.0.0.1",
		port: 12551,
	},
	plugins: [
		tailwindcss(),
		sveltekit({
			compilerOptions: {
				// Force runes mode for the project, except for libraries. Can be removed in svelte 6.
				runes: ({ filename }) =>
					filename.split(/[/\\]/).includes("node_modules") ? undefined : true,
			},

			adapter: adapter(),
		}),
		yawsfServicesHmr(),
	],
	ssr: {
		noExternal: ["bits-ui"],
	},
})
