namespace RetroPlus {
    public class Window : Adw.ApplicationWindow {
        Gee.HashMap<string, Models.System> systems;

        Widgets.StatusBox status_box { get; set; }
        Widgets.SearchBox search_box { get; set; }
        Adw.NavigationView navigation_view { get; set; }

        public bool settings_error { get; set; }
        public bool initialization_error { get; set; }
        public bool systems_error { get; set; }
        public bool init_done { get; set; }

        construct {
            //
            this.set_application ((Adw.Application) GLib.Application.get_default ());
            this.set_title (Constants.APP_NAME);
            this.set_size_request (400, 500);
            this.set_default_size (400, 500);

            //
            status_box = new Widgets.StatusBox ();
            status_box.set_values ("com.vysp3r.RetroPlus", _("Loading") + "...", "");

            //
            this.notify["init-done"].connect (on_init_done_changed);

            //
            this.notify["settings-error"].connect (on_error_changed);

            //
            this.notify["games-error"].connect (on_error_changed);

            //
            this.notify["systems-error"].connect (on_error_changed);

            //
            this.set_content (status_box);
        }

        public void initialize () {
            new Thread<void> ("initialize", () => {
                //
                settings_error = false;
                initialization_error = false;
                systems_error = false;
                init_done = false;

                //
                var download_directory = Application.settings.get_string ("download-directory");
                var user_download_directory = GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOWNLOAD);
                if (download_directory == "")Application.settings.set_string ("download-directory", user_download_directory);
                else if (settings_error = !FileUtils.test (download_directory, GLib.FileTest.IS_DIR)) {
                    message (@"The download-directory setting was invalid therefore it was reset to '$user_download_directory'");
                    Application.settings.set_string ("download-directory", user_download_directory);
                    return;
                }

                //
                if (initialization_error = !Models.Region.initialize ())return;

                //
                systems = new Gee.HashMap<string, Models.System> ();
                if (systems_error = !Models.System.get_systems (ref systems))return;

                //
                init_done = true;
            });
        }

        void on_init_done_changed () {
            //
            if (!init_done)return;

            //
            var ordered_systems = systems.values.order_by ((a, b) => {
                return strcmp (a.title, b.title);
            });

            //
            var search_filter_box = new Widgets.SearchFilterBox ();
            search_filter_box.initialize (ordered_systems);

            //
            search_box = new Widgets.SearchBox (search_filter_box);

            //
            var search_page = new Adw.NavigationPage.with_tag (search_box, Constants.APP_NAME, "search");

            //
            navigation_view = new Adw.NavigationView ();
            navigation_view.set_animate_transitions (true);
            navigation_view.add (search_page);

            //
            this.set_content (navigation_view);
        }

        void on_error_changed () {
            //
            var title = "";

            //
            if (settings_error) {
                title = _("An error occured during the initialization.");
            }

            //
            if (initialization_error) {
                title = _("An error occured during the initialization.");
            }

            //
            if (systems_error) {
                title = _("An error occured while loading the systems.");
            }

            //
            if (title != "") {
                //
                status_box.set_values (null, title, _("To fix this problem, you should report this issue on GitHub."));

                //
                this.set_content (status_box);
            }
        }
    }
}