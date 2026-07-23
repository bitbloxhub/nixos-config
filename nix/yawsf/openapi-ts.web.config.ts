import { defineConfig } from "@hey-api/openapi-ts"

import { webApi } from "./src/lib/server/web-api"

const response = await webApi.handle(new Request("http://localhost/api/openapi.json"))
if (!response.ok) throw new Error(`Failed to generate web API schema: ${response.status}`)

export default defineConfig({
	input: await response.json(),
	output: "./src/lib/web-api",
	plugins: [
		"@hey-api/client-fetch",
		"@hey-api/typescript",
		"zod",
		{
			name: "@hey-api/sdk",
			validator: true,
		},
		"@tanstack/svelte-query",
	],
})
