import { execFile } from "node:child_process"
import { randomInt } from "node:crypto"
import { Fragment, useEffect, useState } from "react"
import {
	Action,
	ActionPanel,
	closeMainWindow,
	Form,
	Icon,
	List,
	useNavigation,
	Toast,
	confirmAlert,
	showToast,
} from "@vicinae/api"
import type {
	Form as FormTypes,
	KeyEquivalent,
	KeyModifier,
} from "@vicinae/api"

const gopass = "gopass"

const maxPasswordLength = 128

type PasswordOptions = {
	length: number
	uppercase: boolean
	lowercase: boolean
	digits: boolean
	symbols: boolean
	extendedAscii: boolean
	customInclude: string
	exclude: string
	excludeLookalikes: boolean
	pickEveryGroup: boolean
	hex: boolean
}

const passwordCharacterSets = {
	uppercase: "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	lowercase: "abcdefghijklmnopqrstuvwxyz",
	digits: "0123456789",
	symbols: "!@#$%^&*()-_=+[]{};:,.?/",
}

function generatePassword(options: PasswordOptions): string {
	const selectedSets = [
		options.uppercase ? passwordCharacterSets.uppercase : "",
		options.lowercase ? passwordCharacterSets.lowercase : "",
		options.digits ? passwordCharacterSets.digits : "",
		options.symbols ? passwordCharacterSets.symbols : "",
		options.extendedAscii
			? Array.from({ length: 95 }, (_, index) =>
					String.fromCharCode(161 + index),
				).join("")
			: "",
	].filter(Boolean)
	const excluded = new Set([
		...options.exclude,
		...(options.excludeLookalikes ? "Il1O0o" : ""),
	])
	const passwordCharacters = [
		...new Set([
			...selectedSets.join(""),
			...(options.hex ? "0123456789abcdef" : options.customInclude),
		]),
	]
		.filter((character) => !excluded.has(character))
		.join("")
	if (!selectedSets.length)
		throw new Error("Select at least one character type")
	if (!passwordCharacters.length)
		throw new Error("No characters remain after exclusions")
	if (options.length < 1) throw new Error("Length must be positive")

	const characters: string[] = []
	if (options.pickEveryGroup) {
		for (const group of selectedSets) {
			const available = [...group].filter(
				(character) => !excluded.has(character),
			)
			if (available.length) {
				characters.push(available[randomInt(available.length)]!)
			}
		}
	}

	while (characters.length < options.length) {
		characters.push(
			passwordCharacters[randomInt(passwordCharacters.length)]!,
		)
	}

	for (let index = characters.length - 1; index > 0; index -= 1) {
		const swapIndex = randomInt(index + 1)
		;[characters[index], characters[swapIndex]] = [
			characters[swapIndex]!,
			characters[index]!,
		]
	}
	return characters.join("")
}

function passwordEntropy(options: PasswordOptions): number {
	const characters = [
		options.uppercase ? passwordCharacterSets.uppercase : "",
		options.lowercase ? passwordCharacterSets.lowercase : "",
		options.digits ? passwordCharacterSets.digits : "",
		options.symbols ? passwordCharacterSets.symbols : "",
		options.extendedAscii
			? Array.from({ length: 95 }, (_, index) =>
					String.fromCharCode(161 + index),
				).join("")
			: "",
		options.hex ? "0123456789abcdef" : options.customInclude,
	].join("")
	const excluded = new Set([
		...options.exclude,
		...(options.excludeLookalikes ? "Il1O0o" : ""),
	])
	const poolSize = [...new Set(characters)].filter(
		(character) => !excluded.has(character),
	).length
	return poolSize ? options.length * Math.log2(poolSize) : 0
}

