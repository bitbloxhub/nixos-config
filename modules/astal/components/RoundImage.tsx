import { Gtk, Gdk } from "ags/gtk4"
import { Accessor, FCProps } from "ags"
import GdkPixbuf from "gi://GdkPixbuf"

// taken from https://github.com/unfaiyted/faiyt-ags/blob/c99ee69/src/widget/utils/rounded-image.tsx
type RoundImageProps = FCProps<
	Gtk.Image,
	{
		file: Accessor<string>
		className?: string
		size?: number | { width: number; height: number }
		radius?: number
	}
>

export default function RoundImage({
	file,
	className = "",
	size = 48,
	radius = 8,
}: RoundImageProps) {
	const width = typeof size === "number" ? size : size.width
	const height = typeof size === "number" ? size : size.height

	return (
		<drawingarea
			class={className}
			widthRequest={width}
			heightRequest={height}
			vexpand={false}
			hexpand={false}
			$={(self) => {
				self.set_draw_func((widget, cr) => {
					const currentFile = file.peek()

					const allocation = widget.get_allocation()
					const w = allocation.width
					const h = allocation.height

					let pixbuf: GdkPixbuf.Pixbuf | null = null
					let error: Error | null = null

					// Load the image if file path is provided
					if (currentFile) {
						try {
							// First load the image to get its dimensions
							const originalPixbuf =
								GdkPixbuf.Pixbuf.new_from_file(currentFile)

							if (originalPixbuf) {
								const origWidth = originalPixbuf.get_width()
								const origHeight = originalPixbuf.get_height()

								// Calculate scale to fill (not fit)
								const scaleX = w / origWidth
								const scaleY = h / origHeight
								const scale = Math.max(scaleX, scaleY)

								// Load at the size that will fill the container
								const scaledWidth = Math.round(
									origWidth * scale,
								)
								const scaledHeight = Math.round(
									origHeight * scale,
								)

								pixbuf =
									GdkPixbuf.Pixbuf.new_from_file_at_scale(
										currentFile,
										scaledWidth,
										scaledHeight,
										false, // don't preserve aspect ratio
									)
							}
						} catch (e) {
							error = e as Error
							console.error(
								`Failed to load image: ${currentFile}`,
								e,
							)
						}
					}

					// Create rounded rectangle path
					const degrees = Math.PI / 180.0

					cr.newSubPath()
					cr.arc(
						w - radius,
						radius,
						radius,
						-90 * degrees,
						0 * degrees,
					)
					cr.arc(
						w - radius,
						h - radius,
						radius,
						0 * degrees,
						90 * degrees,
					)
					cr.arc(
						radius,
						h - radius,
						radius,
						90 * degrees,
						180 * degrees,
					)
					cr.arc(radius, radius, radius, 180 * degrees, 270 * degrees)
					cr.closePath()

					// Clip to the rounded rectangle
					cr.clip()

					// Draw the image if loaded successfully
					if (pixbuf) {
						// Center the image if it's larger than the container
						const pixbufWidth = pixbuf.get_width()
						const pixbufHeight = pixbuf.get_height()
						const offsetX = (w - pixbufWidth) / 2
						const offsetY = (h - pixbufHeight) / 2

						Gdk.cairo_set_source_pixbuf(
							cr,
							pixbuf,
							offsetX,
							offsetY,
						)
						cr.paint()
					} else if (!currentFile) {
						// Draw loading state
						cr.setSourceRGBA(0.3, 0.3, 0.3, 0.5)
						cr.paint()

						// Draw loading icon
						cr.setSourceRGBA(1, 1, 1, 0.6)
						cr.selectFontFace("monospace", 0, 0)
						cr.setFontSize(Math.min(w, h) * 0.3)
						cr.moveTo(w * 0.5 - 10, h * 0.5 + 5)
						cr.showText("⏳")
					} else {
						// Draw placeholder or error state
						cr.setSourceRGBA(0.2, 0.2, 0.2, 0.8)
						cr.paint()

						// Draw error icon or text
						if (error) {
							cr.setSourceRGBA(1, 1, 1, 0.8)
							cr.selectFontFace("monospace", 0, 0)
							cr.setFontSize(Math.min(w, h) * 0.3)
							cr.moveTo(w * 0.5 - 10, h * 0.5 + 5)
							cr.showText("?")
						}
					}

					return true
				})
				file.subscribe(() => self.queue_draw())
			}}
		/>
	)
}
