import type { RequestHandler } from "./$types"
import { initialize } from "$lib/server/services"

export const POST: RequestHandler = async ({ request, url }) => {
	const init = await request.json()
	await initialize(init, url.origin)

	return new Response(null, { status: 204 })
}