function PasswordGenerator({
	onGenerated,
}: {
	onGenerated: (password: string) => void
}) {
	const { pop } = useNavigation()
	const [options, setOptions] = useState<PasswordOptions>({
		length: 20,
		uppercase: true,
		lowercase: true,
		digits: true,
		symbols: true,
		extendedAscii: false,
		customInclude: "",
		exclude: "",
		excludeLookalikes: true,
		pickEveryGroup: false,
		hex: false,
	})
	const [generated, setGenerated] = useState(() => generatePassword(options))
	const [showGenerated, setShowGenerated] = useState(true)
	useEffect(() => {
		try {
			setGenerated(generatePassword(options))
		} catch {
			// Keep current password while options are temporarily invalid.
		}
	}, [
		options.length,
		options.uppercase,
		options.lowercase,
		options.digits,
		options.symbols,
		options.extendedAscii,
		options.customInclude,
		options.exclude,
		options.excludeLookalikes,
		options.pickEveryGroup,
		options.hex,
	])
	const entropy = passwordEntropy(options)
	const quality =
		entropy >= 100 ? "Excellent" : entropy >= 70 ? "Strong" : "Weak"

	function regenerate() {
		try {
			setGenerated(generatePassword(options))
		} catch (error) {
			void showToast({
				style: Toast.Style.Failure,
				title: "Cannot generate password",
				message: errorMessage(error),
			})
		}
	}

	return (
		<Form
			navigationTitle="Generate password"
			actions={
				<ActionPanel>
					<Action
						title="Use password"
						icon={Icon.Checkmark}
						shortcut={{ key: "enter", modifiers: ["ctrl"] }}
						onAction={() => {
							onGenerated(generated)
							pop()
						}}
					/>
					<Action
						title={
							showGenerated ? "Hide password" : "Show password"
						}
						icon={showGenerated ? Icon.EyeDisabled : Icon.Eye}
						shortcut={{ key: "h", modifiers: ["ctrl"] }}
						onAction={() => setShowGenerated((shown) => !shown)}
					/>
					<Action
						title="Regenerate password"
						icon={Icon.ArrowClockwise}
						shortcut={{ key: "r", modifiers: ["ctrl"] }}
						onAction={regenerate}
					/>
				</ActionPanel>
			}
		>
			{showGenerated ? (
				<Form.TextField
					id="generated"
					title="Password"
					value={generated}
					onChange={setGenerated}
				/>
			) : (
				<Form.PasswordField
					id="generated"
					title="Password"
					value={generated}
					onChange={setGenerated}
				/>
			)}
			<Form.Description
				title="Password quality"
				text={`${quality} · ${options.length} characters · ${entropy.toFixed(2)} bits entropy`}
			/>
			<Form.TextField
				id="length"
				title="Length"
				value={String(options.length)}
				onChange={(value) => {
					const length = Number.parseInt(value, 10)
					if (Number.isInteger(length)) {
						setOptions((current) => ({
							...current,
							length: Math.min(
								Math.max(length, 1),
								maxPasswordLength,
							),
						}))
					}
				}}
			/>
			<Form.Separator />
			<Form.Description
				title="Character types"
				text="Select allowed characters"
			/>
			<Form.Checkbox
				id="uppercase"
				title="A-Z"
				label="Uppercase letters"
				value={options.uppercase}
				onChange={(uppercase) =>
					setOptions((current) => ({ ...current, uppercase }))
				}
			/>
			<Form.Checkbox
				id="lowercase"
				title="a-z"
				label="Lowercase letters"
				value={options.lowercase}
				onChange={(lowercase) =>
					setOptions((current) => ({ ...current, lowercase }))
				}
			/>
			<Form.Checkbox
				id="digits"
				title="0-9"
				label="Numbers"
				value={options.digits}
				onChange={(digits) =>
					setOptions((current) => ({ ...current, digits }))
				}
			/>
			<Form.Checkbox
				id="symbols"
				title="/ * + & ..."
				label="Symbols"
				value={options.symbols}
				onChange={(symbols) =>
					setOptions((current) => ({ ...current, symbols }))
				}
			/>
			<Form.Checkbox
				id="extended-ascii"
				title="Extended ASCII"
				label="Extended ASCII characters"
				value={options.extendedAscii}
				onChange={(extendedAscii) =>
					setOptions((current) => ({ ...current, extendedAscii }))
				}
			/>
			<Form.TextField
				id="custom-include"
				title="Also choose from"
				value={options.customInclude}
				onChange={(customInclude) =>
					setOptions((current) => ({ ...current, customInclude }))
				}
			/>
			<Form.TextField
				id="exclude"
				title="Do not include"
				value={options.exclude}
				onChange={(exclude) =>
					setOptions((current) => ({ ...current, exclude }))
				}
			/>
			<Form.Checkbox
				id="hex"
				title="Hex"
				label="Hexadecimal"
				value={options.hex}
				onChange={(hex) =>
					setOptions((current) => ({ ...current, hex }))
				}
			/>
			<Form.Checkbox
				id="exclude-lookalikes"
				title="Look-alikes"
				label="Exclude I, l, 1, O, 0, o"
				value={options.excludeLookalikes}
				onChange={(excludeLookalikes) =>
					setOptions((current) => ({ ...current, excludeLookalikes }))
				}
			/>
			<Form.Checkbox
				id="pick-every-group"
				title="Every group"
				label="Pick from each selected group"
				value={options.pickEveryGroup}
				onChange={(pickEveryGroup) =>
					setOptions((current) => ({ ...current, pickEveryGroup }))
				}
			/>
		</Form>
	)
}

