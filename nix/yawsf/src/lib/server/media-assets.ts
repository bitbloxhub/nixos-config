import { execFile } from "node:child_process"
import { existsSync, readFileSync, statSync } from "node:fs"
import { extname } from "node:path"
import { fileURLToPath } from "node:url"
import { promisify } from "node:util"
import { randomUUID } from "node:crypto"

interface MediaAsset {
	path: string
	mimeType: string
}

const assets = new Map<string, MediaAsset>()
const assetIds = new Map<string, string>()
const iconLookupCache = new Map<string, Promise<string>>()
export function mediaAssetUrl(source: string): string {
	if (!source || source.includes("/") || source.includes(":")) {
		if (!source.startsWith("file:")) return source

		try {
			const path = fileURLToPath(source)
			return registerAsset(path) ?? ""
		} catch {
			return ""
		}
	}

	return source
}

export function resolveMediaAssetUrl(source: string): Promise<string> {
	const immediateUrl = mediaAssetUrl(source)
	if (immediateUrl !== source || !/^[A-Za-z0-9._-]+$/.test(source)) {
		return Promise.resolve(immediateUrl)
	}

	const cached = iconLookupCache.get(source)
	if (cached) return cached

	const lookup = lookupThemeIcon(source)
	iconLookupCache.set(source, lookup)
	return lookup
}

const execFileAsync = promisify(execFile)
async function lookupThemeIcon(source: string): Promise<string> {
	try {
		const { stdout } = await execFileAsync("yawsf-icon-lookup", [source], {
			encoding: "utf8",
			maxBuffer: 1024 * 1024,
		})
		return registerAsset(stdout.trim()) ?? source
	} catch {
		return source
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

function registerAsset(path: string): string | null {
	try {
		if (!existsSync(path) || !statSync(path).isFile()) return null

		const existingId = assetIds.get(path)
		if (existingId) return `/api/media/${existingId}`

		const id = randomUUID()
		assets.set(id, { path, mimeType: mimeType(path) })
		assetIds.set(path, id)
		return `/api/media/${id}`
	} catch {
		return null
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
