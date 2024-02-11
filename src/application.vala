namespace RetroPlus {
    public class Application : Adw.Application {
        public static Settings settings;

        Gee.HashMap<string, Models.System> systems;
        List<Models.Source> sources;

        Gee.Iterator<Models.System> get_systems_ordered_by_name () {
            return systems.values.order_by ((a, b) => {
                return strcmp (a.title, b.title);
            });
        }

        construct {
            this.application_id = Constants.APP_ID;
            this.flags |= ApplicationFlags.FLAGS_NONE;

            Intl.bindtextdomain (Constants.APP_ID, Constants.LOCALE_DIR);
        }

        public override void activate () {
            //
            settings = new Settings ("com.vysp3r.RetroPlus");

            //
            var display = Gdk.Display.get_default ();

            //
            Gtk.IconTheme.get_for_display (display).add_resource_path ("/com/vysp3r/RetroPlus/icons");

            //
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/vysp3r/RetroPlus/css/style.css");

            //
            Gtk.StyleContext.add_provider_for_display (display, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            //
            add_shortcuts ();

            //
            if (!Models.Region.initialize ()) {
                //
                message ("An error occured during the initialization of the flags folder.");

                //
                var status_window = new StatusWindow ();
                status_window.set_application (this);
                status_window.initialize ("bug-symbolic", "", _("An error occurred during the initialization.") + "\n" + _("Please report this on our GitHub."));
                status_window.present ();

                //
                return;
            }

            //
            sources = Models.Source.get_sources ();

            //
            systems = Models.System.get_systems ();

            //
            foreach (var key in Application.settings.settings_schema.list_keys ()) {
                var download_directory = Application.settings.get_string (key);
                var user_download_directory = GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOWNLOAD);
                if (download_directory == "")Application.settings.set_string (key, user_download_directory);
                else if (!FileUtils.test (download_directory, GLib.FileTest.IS_DIR)) {
                    message (@"The $key setting was invalid therefore it was reset to '$user_download_directory'");
                    Application.settings.set_string (key, user_download_directory);
                }
            }

            //
            var main_window = new MainWindow ();
            main_window.set_application (this);
            main_window.initialize (get_systems_ordered_by_name (), sources);
            main_window.present ();
        }

        void add_shortcuts () {
            // Register the action to display the about dialog
            var about_action = new SimpleAction ("show-about", null);
            about_action.activate.connect (this.show_about_dialog);
            this.add_action (about_action);

            // Register the action to display the preferences dialog
            var preferences_action = new SimpleAction ("show-preferences", null);
            preferences_action.activate.connect (this.show_preferences_dialog);
            this.add_action (preferences_action);

            // Register the action to close the app on Ctrl + Q
            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (this.quit);
            this.set_accels_for_action ("app.quit", { "<Ctrl>Q" });
            this.add_action (quit_action);
        }

        void show_preferences_dialog () {
            var preferences_dialog = new PreferencesDialog ();
            preferences_dialog.set_transient_for (this.get_active_window ());
            preferences_dialog.initialize (get_systems_ordered_by_name ());
            preferences_dialog.present ();
        }

        void show_about_dialog () {
            const string[] devs = {
                "Charles Malouin (Vysp3r) https://github.com/Vysp3r",
                null
            };

            const string[] thanks = {
                "GNOME Project https://www.gnome.org/",
                "Bootstrap Icons https://github.com/twbs/icons",
                "Vimm's Lair https://vimm.net/",
                null
            };

            var about_dialog = new Adw.AboutWindow ();
            about_dialog.set_application_name (Constants.APP_NAME);
            about_dialog.set_application_icon (Constants.APP_ID);
            about_dialog.set_version (Constants.APP_VERSION);
            about_dialog.set_comments ("A simple ROM downloader");
            about_dialog.add_link ("Github", "https://github.com/Vysp3r/RetroPlus");
            about_dialog.set_issue_url ("https://github.com/Vysp3r/RetroPlus/issues/new/choose");
            about_dialog.set_copyright ("© 2024 Vysp3r");
            about_dialog.set_license_type (Gtk.License.GPL_3_0);
            about_dialog.set_developers (devs);
            about_dialog.add_credit_section ("Special thanks to", thanks);
            about_dialog.set_transient_for (this.get_active_window ());
            about_dialog.set_modal (true);
            about_dialog.present ();
        }

        public static int main (string[] args) {
            if (Thread.supported () == false) {
                message ("Threads are not supported!");
                return -1;
            }

            var application = new Application ();

            return application.run (args);
        }
    }
}