type Entry = {
	path: string
	content?: string
}

type SecretField = {
	key: string
	value: string
	line: number
	copyByKey?: boolean
}

type SecretFields = {
	password: string
	fields: SecretField[]
}

const sensitiveKeys = new Set(["hotp", "otpauth", "password", "totp"])

function hiddenKeys(fields: SecretField[]): string[] {
	return (
		fields
			.find((field) => field.key.toLowerCase() === "unsafe-keys")
			?.value.split(",")
			.map((key) => key.trim().toLowerCase())
			.filter(Boolean) ?? []
	)
}

function isSensitiveKey(key: string, extraKeys: string[] = []): boolean {
	const normalized = key.toLowerCase()
	return sensitiveKeys.has(normalized) || extraKeys.includes(normalized)
}

function copyShortcut(key: string) {
	const shortcuts: Record<string, KeyEquivalent> = {
		password: "c",
		username: "b",
		url: "u",
		totp: "t",
		otpauth: "t",
	}
	const shortcutKey = shortcuts[key.toLowerCase()]
	return shortcutKey
		? { key: shortcutKey, modifiers: ["ctrl"] as KeyModifier[] }
		: undefined
}

function parseEntries(stdout: string): Entry[] {
	const trimmed = stdout.trim()
	if (!trimmed) return []

	try {
		const parsed: unknown = JSON.parse(trimmed)
		if (Array.isArray(parsed)) {
			return parsed.flatMap((entry) => {
				if (typeof entry === "string") return [{ path: entry }]
				if (entry && typeof entry === "object" && "path" in entry) {
					const path = entry.path
					return typeof path === "string" ? [{ path }] : []
				}
				return []
			})
		}
	} catch {
		// Older gopass versions can return a plain, newline-delimited list.
	}

	return trimmed.split("\n").map((path) => ({ path }))
}

function parseSecret(content: string): SecretFields {
	const lines = content.split("\n")
	const password = lines[0] ?? ""

	const base64Header = lines.findIndex((line) =>
		line.includes("Content-Transfer-Encoding Base64"),
	)
	if (base64Header >= 0) {
		const encoded = lines
			.slice(base64Header + 1)
			.join("")
			.trim()
		const decoded = Buffer.from(encoded, "base64").toString("utf8")
		return parseSecret(`${password}\n${decoded}`)
	}
	const fields: SecretField[] = []

	for (let index = 1; index < lines.length; index += 1) {
		const line = lines[index]
		if (!line?.trim()) continue

		const pair = line.match(/^([^:]+):\s+(.*)$/)
		const emptyPair = line.match(/^([^:]+):$/)
		let key = pair?.[1]?.trim() ?? emptyPair?.[1]?.trim() ?? ""
		let value = pair?.[2]?.trim() ?? ""
		if (!pair && !emptyPair) value = line

		if (line.startsWith("otpauth://")) {
			key = "otpauth"
			value = line
		}
		let valueLine = index
		const isField = (candidate: string) =>
			/^[^:]+:\s+/.test(candidate) || /^[^:]+:$/.test(candidate)

		if (!value && key) {
			const continuation: string[] = []
			let nextIndex = index + 1
			while (nextIndex < lines.length) {
				const next = lines[nextIndex]
				if (!next?.trim() || (key !== "notes" && isField(next))) break
				continuation.push(next.trim())
				nextIndex += 1
			}
			if (continuation.length) {
				value = continuation.join("\n")
				valueLine = index + 1
				index = nextIndex - 1
			}
		}

		const previous = fields.at(-1)
		if (pair && previous?.key === key && previous.copyByKey) {
			previous.value += `\n${value}`
		} else {
			fields.push({
				key,
				value,
				line: valueLine,
				copyByKey: Boolean(pair),
			})
		}
	}

	return { password, fields }
}

