import { defineConfig } from "@hey-api/openapi-ts"

const input = process.env.YAWSF_HOST_OPENAPI_SPEC
if (!input) {
	throw new Error("YAWSF_HOST_OPENAPI_SPEC must point to the locked YAWSF host OpenAPI spec")
}

export default defineConfig({
	input,
	output: "./src/lib/server/yawsf-host",
	plugins: ["@hey-api/client-fetch", "@hey-api/typescript", "@hey-api/sdk"],
})
