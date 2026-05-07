use gtk4::{Align, Label};
use reactive_graph::{effect::RenderEffect, traits::Get};
use reactive_stores::Store;

#[derive(Clone, Store)]
pub struct WorkspaceState {
	pub name: String,
}

pub struct WorkspaceWidget {
	pub label: Label,
	_effect: RenderEffect<()>,
}

impl WorkspaceWidget {
	pub fn new() -> Self {
		let state = Store::new(WorkspaceState {
			name: "ws1".to_string(),
		});

		let label = Label::builder().halign(Align::Start).hexpand(true).build();

		let effect = RenderEffect::new({
			let state = state;
			let label = label.clone();

			move |_| {
				label.set_label(&format!("workspace: {}", state.name().get()));
			}
		});

		Self {
			label,
			_effect: effect,
		}
	}
}