async function runGopass(args: string[], input?: string): Promise<string> {
	return new Promise((resolve, reject) => {
		const child = execFile(
			gopass,
			args,
			{ encoding: "utf8", maxBuffer: 1024 * 1024 },
			(error, stdout, stderr) => {
				if (error) {
					Object.assign(error, { stderr })
					reject(error)
					return
				}
				resolve(stdout)
			},
		)
		child.stdin?.end(input)
	})
}

async function readGopassSafetyConfig(): Promise<{
	safeContent: boolean
	hiddenKeys: string[]
}> {
	try {
		const [safeContent, configuredHiddenKeys] = await Promise.all([
			runGopass(["config", "show.safecontent"]),
			runGopass(["config", "show.hidden-keys"]),
		])
		return {
			safeContent: safeContent.trim().toLowerCase() === "true",
			hiddenKeys: configuredHiddenKeys
				.split(/[\n,]/)
				.map((key) => key.trim().toLowerCase())
				.filter(Boolean),
		}
	} catch {
		return { safeContent: false, hiddenKeys: [] }
	}
}

function errorMessage(error: unknown): string {
	if (error && typeof error === "object" && "stderr" in error) {
		const stderr = error.stderr
		if (typeof stderr === "string" && stderr.trim()) return stderr.trim()
	}
	return error instanceof Error ? error.message : String(error)
}

async function copyWithGopass(args: string[], title: string): Promise<void> {
	try {
		await runGopass(args)
		await showToast({
			style: Toast.Style.Success,
			title,
		})
		await closeMainWindow()
	} catch (error) {
		await showToast({
			style: Toast.Style.Failure,
			title: "gopass failed",
			message: errorMessage(error),
		})
	}
}

async function listEntries(): Promise<Entry[]> {
	return parseEntries(await runGopass(["ls", "--flat", "--json", "--nosync"]))
}

async function saveEntry(path: string, content: string): Promise<void> {
	await runGopass(["insert", "--force", "--yes", "--nosync", path], content)
}

