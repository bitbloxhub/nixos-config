mod bar;

use gtk4::Application;
use gtk4::prelude::{ApplicationExt, ApplicationExtManual, ObjectExt};

fn main() -> gtk4::glib::ExitCode {
	let _ = any_spawner::Executor::init_glib();

	let app = Application::builder()
		.application_id("com.bitbloxhub.GtkReactiveShell")
		.build();

	app.connect_activate(build_ui);
	app.run()
}

fn build_ui(app: &Application) {
	let bar = bar::Bar::new(app);
	bar.present();

	unsafe {
		app.set_data("bar", bar);
	}
}
