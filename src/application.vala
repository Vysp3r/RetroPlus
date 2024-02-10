namespace RetroPlus {
    public class Application : Adw.Application {
        public static Window main_window;
        public static Settings settings;

        construct {
            application_id = Constants.APP_ID;
            flags |= ApplicationFlags.FLAGS_NONE;

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

            //
            main_window = new Window ();
            main_window.initialize ();
            main_window.show ();
        }

        void show_preferences_dialog () {
            var preferences_dialog = new Preferences (main_window);
            preferences_dialog.show ();
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

            var about_window = new Adw.AboutWindow ();
            about_window.set_application_name (Constants.APP_NAME);
            about_window.set_application_icon (Constants.APP_ID);
            about_window.set_version (Constants.APP_VERSION);
            about_window.set_comments ("A simple ROM downloader");
            about_window.add_link ("Github", "https://github.com/Vysp3r/RetroPlus");
            about_window.set_issue_url ("https://github.com/Vysp3r/RetroPlus/issues/new/choose");
            about_window.set_copyright ("© 2024 Vysp3r");
            about_window.set_license_type (Gtk.License.GPL_3_0);
            about_window.set_developers (devs);
            about_window.add_credit_section ("Special thanks to", thanks);
            about_window.set_transient_for (main_window);
            about_window.set_modal (true);
            about_window.show ();
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