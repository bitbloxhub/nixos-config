export function eventStream<T>(
	request: Request,
	event: string,
	subscribe: (emit: (value: T) => void) => () => void,
): Response {
	const encoder = new TextEncoder()

	const timers = new Set<ReturnType<typeof setTimeout>>()
	let unsubscribe: () => void = () => {}
	const cleanup = () => {
		request.signal.removeEventListener("abort", cleanup)
		unsubscribe()
		for (const timer of timers) clearTimeout(timer)
		timers.clear()
	}
	const stream = new ReadableStream<Uint8Array>({
		start(controller) {
			unsubscribe = subscribe((value) => {
				const payload = `event: ${event}\ndata: ${JSON.stringify(value)}\n\n`
				controller.enqueue(encoder.encode(payload))
				const timer = setTimeout(() => {
					timers.delete(timer)
					try {
						controller.enqueue(encoder.encode(":\n\n"))
					} catch {
						// Stream closed before the follow-up write.
					}
				}, 10)
				timers.add(timer)
			})
			request.signal.addEventListener("abort", cleanup, { once: true })
		},
		cancel() {
			cleanup()
		},
	})

	return new Response(stream, {
		headers: { "Cache-Control": "no-cache", "Content-Type": "text/event-stream" },
	})
}
