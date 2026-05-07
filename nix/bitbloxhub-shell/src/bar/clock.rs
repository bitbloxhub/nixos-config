use gtk4::{Align, Label, glib};
use reactive_graph::{
	effect::RenderEffect,
	traits::{Get, Set},
};
use reactive_stores::Store;

#[derive(Clone, Store)]
pub struct ClockState {
	pub value: String,
}

fn now_hhmmss() -> String {
	let dt = glib::DateTime::now_local().expect("local datetime unavailable");
	dt.format("%H:%M:%S")
		.expect("failed to format time")
		.to_string()
}

pub struct ClockWidget {
	pub label: Label,
	_effect: RenderEffect<()>,
	_tick: glib::SourceId,
}

impl ClockWidget {
	pub fn new() -> Self {
		let state = Store::new(ClockState {
			value: now_hhmmss(),
		});

		let label = Label::builder().halign(Align::End).hexpand(true).build();

		let effect = RenderEffect::new({
			let state = state;
			let label = label.clone();

			move |_| {
				label.set_label(&state.value().get());
			}
		});

		let tick = glib::timeout_add_seconds_local(1, {
			let state = state;
			move || {
				state.value().set(now_hhmmss());
				glib::ControlFlow::Continue
			}
		});

		Self {
			label,
			_effect: effect,
			_tick: tick,
		}
	}
}
