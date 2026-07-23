import { z } from "zod"

export const toOpenApiSchema = (schema: z.ZodType) =>
	z.toJSONSchema(schema, { target: "openapi-3.0" }) as never
