namespace RetroPlus.Widgets {
    public class GameDetailDialog : Adw.MessageDialog {
        public Models.Game game { get; construct; }
        public Adw.ApplicationWindow window { get; construct; }
        GLib.ListStore media_list_store { get; set; }
        Gtk.DropDown media_dropdown { get; set; }
        Gtk.Label crc_label { get; set; }
        Gtk.Label md5_label { get; set; }
        Gtk.Label sha1_label { get; set; }
        Gtk.Label download_size_label { get; set; }

        public signal void download_clicked (Models.Game game, Models.Media media);
        public signal void close_clicked ();

        public GameDetailDialog (Models.Game game) {
            Object (game: game);
        }

        construct {
            this.add_response ("close", _("Close"));
            this.set_response_appearance ("close", Adw.ResponseAppearance.DEFAULT);

            this.add_response ("download", _("Download"));
            this.set_response_appearance ("download", Adw.ResponseAppearance.SUGGESTED);

            //
            this.set_close_response ("close");

            //
            this.response.connect (on_response);

            //
            this.set_heading (game.title);

            //
            var carousel = new Adw.Carousel ();
            carousel.set_interactive (true);
            carousel.append (get_info_box ());
            if (game.rated)carousel.append (get_rating_box ());
            if (game.medias.nth_data (0).has_hash)carousel.append (get_hash_box ());

            //
            var carousel_indicator_dots = new Adw.CarouselIndicatorDots ();
            carousel_indicator_dots.set_carousel (carousel);

            //
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            box.append (carousel);
            box.append (carousel_indicator_dots);

            //
            this.set_extra_child (box);
        }

        void on_response (string response) {
            switch (response) {
            case "download":
                download_clicked (game, (Models.Media) media_dropdown.get_selected_item ());
                break;
            case "close":
                close_clicked ();
                break;
            }
        }

        Gtk.Box get_info_box () {
            var system_label = new Gtk.Label (_("System") + ": " + game.system);

            var region_label = new Gtk.Label (_("Region") + ": ");

            var flags_box = new Gtk.FlowBox ();
            flags_box.set_max_children_per_line (2);
            flags_box.set_halign (Gtk.Align.CENTER);
            flags_box.set_size_request (50, 0);
            flags_box.set_visible (game.regions.length () > 0);

            Models.Region.load_flags.begin (game.regions, (region) => {
                region.download_flag.begin ((obj, res) => {
                    var downloaded = region.download_flag.end (res);

                    if (downloaded) {
                        var image = new Gtk.Image.from_file (region.get_flag_path ());
                        image.set_tooltip_text (region.title);

                        flags_box.append (image);
                    }
                });
            });

            var region_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
            region_box.set_halign (Gtk.Align.CENTER);
            region_box.set_hexpand (true);
            region_box.append (region_label);
            region_box.append (flags_box);

            var players_label = new Gtk.Label (_("Players") + ": " + game.max_players.to_string () + (game.simultaneous ? " " + _("Simultaneous") : ""));

            var year_label = new Gtk.Label (_("Year") + ": " + (game.year.to_string ()));

            var publisher_label = new Gtk.Label (_("Publisher") + ": " + game.publisher);

            var serial_label = new Gtk.Label (_("Serial") + "#: " + game.serial);

            download_size_label = new Gtk.Label (_("Size") + ": " + game.medias.nth_data (0).get_formatted_download_size ());

            var media_label = new Gtk.Label (_("Version") + ": " + (game.medias.length () == 1 ? "%.2f".printf (game.medias.nth_data (0).version) : ""));

            //
            media_list_store = new GLib.ListStore (typeof (Models.Media));

            foreach (var media in game.medias) {
                media_list_store.append (media);
            }

            //
            var media_selection_model = new Gtk.SingleSelection (media_list_store);

            //
            var media_factory = new Gtk.SignalListItemFactory ();
            media_factory.bind.connect (media_factory_bind);
            media_factory.setup.connect (media_factory_setup);

            //
            media_dropdown = new Gtk.DropDown (media_selection_model, null);
            media_dropdown.set_factory (media_factory);
            media_dropdown.notify["selected-item"].connect (on_media_dropdown_selected_item_changed);

            //
            var media_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            media_box.set_halign (Gtk.Align.CENTER);
            media_box.append (media_label);
            if (game.medias.length () > 1)media_box.append (media_dropdown);

            var play_online_button = new Gtk.Button.with_label (_("Play online"));
            play_online_button.clicked.connect (on_play_online_button_clicked);

            var manual_button = new Gtk.Button.with_label (_("See manual"));
            manual_button.clicked.connect (on_manual_button_clicked);

            //
            var extra_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            extra_box.set_halign (Gtk.Align.CENTER);
            if (game.support_play_online)extra_box.append (play_online_button);
            if (game.has_manual)extra_box.append (manual_button);

            //
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            box.set_valign (Gtk.Align.CENTER);
            box.set_hexpand (true);
            box.append (system_label);
            box.append (region_box);
            if (game.has_max_players)box.append (players_label);
            if (game.has_year)box.append (year_label);
            if (game.has_publisher)box.append (publisher_label);
            if (game.has_serial)box.append (serial_label);
            box.append (download_size_label);
            box.append (media_box);
            if (game.support_play_online || game.has_manual)box.append (extra_box);

            //
            return box;
        }

