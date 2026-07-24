#include <gtk/gtk.h>

int main(int argc, char **argv) {
	if (argc != 2) return 2;

	gtk_init();

	GdkDisplay *display = gdk_display_get_default();
	if (display == NULL) return 1;

	GtkIconTheme *theme = gtk_icon_theme_get_for_display(display);
	if (!gtk_icon_theme_has_icon(theme, argv[1])) return 1;
	GtkIconPaintable *icon = gtk_icon_theme_lookup_icon(
		theme,
		argv[1],
		NULL,
		48,
		1,
		GTK_TEXT_DIR_LTR,
		0
	);
	if (icon == NULL) return 1;

	GFile *file = gtk_icon_paintable_get_file(icon);
	if (file == NULL) return 1;

	char *path = g_file_get_path(file);
	if (path == NULL) return 1;

	g_print("%s\n", path);
	g_free(path);
	return 0;
}
