namespace RetroPlus.Widgets {
    public class DownloadRow : Gtk.ListBoxRow {
        public Models.Game game { get; construct; }
        public Gtk.Button cancel_button { get; set; }
        Gtk.ProgressBar progress_bar { get; set; }

        public signal void start_download ();

        public DownloadRow (Models.Game game) {
            Object (game: game);
        }

        construct {
            //
            var title_label = new Gtk.Label (game.title);
            title_label.set_ellipsize (Pango.EllipsizeMode.END);
            title_label.set_tooltip_text (game.title);
            title_label.set_hexpand (true);

            //
            cancel_button = new Gtk.Button.from_icon_name ("x-lg-symbolic");
            cancel_button.add_css_class ("flat");

            //
            var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            top_box.append (title_label);
            top_box.append (cancel_button);

            //
            progress_bar = new Gtk.ProgressBar ();
            progress_bar.set_show_text (true);
            progress_bar.set_text (_("Queued"));

            //
            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.add_css_class ("p-10");
            main_box.append (top_box);
            main_box.append (progress_bar);

            //
            this.set_child (main_box);
        }

        public void set_starting () {
            progress_bar.set_text (_("Starting"));
        }

        public void set_cancelling () {
            progress_bar.set_text (_("Cancelling"));
        }

        public void set_progress (double progress) {
            progress_bar.set_fraction (progress);
        }

        public void set_download_speed (double bytes) {
            var pourcentage = progress_bar.get_fraction () * 100;
            if (bytes < 1024.0f) {
                progress_bar.set_text ("%.0f% | ".printf (pourcentage) + "%.0f Bps".printf (bytes));
            } else {
                var kilobytes = bytes / 1024.0f;
                if (kilobytes < 1024.0f) {
                    progress_bar.set_text ("%.0f% | ".printf (pourcentage) + "%.0f Kbps".printf (kilobytes));
                } else {
                    var megabytes = kilobytes / 1024.0f;
                    progress_bar.set_text ("%.0f% | ".printf (pourcentage) + "%.1f Mbps".printf (megabytes));
                }
            }
        }
    }
}