        void on_play_online_button_clicked () {
            var uri_launcher = new Gtk.UriLauncher (game.get_play_online_url ());
            uri_launcher.launch.begin (window, null);
        }

        void on_manual_button_clicked () {
            var uri_launcher = new Gtk.UriLauncher (game.get_manual_url ());
            uri_launcher.launch.begin (window, null);
        }

        void media_factory_bind (Gtk.SignalListItemFactory factory, Object item) {
            Gtk.ListItem list_item = item as Gtk.ListItem;

            var media = list_item.get_item () as Models.Media;

            var title = list_item.get_data<Gtk.Label> ("title");
            title.label = "%.2f".printf (media.version);
        }

        void media_factory_setup (Gtk.SignalListItemFactory factory, Object item) {
            Gtk.ListItem list_item = item as Gtk.ListItem;

            var title = new Gtk.Label ("");

            list_item.set_data ("title", title);
            list_item.set_child (title);
        }

        void on_media_dropdown_selected_item_changed () {
            //
            var media = media_dropdown.get_selected_item () as Models.Media;

            if (media == null)return;

            crc_label.set_text (_("CRC") + ": " + media.crc);
            md5_label.set_text (_("MD5") + ": " + media.md5);
            sha1_label.set_text (_("SHA1") + ": " + media.sha1);

            download_size_label.set_text (_("Size") + ": " + media.get_formatted_download_size ());
        }

        Gtk.Box get_rating_box () {
            var graphics_rating_label = new Gtk.Label (_("Graphics") + ": " + "%.2f".printf (game.graphics_rating));

            var sound_rating_label = new Gtk.Label (_("Sound") + ": " + "%.2f".printf (game.sound_rating));

            var gameplay_rating_label = new Gtk.Label (_("Gameplay") + ": " + "%.2f".printf (game.gameplay_rating));

            var overall_rating_label = new Gtk.Label (_("Overall") + ": " + "%.2f".printf (game.overall_rating) + " (" + game.total_votes.to_string () + " " + (game.total_votes > 1 ? _("votes") : _("vote")) + ")");

            //
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            box.set_valign (Gtk.Align.CENTER);
            box.set_hexpand (true);
            box.append (graphics_rating_label);
            box.append (sound_rating_label);
            box.append (gameplay_rating_label);
            box.append (overall_rating_label);

            //
            return box;
        }

        Gtk.Box get_hash_box () {
            var last_verification_date_label = new Gtk.Label (_("Verified") + ": " + game.last_verification_date);
            last_verification_date_label.set_tooltip_text (game.last_verification_date);

            crc_label = new Gtk.Label (_("CRC") + ": " + game.medias.nth_data (0).crc);
            crc_label.set_tooltip_text (game.medias.nth_data (0).crc);

            md5_label = new Gtk.Label (_("MD5") + ": " + game.medias.nth_data (0).md5);
            md5_label.set_ellipsize (Pango.EllipsizeMode.END);
            md5_label.set_tooltip_text (game.medias.nth_data (0).md5);

            sha1_label = new Gtk.Label (_("SHA1") + ": " + game.medias.nth_data (0).sha1);
            sha1_label.set_ellipsize (Pango.EllipsizeMode.END);
            sha1_label.set_tooltip_text (game.medias.nth_data (0).sha1);

            //
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
            box.set_valign (Gtk.Align.CENTER);
            box.set_hexpand (true);
            box.append (last_verification_date_label);
            box.append (crc_label);
            box.append (md5_label);
            box.append (sha1_label);

            //
            return box;
        }
    }
}