function EntryForm({ entry, onSaved }: { entry?: Entry; onSaved: () => void }) {
	const [isLoading, setIsLoading] = useState(false)
	const [passwordValue, setPasswordValue] = useState(() =>
		entry ? parseSecret(entry.content ?? "").password : "",
	)
	const { pop } = useNavigation()
	const initial = entry ? parseSecret(entry.content ?? "") : undefined
	const initialHiddenKeys = hiddenKeys(initial?.fields ?? [])
	const [fields, setFields] = useState<SecretField[]>(
		() => initial?.fields ?? [],
	)
	const isEditing = entry !== undefined

	async function submit(values: FormTypes.Values) {
		const path = String(values.path ?? entry?.path ?? "").trim()
		const password = String(values.password ?? "")
		const content = serializeSecret(
			password,
			fields.map(({ key }, index) => ({
				key: String(values[`key-${index}`] ?? key).trim(),
				value: String(values[`value-${index}`] ?? ""),
				line: index + 1,
			})),
		)
		if (!path || !password) {
			await showToast({
				style: Toast.Style.Failure,
				title: "Path and password are required",
			})
			return
		}

		setIsLoading(true)
		try {
			await saveEntry(path, content)
			await showToast({
				style: Toast.Style.Success,
				title: isEditing ? "Entry updated" : "Entry created",
			})
			onSaved()
			pop()
		} catch (error) {
			await showToast({
				style: Toast.Style.Failure,
				title: "gopass failed",
				message: errorMessage(error),
			})
		} finally {
			setIsLoading(false)
		}
	}
	async function removeField(index: number) {
		const field = fields[index]
		if (!field) return

		if (
			!(await confirmAlert({
				title: `Delete ${field.key || "value"}?`,
				message: "This removes field when you save the entry.",
			}))
		)
			return

		setFields((current) =>
			current.filter((_, fieldIndex) => fieldIndex !== index),
		)
	}

	return (
		<Form
			isLoading={isLoading}
			navigationTitle={
				isEditing ? `Edit ${entry?.path}` : "Create gopass entry"
			}
			actions={
				<ActionPanel>
					<Action.SubmitForm
						title={isEditing ? "Save entry" : "Create entry"}
						onSubmit={submit}
					/>
					<Action.Push
						title="Generate password"
						icon={Icon.Key}
						shortcut={{ key: "g", modifiers: ["ctrl"] }}
						target={
							<PasswordGenerator onGenerated={setPasswordValue} />
						}
					/>
					<Action
						title="Add field"
						icon={Icon.Plus}
						onAction={() =>
							setFields((current) => [
								...current,
								{
									key: "",
									value: "",
									line: current.length + 1,
								},
							])
						}
					/>
					{fields.map((field, index) => (
						<Action
							key={`${field.line}-${index}`}
							title={`Delete ${field.key || `field ${index + 1}`}`}
							icon={Icon.Trash}
							style="destructive"
							onAction={() => void removeField(index)}
						/>
					))}
				</ActionPanel>
			}
		>
			<Form.TextField
				id="path"
				title="Path"
				defaultValue={entry?.path}
				placeholder="work/example.com"
			/>
			<Form.PasswordField
				id="password"
				title="Password"
				value={passwordValue}
				onChange={setPasswordValue}
			/>
			<Form.Separator />
			{fields.map((field, index) => (
				<Fragment key={`${field.line}-${index}`}>
					<Form.TextField
						id={`key-${index}`}
						title="Field"
						defaultValue={field.key}
					/>
					{isSensitiveKey(field.key, initialHiddenKeys) ? (
						<Form.PasswordField
							id={`value-${index}`}
							title="Value"
							defaultValue={field.value}
						/>
					) : (
						<Form.TextArea
							id={`value-${index}`}
							title="Value"
							defaultValue={field.value}
						/>
					)}
				</Fragment>
			))}
		</Form>
	)
}

function serializeSecret(password: string, fields: SecretField[]): string {
	return [
		password,
		...fields.flatMap(({ key, value }) => {
			if (!key && !value) return []
			if (!key) return [value]
			return value.split("\n").map((line) => `${key}: ${line}`)
		}),
	].join("\n")
}

function FieldForm({
	entry,
	password,
	fields,
	field,
	passwordMode,
	onSaved,
}: {
	entry: Entry
	password: string
	fields: SecretField[]
	field?: SecretField
	passwordMode?: boolean
	onSaved: (password: string, fields: SecretField[]) => void
}) {
	const [isLoading, setIsLoading] = useState(false)
	const [passwordValue, setPasswordValue] = useState(password)
	const { pop } = useNavigation()

	async function submit(values: FormTypes.Values) {
		const nextPassword = passwordMode
			? String(values.value ?? "")
			: password
		const nextFields = field
			? fields.map((current) =>
					current.line === field.line
						? {
								...current,
								key: String(values.key ?? "").trim(),
								value: String(values.value ?? ""),
							}
						: current,
				)
			: passwordMode
				? fields
				: [
						...fields,
						{
							key: String(values.key ?? "").trim(),
							value: String(values.value ?? ""),
							line: fields.length + 1,
						},
					]
		if (!nextPassword) {
			await showToast({
				style: Toast.Style.Failure,
				title: "Password is required",
			})
			return
		}
		setIsLoading(true)
		try {
			await saveEntry(
				entry.path,
				serializeSecret(nextPassword, nextFields),
			)
			await showToast({
				style: Toast.Style.Success,
				title: "Field updated",
			})
			onSaved(nextPassword, nextFields)
			pop()
		} catch (error) {
			await showToast({
				style: Toast.Style.Failure,
				title: "gopass failed",
				message: errorMessage(error),
			})
		} finally {
			setIsLoading(false)
		}
	}

	return (
		<Form
			isLoading={isLoading}
			navigationTitle={
				passwordMode
					? "Edit password"
					: field
						? `Edit ${field.key || "value"}`
						: "Add field"
			}
			actions={
				<ActionPanel>
					<Action.SubmitForm
						title={field ? "Save field" : "Add field"}
						onSubmit={submit}
					/>
					{passwordMode ? (
						<Action.Push
							title="Generate password"
							icon={Icon.Key}
							shortcut={{ key: "g", modifiers: ["ctrl"] }}
							target={
								<PasswordGenerator
									onGenerated={setPasswordValue}
								/>
							}
						/>
					) : null}
				</ActionPanel>
			}
		>
			{!passwordMode ? (
				<Form.TextField
					id="key"
					title="Field"
					defaultValue={field?.key}
				/>
			) : null}
			{passwordMode ? (
				<Form.PasswordField
					id="value"
					title="Password"
					value={passwordValue}
					onChange={setPasswordValue}
				/>
			) : (
				<Form.TextArea
					id="value"
					title="Value"
					defaultValue={field?.value}
				/>
			)}
		</Form>
	)
}

