namespace RetroPlus.Widgets {
    public class SearchRow : Gtk.Box {
        public Models.Game game { get; construct; }
        public bool show_system_label { get; construct; }

        public SearchRow (Models.Game game, bool show_system_label) {
            Object (game: game, show_system_label: show_system_label);
        }

        construct {
            //
            this.set_spacing (10);
            this.add_css_class ("p-10");

            //
            var system_label = new Gtk.Label (game.system);
            system_label.set_halign (Gtk.Align.CENTER);
            system_label.set_size_request (80, 0);

            //
            var title = new Gtk.Label (game.title);
            title.set_ellipsize (Pango.EllipsizeMode.END);
            title.set_tooltip_text (game.title);
            title.set_halign (Gtk.Align.START);

            //
            var extra_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            extra_box.set_visible (game.extras.length () > 0);
            extra_box.add_css_class ("search-row-extra");

            foreach (var extra in game.extras) {
                var label = new Gtk.Label (extra.short_title);
                label.set_tooltip_text (extra.title);
                label.set_halign (Gtk.Align.START);

                extra_box.append (label);
            }

            var manual = new Gtk.Image.from_icon_name ("book-half-symbolic");
            manual.set_tooltip_text (_("Manual available"));

            //
            var spacer = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            spacer.set_hexpand (true);

            //
            var region_box = new Gtk.FlowBox ();
            region_box.set_max_children_per_line (2);
            region_box.set_halign (Gtk.Align.CENTER);
            region_box.set_size_request (50, 0);
            region_box.set_visible (game.regions.length () > 0);

            Models.Region.load_flags.begin (game.regions, (region) => {
                region.download_flag.begin ((obj, res) => {
                    var downloaded = region.download_flag.end (res);

                    if (downloaded) {
                        var image = new Gtk.Image.from_file (region.get_flag_path ());
                        image.set_tooltip_text (region.title);

                        region_box.append (image);
                    }
                });
            });

            //
            var version = new Gtk.Label ("v" + "%.2f".printf (game.medias.nth_data (0).version));
            version.set_halign (Gtk.Align.CENTER);
            version.set_size_request (55, 0);

            //
            if (show_system_label)this.append (system_label);
            this.append (title);
            this.append (extra_box);
            if (game.has_manual)this.append (manual);
            this.append (spacer);
            this.append (region_box);
            this.append (version);
        }
    }
}
