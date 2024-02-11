namespace RetroPlus {
    public class PreferencesDialog : Adw.PreferencesWindow {
        ListStore systems_model { get; set; }
        Adw.ComboRow systems_row { get; set; }
        Adw.EntryRow directory_row { get; set; }

        construct {
            //
            this.set_size_request (250, 350);
            this.set_default_size (250, 350);

            //
            var page = new Adw.PreferencesPage ();
            page.add (get_system_directories_group ());

            //
            this.add (page);
        }

        Adw.PreferencesGroup get_system_directories_group () {
            //
            var systems_factory = new Gtk.SignalListItemFactory ();
            systems_factory.bind.connect (systems_factory_bind);
            systems_factory.setup.connect (systems_factory_setup);

            //
            systems_model = new ListStore (typeof (Models.System));

            //
            systems_row = new Adw.ComboRow ();
            systems_row.set_title (_("Choose a system"));
            systems_row.set_factory (systems_factory);
            systems_row.set_model (systems_model);
            systems_row.notify["selected-item"].connect (on_systems_row_selected_item);

            //
            var directory_button = new Gtk.Button.from_icon_name ("folder-open-symbolic");
            directory_button.add_css_class ("flat");
            directory_button.set_size_request (25, 25);
            directory_button.clicked.connect (on_directory_button_clicked);

            //
            var directory_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            directory_box.set_valign (Gtk.Align.CENTER);
            directory_box.append (directory_button);

            //
            directory_row = new Adw.EntryRow ();
            directory_row.set_title (_("Download directory"));
            directory_row.set_editable (false);
            directory_row.add_suffix (directory_box);

            //
            var system_directories_group = new Adw.PreferencesGroup ();
            system_directories_group.set_title (_("Download directory per system"));
            system_directories_group.add (systems_row);
            system_directories_group.add (directory_row);

            //
            return system_directories_group;
        }

        public void initialize (Gee.Iterator<Models.System> systems) {
            //
            systems_model.remove_all ();

            //
            systems.foreach ((system) => {
                if (system.title != "All")systems_model.append (system);

                return true;
            });

            //
            on_systems_row_selected_item ();
        }

        void on_systems_row_selected_item () {
            var system = (Models.System) systems_row.get_selected_item ();

            directory_row.set_text (Application.settings.get_string (system.download_directory_setting_name));
        }

        void on_directory_button_clicked () {
            var file_dialog = new Gtk.FileDialog ();
            file_dialog.set_modal (true);
            file_dialog.set_title (_("Choose the download directory"));
            file_dialog.select_folder.begin (this, null, (obj, res) => {
                try {
                    var file = file_dialog.select_folder.end (res);
                    if (file == null)return;
                    var system = (Models.System) systems_row.get_selected_item ();
                    Application.settings.set_string (system.download_directory_setting_name, file.get_path ());
                    on_systems_row_selected_item ();
                } catch (Error e) {
                    message (e.message);
                }
            });
        }

        void systems_factory_bind (Gtk.SignalListItemFactory factory, Object item) {
            Gtk.ListItem list_item = item as Gtk.ListItem;

            var system = list_item.get_item () as Models.System;

            var title = list_item.get_data<Gtk.Label> ("title");
            title.label = system.title;
        }

        void systems_factory_setup (Gtk.SignalListItemFactory factory, Object item) {
            Gtk.ListItem list_item = item as Gtk.ListItem;

            var title = new Gtk.Label ("");
            title.set_hexpand (true);
            title.set_halign (Gtk.Align.START);

            list_item.set_data ("title", title);
            list_item.set_child (title);
        }
    }
}