function EntryView({
	entry,
	onUpdated,
}: {
	entry: Entry
	onUpdated: () => void
}) {
	const [content, setContent] = useState<string>()
	const [isLoading, setIsLoading] = useState(true)
	const [safeContent, setSafeContent] = useState(true)
	const [configuredHiddenKeys, setConfiguredHiddenKeys] = useState<string[]>(
		[],
	)

	useEffect(() => {
		let active = true
		runGopass(["show", "--unsafe", "--noparsing", "--nosync", entry.path])
			.then((value) => {
				if (active) setContent(value)
			})
			.catch(() => {
				if (active) setContent(undefined)
			})
			.finally(() => {
				if (active) setIsLoading(false)
			})
		return () => {
			active = false
		}
	}, [entry.path])

	useEffect(() => {
		let active = true
		void readGopassSafetyConfig().then((config) => {
			if (!active) return
			setSafeContent(config.safeContent)
			setConfiguredHiddenKeys(config.hiddenKeys)
		})
		return () => {
			active = false
		}
	}, [])

	const parsed = content === undefined ? undefined : parseSecret(content)
	const unsafeKeys = hiddenKeys(parsed?.fields ?? [])
	const hidden = [...configuredHiddenKeys, ...unsafeKeys]
	const [otp, setOtp] = useState<string>()

	useEffect(() => {
		if (
			!parsed?.fields.some(
				(field) => field.key.toLowerCase() === "otpauth",
			)
		)
			return

		let active = true
		const updateOtp = async () => {
			try {
				const value = await runGopass([
					"otp",
					"--password",
					"--nosync",
					entry.path,
				])
				if (active) setOtp(value.trim())
			} catch {
				if (active) setOtp(undefined)
			}
		}

		void updateOtp()
		const interval = setInterval(() => void updateOtp(), 1000)
		return () => {
			active = false
			clearInterval(interval)
		}
	}, [content, entry.path])

	async function copyField(field: {
		key: string
		line: number
		copyByKey?: boolean
		value: string
	}) {
		const key = field.key.toLowerCase()
		const args =
			key === "otpauth"
				? ["otp", "--clip", "--nosync", entry.path]
				: key === "password"
					? ["show", "--clip", "--nosync", entry.path]
					: field.copyByKey
						? ["show", "--clip", "--nosync", entry.path, field.key]
						: [
								"show",
								`--clip=${field.line}`,
								"--noparsing",
								"--nosync",
								entry.path,
							]
		await copyWithGopass(args, `${field.key} copied`)
	}
	async function deleteField(field: SecretField) {
		if (!parsed) return
		if (
			!(await confirmAlert({
				title: `Delete ${field.key || "value"}?`,
				message: "This cannot be undone.",
			}))
		)
			return

		const nextFields = parsed.fields.filter(
			(current) => current.line !== field.line,
		)
		setIsLoading(true)
		try {
			await saveEntry(
				entry.path,
				serializeSecret(parsed.password, nextFields),
			)
			setContent(serializeSecret(parsed.password, nextFields))
			onUpdated()
			await showToast({
				style: Toast.Style.Success,
				title: "Field deleted",
			})
		} catch (error) {
			await showToast({
				style: Toast.Style.Failure,
				title: "gopass failed",
				message: errorMessage(error),
			})
		} finally {
			setIsLoading(false)
		}
	}

	const fields = parsed
		? [
				{
					key: "Password",
					value: safeContent ? "••••••" : parsed.password,
					line: 0,
				},
				...parsed.fields,
			]
		: []

	function editTarget(field: SecretField) {
		if (!parsed) return null
		const passwordMode = field.key.toLowerCase() === "password"
		return (
			<FieldForm
				entry={entry}
				password={parsed.password}
				fields={parsed.fields}
				field={passwordMode ? undefined : field}
				passwordMode={passwordMode}
				onSaved={(nextPassword, nextFields) => {
					setContent(serializeSecret(nextPassword, nextFields))
					onUpdated()
				}}
			/>
		)
	}
	function addFieldTarget() {
		if (!parsed) return null
		return (
			<FieldForm
				entry={entry}
				password={parsed.password}
				fields={parsed.fields}
				onSaved={(nextPassword, nextFields) => {
					setContent(serializeSecret(nextPassword, nextFields))
					onUpdated()
				}}
			/>
		)
	}

	return (
		<List
			isLoading={isLoading}
			navigationTitle={entry.path}
			searchBarPlaceholder="Search fields"
		>
			{fields.map((field) => (
				<List.Item
					key={`${field.line}-${field.key}`}
					title={field.key || "Value"}
					subtitle={
						field.key.toLowerCase() === "otpauth"
							? (otp ?? "Generating OTP…")
							: safeContent && isSensitiveKey(field.key, hidden)
								? "••••••"
								: field.value
					}
					actions={
						<ActionPanel>
							<Action
								title={`Copy ${field.key || "value"}`}
								icon={Icon.CopyClipboard}
								shortcut={copyShortcut(field.key)}
								onAction={() => void copyField(field)}
							/>
							<ActionPanel.Section title="Field actions">
								<Action.Push
									title="Edit field"
									icon={Icon.Pencil}
									shortcut={{ key: "e", modifiers: ["ctrl"] }}
									target={editTarget(field)}
								/>
								<Action.Push
									title="Add field"
									icon={Icon.Plus}
									shortcut={{ key: "n", modifiers: ["ctrl"] }}
									target={addFieldTarget()}
								/>
								<Action
									title="Delete field"
									icon={Icon.Trash}
									style="destructive"
									shortcut={{ key: "d", modifiers: ["ctrl"] }}
									onAction={() => void deleteField(field)}
								/>
							</ActionPanel.Section>
						</ActionPanel>
					}
				/>
			))}
		</List>
	)
}

