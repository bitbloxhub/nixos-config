import { createClient } from "./yawsf-host/client"
import type { StartInfo } from "./services"

export type YawsfHostClient = ReturnType<typeof createClient>

export function createYawsfHostClient(
	info: Pick<StartInfo, "host_api" | "token">,
): YawsfHostClient {
	return createClient({
		auth: info.token,
		baseUrl: info.host_api,
	})
}
