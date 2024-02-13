namespace RetroPlus.Widgets {
    public class SearchRow : Gtk.Box {
        Gtk.Label system_label { get; set; }
        Gtk.Label title_label { get; set; }
        Gtk.Box extra_box { get; set; }
        Gtk.Image manual_image { get; set; }
        Gtk.Grid region_grid { get; set; }
        Gtk.Label version_label { get; set; }

        construct {
            this.set_spacing (10);
            this.add_css_class ("p-10");

            system_label = new Gtk.Label (null);
            system_label.set_halign (Gtk.Align.CENTER);
            system_label.set_size_request (80, 0);

            title_label = new Gtk.Label (null);
            title_label.set_ellipsize (Pango.EllipsizeMode.END);
            title_label.set_halign (Gtk.Align.START);

            extra_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            extra_box.add_css_class ("search-row-extra");

            manual_image = new Gtk.Image.from_icon_name ("book-half-symbolic");
            manual_image.set_tooltip_text (_("Manual available"));

            var spacer = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            spacer.set_hexpand (true);

            region_grid = new Gtk.Grid ();
            region_grid.insert_row (0);
            region_grid.insert_row (0);
            region_grid.insert_column (0);
            region_grid.insert_column (0);
            region_grid.set_column_spacing (5);
            region_grid.set_column_homogeneous (true);
            region_grid.set_row_homogeneous (true);
            region_grid.set_halign (Gtk.Align.CENTER);
            region_grid.set_valign (Gtk.Align.CENTER);
            region_grid.set_size_request (50, 50);
            for (var i = 1; i <= 4; i++) {
                bool pair = (i % 2) == 0;
                int row = pair ? 1 : 0;
                int column = i > 2 ? 1 : 0;

                var image = new Gtk.Image ();
                region_grid.attach (image, column, row);
            }

            version_label = new Gtk.Label (null);
            version_label.set_halign (Gtk.Align.CENTER);
            version_label.set_size_request (55, 0);

            this.append (system_label);
            this.append (title_label);
            this.append (extra_box);
            this.append (manual_image);
            this.append (spacer);
            this.append (region_grid);
            this.append (version_label);
        }

        public void initialize (Models.Game game, bool show_system_label) {
            system_label.set_text (game.system);
            system_label.set_visible (show_system_label);

            title_label.set_text (game.title);
            title_label.set_tooltip_text (game.title);

            extra_box.set_visible (game.extras.length () > 0);
            while (extra_box.get_first_child () != null) {
                extra_box.remove (extra_box.get_first_child ());
            }
            foreach (var extra in game.extras) {
                var label = new Gtk.Label (extra.short_title);
                label.set_tooltip_text (extra.title);
                label.set_halign (Gtk.Align.START);

                extra_box.append (label);
            }

            manual_image.set_visible (game.has_manual);

            region_grid.set_visible (game.regions.length () > 0);
            for (var i = 1; i <= 4; i++) {
                bool pair = (i % 2) == 0;
                int row = pair ? 1 : 0;
                int column = i > 2 ? 1 : 0;

                var image = (Gtk.Image) region_grid.get_child_at (column, row);
                image.clear ();
                image.set_visible (false);
            }
            int region_count = 0;
            Models.Region.load_flags.begin (game.regions, (region) => {
                region.download_flag.begin ((obj, res) => {
                    var downloaded = region.download_flag.end (res);

                    if (downloaded) {
                        region_count++;
                        if (region_count > 4)return;

                        bool pair = (region_count % 2) == 0;
                        int row = pair ? 1 : 0;
                        int column = region_count > 2 ? 1 : 0;

                        var image = (Gtk.Image) region_grid.get_child_at (column, row);
                        image.set_tooltip_text (region.title);
                        image.set_from_file (region.get_flag_path ());
                        image.set_visible (true);
                    }
                });
            });

            version_label.set_text ("v" + "%.2f".printf (game.medias.nth_data (0).version));
        }
    }
}