export default function Gopass() {
	const [entries, setEntries] = useState<Entry[]>([])
	const [isLoading, setIsLoading] = useState(true)
	const [error, setError] = useState<string>()
	const [entryFields, setEntryFields] = useState<Record<string, string[]>>({})
	const { push } = useNavigation()

	async function deleteEntry(entry: Entry) {
		if (
			!(await confirmAlert({
				title: `Delete ${entry.path}?`,
				message: "This cannot be undone.",
			}))
		)
			return

		setIsLoading(true)

		try {
			await runGopass([
				"delete",
				"--force",
				"--yes",
				"--nosync",
				entry.path,
			])
			await refresh()
			await showToast({
				style: Toast.Style.Success,
				title: "Entry deleted",
			})
		} catch (error) {
			await showToast({
				style: Toast.Style.Failure,
				title: "gopass failed",
				message: errorMessage(error),
			})
		} finally {
			setIsLoading(false)
		}
	}
	async function copyEntryField(entry: Entry, field: string) {
		const args = [
			...(field === "totp" ? ["otp", "--clip"] : ["show", "--clip"]),
			"--nosync",
			entry.path,
			...(field === "password" || field === "totp" ? [] : [field]),
		]
		await copyWithGopass(args, `${field} copied`)
	}

	async function refresh() {
		setIsLoading(true)
		setError(undefined)
		try {
			setEntries(await listEntries())
		} catch (reason) {
			setError(errorMessage(reason))
		} finally {
			setIsLoading(false)
		}
	}

	useEffect(() => {
		void refresh()
	}, [])

	useEffect(() => {
		let active = true
		void Promise.all(
			entries.map(async (entry) => {
				try {
					const content = await runGopass([
						"show",
						"--unsafe",
						"--noparsing",
						"--nosync",
						entry.path,
					])
					const keys = parseSecret(content).fields.map((field) =>
						field.key.toLowerCase(),
					)
					return [entry.path, keys] as const
				} catch {
					return [entry.path, []] as const
				}
			}),
		).then((loaded) => {
			if (active) setEntryFields(Object.fromEntries(loaded))
		})
		return () => {
			active = false
		}
	}, [entries])

	const create = (
		<EntryForm
			onSaved={() => {
				void refresh()
			}}
		/>
	)

	function copyActions(entry: Entry) {
		const keys = entryFields[entry.path] ?? []
		const actions = [
			<Action
				key="password"
				title="Copy password"
				icon={Icon.CopyClipboard}
				shortcut={{ key: "c", modifiers: ["ctrl"] }}
				onAction={() => void copyEntryField(entry, "password")}
			/>,
		]
		if (keys.includes("username")) {
			actions.push(
				<Action
					key="username"
					title="Copy username"
					icon={Icon.CopyClipboard}
					shortcut={{ key: "b", modifiers: ["ctrl"] }}
					onAction={() => void copyEntryField(entry, "username")}
				/>,
			)
		}
		if (keys.includes("url")) {
			actions.push(
				<Action
					key="url"
					title="Copy URL"
					icon={Icon.CopyClipboard}
					shortcut={{ key: "u", modifiers: ["ctrl"] }}
					onAction={() => void copyEntryField(entry, "url")}
				/>,
			)
		}
		if (keys.includes("totp") || keys.includes("otpauth")) {
			actions.push(
				<Action
					key="totp"
					title="Copy TOTP"
					icon={Icon.CopyClipboard}
					shortcut={{ key: "t", modifiers: ["ctrl"] }}
					onAction={() => void copyEntryField(entry, "totp")}
				/>,
			)
		}
		return actions
	}

	return (
		<List
			isLoading={isLoading}
			searchBarPlaceholder="Search gopass entries"
			actions={
				<ActionPanel>
					<Action
						title="Refresh"
						icon={Icon.ArrowClockwise}
						onAction={() => void refresh()}
					/>
					<ActionPanel.Section title="Entry actions">
						<Action
							title="Add entry"
							icon={Icon.Plus}
							shortcut={{ key: "n", modifiers: ["ctrl"] }}
							onAction={() => push(create)}
						/>
					</ActionPanel.Section>
				</ActionPanel>
			}
		>
			{error ? (
				<List.EmptyView
					title="Unable to read gopass"
					description={error}
				/>
			) : null}
			{entries.map((entry) => (
				<List.Item
					key={entry.path}
					title={entry.path}
					icon={Icon.Key}
					actions={
						<ActionPanel>
							<Action.Push
								title="View entry"
								target={
									<EntryView
										entry={entry}
										onUpdated={() => {
											void refresh()
										}}
									/>
								}
							/>
							<ActionPanel.Section title="Copy fields">
								{copyActions(entry)}
							</ActionPanel.Section>
							<ActionPanel.Section title="Entry actions">
								<Action
									title="Add entry"
									icon={Icon.Plus}
									shortcut={{ key: "n", modifiers: ["ctrl"] }}
									onAction={() => push(create)}
								/>
								<Action
									title="Delete entry"
									icon={Icon.Trash}
									style="destructive"
									shortcut={{ key: "d", modifiers: ["ctrl"] }}
									onAction={() => void deleteEntry(entry)}
								/>
							</ActionPanel.Section>
						</ActionPanel>
					}
				/>
			))}
		</List>
	)
}
