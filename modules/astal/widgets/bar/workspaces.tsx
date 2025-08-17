import { Accessor, For, createBinding } from "ags"
import NiriGObject from "../../utils/niri"

export default function Workspaces({ niri }: { niri: NiriGObject }) {
	const workspacesBinding = createBinding(niri, "workspaces")
	const workspaces = workspacesBinding((workspaces) => {
		return workspaces.sort((a, b) => {
			return a.idx - b.idx
		})
	})

	return (
		<box class="workspaces">
			<For each={workspaces}>
				{(workspace) => {
					return (
						<button
							$={(self) => {
								niri.connect("focus-changed", (_, id) => {
									const isFocused = workspace.id === id
									if (
										self.has_css_class(
											"workspace-button-focused",
										) &&
										!isFocused
									) {
										self.remove_css_class(
											"workspace-button-focused",
										)
									} else if (
										!self.has_css_class(
											"workspace-button-focused",
										) &&
										isFocused
									) {
										self.add_css_class(
											"workspace-button-focused",
										)
									}
								})
							}}
							onClicked={() => {
								niri.focusWorkspace(workspace.idx)
							}}
							class={`workspace-button ${workspace.is_focused ? "workspace-button-focused" : ""}`}
						>
							<label label={workspace.idx.toString()} />
						</button>
					)
				}}
			</For>
		</box>
	)
}
