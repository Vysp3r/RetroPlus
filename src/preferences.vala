namespace RetroPlus {
    public class Preferences : Adw.PreferencesWindow {
        public Preferences(Window parent) {
            this.set_transient_for(parent);
        }

        construct {
            //
            this.set_size_request(250, 175);
            this.set_default_size(250, 175);

            //
            this.add(get_test_page());
        }

        Adw.PreferencesPage get_test_page() {
            //
            var file_dialog = new Gtk.FileDialog();
            file_dialog.set_modal(true);
            file_dialog.set_title(_("Choose the download directory"));

            //
            var download_directory_button = new Gtk.Button.from_icon_name("folder-open-symbolic");
            download_directory_button.add_css_class("flat");
            download_directory_button.set_size_request(25, 25);
            download_directory_button.clicked.connect(() => {
                file_dialog.select_folder.begin(this, null, (obj, res) => {
                    try {
                        var file = file_dialog.select_folder.end(res);
                        if (file == null)return;
                        Application.settings.set_string("download-directory", file.get_path());
                    } catch (Error e) {
                        message(e.message);
                    }
                });
            });

            //
            var download_directory_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
            download_directory_box.set_valign(Gtk.Align.CENTER);
            download_directory_box.append(download_directory_button);

            //
            var download_directory_row = new Adw.EntryRow();
            download_directory_row.set_title(_("Download directory"));
            download_directory_row.set_editable(false);
            download_directory_row.add_suffix(download_directory_box);

            //
            Application.settings.bind("download-directory", download_directory_row, "text", GLib.SettingsBindFlags.DEFAULT);

            //
            var main_group = new Adw.PreferencesGroup();
            main_group.add(download_directory_row);

            //
            var page = new Adw.PreferencesPage();
            page.add(main_group);

            //
            return page;
        }
    }
}