namespace RetroPlus.Widgets {
    public class MyrientGameDetailDialog : Adw.MessageDialog {
        Gtk.Label download_size_label { get; set; }
        Models.MyrientGame game { get; set; }
        string system_path { get; set; }

        public signal void download_clicked (Models.Game game, string download_url);
        public signal void close_clicked ();

        construct {
            this.add_response ("close", _("Close"));
            this.set_response_appearance ("close", Adw.ResponseAppearance.DEFAULT);

            this.add_response ("download", _("Download"));
            this.set_response_appearance ("download", Adw.ResponseAppearance.SUGGESTED);

            this.set_close_response ("close");

            this.response.connect (on_response);

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            box.append (get_info_box ());

            this.set_extra_child (box);
        }

        void on_response (string response) {
            switch (response) {
            case "download":
                download_clicked (game, game.get_download_url (system_path));
                break;
            case "close":
                close_clicked ();
                break;
            }
        }

        Gtk.Box get_info_box () {
            download_size_label = new Gtk.Label (null);

            var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            info_box.append (download_size_label);

            return info_box;
        }

        public void initialize (Models.MyrientGame game, string system_path) {
            this.game = game;
            this.system_path = system_path;

            this.set_heading (game.title);

            download_size_label.set_text (_("Size") + ": " + game.file_size.to_string ()); // TODO Format this
        }
    }
}