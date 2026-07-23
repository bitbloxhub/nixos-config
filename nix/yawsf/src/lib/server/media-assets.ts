import { existsSync, readFileSync, statSync } from "node:fs"
import { extname } from "node:path"
import { fileURLToPath } from "node:url"
import { randomUUID } from "node:crypto"

interface MediaAsset {
	path: string
	mimeType: string
}

const assets = new Map<string, MediaAsset>()
const assetIds = new Map<string, string>()

export function mediaAssetUrl(source: string): string {
	if (!source.startsWith("file:")) return source

	try {
		const path = fileURLToPath(source)
		if (!existsSync(path) || !statSync(path).isFile()) return ""

		const existingId = assetIds.get(path)
		if (existingId) return `/api/media/${existingId}`

		const id = randomUUID()
		assets.set(id, { path, mimeType: mimeType(path) })
		assetIds.set(path, id)
		return `/api/media/${id}`
	} catch {
		return ""
	}
}

export function mediaAsset(id: string): Response {
	const asset = assets.get(id)
	if (!asset) return new Response("Not found", { status: 404 })

	try {
		return new Response(readFileSync(asset.path), {
			headers: {
				"Cache-Control": "public, max-age=31536000, immutable",
				"Content-Type": asset.mimeType,
			},
		})
	} catch {
		assets.delete(id)
		assetIds.delete(asset.path)
		return new Response("Not found", { status: 404 })
	}
}

function mimeType(path: string): string {
	const extension = extname(path).toLowerCase()
	if (extension === ".jpg" || extension === ".jpeg") return "image/jpeg"
	if (extension === ".gif") return "image/gif"
	if (extension === ".webp") return "image/webp"
	if (extension === ".svg") return "image/svg+xml"
	return "image/png"
}
