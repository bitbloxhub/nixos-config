import type { RequestHandler } from "./$types"
import { webApi } from "$lib/server/web-api"

export const fallback: RequestHandler = ({ request }) => webApi.handle(request)
