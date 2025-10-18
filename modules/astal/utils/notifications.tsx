import { readFile, writeFile } from "ags/file"
import GObject, { property, register, signal } from "ags/gobject"
import GLib from "gi://GLib"
import AstalNotifd from "gi://AstalNotifd"

@register({ GTypeName: "Notifications" })
export default class NotificationsGObject extends GObject.Object {
	@property(AstalNotifd.Notifd)
	notifd: AstalNotifd.Notifd

	@property(Array<AstalNotifd.Notification>)
	notifications: Array<AstalNotifd.Notification>

	@signal([AstalNotifd.Notification], GObject.TYPE_NONE, { default: false })
	notified(this: object, _: AstalNotifd.Notification): undefined {
		throw "never runs!"
	}

	@signal([Number], GObject.TYPE_NONE, { default: false })
	resolved(this: object, _: number): undefined {
		throw "never runs!"
	}

	constructor() {
		super()
		const notifd = AstalNotifd.get_default()
		this.notifd = notifd
		this.notifications = notifd.notifications

		notifd.connect("notified", (_, id) => {
			this.notifications = notifd.notifications.sort(
				(n1, n2) => n1.id - n2.id,
			)
			this.notified(notifd.notifications.find((n) => n.id == id)!)
		})

		notifd.connect("resolved", (_, id) => {
			this.resolved(id)
			setTimeout(() => {
				this.notifications = notifd.notifications.sort(
					(n1, n2) => n1.id - n2.id,
				)
			}, 300)
		})
	}
}
