// SvelteKit 2 does not expose a stable HMR disposal hook for server modules.

import { startMpris, type MprisService } from "./services/mpris"
import { startNiri, type NiriService } from "./services/niri"
import {
	startNotificationWindows,
	type NotificationWindowsService,
} from "./services/notification-windows"
import { startNotifications, type NotificationService } from "./services/notifications"
import { startTopbars } from "./services/topbars"
import { startBentoWindows, type BentoWindowsService } from "./services/bento-windows"
import { startCava, type CavaService } from "./services/cava"

export interface StartInfo {
	protocol: "yawsf-v1"
	host_api: string
	token: string
}

export interface Services {
	mpris: MprisService
	niri: NiriService
	notifications: NotificationService
	notificationWindows: NotificationWindowsService
	bentoWindows: BentoWindowsService
	cava: CavaService
	stop(): Promise<void>
}

interface State {
	startInfo: StartInfo | null
	shellUrl: string | null
	services: Services | null
}

const stateKey = Symbol.for("yawsf.bitbloxhub-shell.services")
const state = ((globalThis as Record<PropertyKey, unknown>)[stateKey] ??= {
	startInfo: null,
	shellUrl: null,
	services: null,
}) as State

if (state.startInfo && state.shellUrl) {
	await state.services?.stop()
	state.services = await startServices(state.startInfo, state.shellUrl)
}

export async function initialize(info: StartInfo, shellUrl: string): Promise<void> {
	await state.services?.stop()
	state.startInfo = info
	state.shellUrl = shellUrl
	state.services = await startServices(info, shellUrl)
}

export function startInfo(): StartInfo | null {
	return state.startInfo
}

export function services(): Services | null {
	return state.services
}

async function startServices(info: StartInfo, shellUrl: string): Promise<Services> {
	const [mpris, niri, notifications] = await Promise.all([
		startMpris(),
		startNiri(),
		startNotifications(),
	])
	const topbars = startTopbars(info, shellUrl, niri)
	const notificationWindows = startNotificationWindows(info, shellUrl, niri, notifications)
	const bentoWindows = startBentoWindows(info, shellUrl, niri)
	const cava = startCava()

	return {
		mpris,
		niri,
		notifications,
		notificationWindows,
		bentoWindows,
		cava,
		async stop() {
			await Promise.all([notificationWindows.stop(), bentoWindows.stop(), topbars.stop()])
			await Promise.all([mpris.stop(), niri.stop(), notifications.stop(), cava.stop()])
		},
	}
}
