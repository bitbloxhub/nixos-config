import type { Handle, ServerInit } from "@sveltejs/kit"
import { services, startInfo } from "$lib/server/services"
import { createYawsfHostClient } from "$lib/server/yawsf-host-client"
import { quit } from "$lib/server/yawsf-host/sdk.gen"

export const init: ServerInit = async () => {
	process.on("sveltekit:shutdown", () => {
		const info = startInfo()
		if (!info) return

		void quit({
			client: createYawsfHostClient(info),
			throwOnError: true,
		}).catch(() => undefined)
	})
}

export const handle: Handle = async ({ event, resolve }) => {
	event.locals.start_info = startInfo()
	event.locals.services = services()

	const response = await resolve(event)
	if (response.headers.get("Content-Type")?.startsWith("text/html")) {
		response.headers.set("Cache-Control", "no-cache")
	}
	return response
}
