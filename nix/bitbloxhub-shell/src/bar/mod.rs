use gtk4::prelude::{BoxExt, GtkWindowExt};
use gtk4::{Align, Application, ApplicationWindow, Box as GtkBox, Label, Orientation};
use gtk4_layer_shell::{Edge, Layer, LayerShell};

mod clock;
mod workspace;

use clock::ClockWidget;
use workspace::WorkspaceWidget;

pub struct Bar {
	window: ApplicationWindow,
	_workspace: WorkspaceWidget,
	_clock: ClockWidget,
}

impl Bar {
	pub fn new(app: &Application) -> Self {
		let root = GtkBox::builder()
			.orientation(Orientation::Horizontal)
			.spacing(12)
			.margin_top(6)
			.margin_bottom(6)
			.margin_start(12)
			.margin_end(12)
			.build();

		let workspace = WorkspaceWidget::new();
		let center = Label::builder()
			.halign(Align::Center)
			.hexpand(true)
			.label("bitbloxhub shell")
			.build();
		let clock = ClockWidget::new();

		root.append(&workspace.label);
		root.append(&center);
		root.append(&clock.label);

		let window = ApplicationWindow::builder()
			.application(app)
			.title("bitbloxhub shell")
			.default_width(1200)
			.default_height(36)
			.resizable(false)
			.deletable(false)
			.child(&root)
			.build();

		window.init_layer_shell();
		window.set_layer(Layer::Top);
		window.set_namespace(Some("bitbloxhub-shell"));
		window.set_anchor(Edge::Top, true);
		window.set_anchor(Edge::Left, true);
		window.set_anchor(Edge::Right, true);
		window.auto_exclusive_zone_enable();

		Self {
			window,
			_workspace: workspace,
			_clock: clock,
		}
	}

	pub fn present(&self) {
		self.window.present();
	}
}
