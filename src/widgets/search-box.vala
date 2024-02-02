namespace RetroPlus.Widgets {
    public class SearchBox : Gtk.Box {
        Gtk.Entry search_entry { get; set; }
        public SearchFilterBox search_filter_box { get; construct; }
        Gtk.ListBox games_list { get; set; }
        Gtk.Spinner spinner { get; set; }
        DownloadPopover download_popover { get; set; }
        Adw.ToastOverlay toast_overlay { get; set; }
        List<Models.Game> search_results;
        Gtk.Label system_label { get; set; }

        public SearchBox (SearchFilterBox search_filter_box) {
            Object (search_filter_box: search_filter_box);
        }

        construct {
            //
            this.set_orientation (Gtk.Orientation.VERTICAL);

            //
            var download_button = new Gtk.Button.from_icon_name ("download-symbolic");
            download_button.clicked.connect (on_download_button_clicked);

            //
            download_popover = new DownloadPopover ();
            download_popover.set_parent (download_button);
            download_popover.set_autohide (true);
            download_popover.download_finished.connect (on_download_finished);
            download_popover.download_cancelled.connect (on_download_cancelled);
            download_popover.download_error.connect (on_download_error);
            download_popover.download_file_exists.connect (on_download_file_exists);

            //
            var menu_model = new GLib.Menu ();
            menu_model.append (_("Preferences"), "app.show-preferences");
            menu_model.append (_("Keyboard Shortcuts"), "win.show-help-overlay");
            menu_model.append (_("About"), "app.show-about");

            //
            var menu_button = new Gtk.MenuButton ();
            menu_button.set_icon_name ("open-menu-symbolic");
            menu_button.set_menu_model (menu_model);

            //
            var header = new Adw.HeaderBar ();
            header.add_css_class ("flat");
            header.pack_start (download_button);
            header.pack_end (menu_button);

            //
            search_entry = new Gtk.Entry ();
            search_entry.set_hexpand (true);
            search_entry.set_placeholder_text (_("Search a game by name"));
            search_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY, "search-symbolic");
            search_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "funnel-fill-symbolic");
            search_entry.set_icon_tooltip_text (Gtk.EntryIconPosition.SECONDARY, _("Advanced filtering options"));
            search_entry.icon_press.connect (on_search_entry_icon_pressed);
            search_entry.activate.connect (on_search_entry_activated);

            //
            search_filter_box.set_visible (false);

            //
            system_label = new Gtk.Label (_("System"));
            system_label.set_halign (Gtk.Align.CENTER);
            system_label.set_size_request (80, 0);

            //
            var title_label = new Gtk.Label (_("Title"));
            title_label.set_halign (Gtk.Align.CENTER);
            title_label.set_hexpand (true);

            //
            var region_label = new Gtk.Label (_("Region"));
            region_label.set_halign (Gtk.Align.CENTER);
            region_label.set_size_request (50, 0);

            //
            var version_label = new Gtk.Label (_("Version"));
            version_label.set_halign (Gtk.Align.CENTER);
            version_label.set_size_request (55, 0);

            //
            var legend_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            legend_box.set_margin_start (10);
            legend_box.set_margin_end (12);
            legend_box.append (system_label);
            legend_box.append (title_label);
            legend_box.append (region_label);
            legend_box.append (version_label);

            //
            games_list = new Gtk.ListBox ();
            games_list.set_activate_on_single_click (false);
            games_list.set_selection_mode (Gtk.SelectionMode.SINGLE);
            games_list.add_css_class ("boxed-list");
            games_list.set_hexpand (true);
            games_list.row_selected.connect (on_game_list_row_selected);

            //
            var scrolled_window = new Gtk.ScrolledWindow ();
            scrolled_window.set_propagate_natural_width (false);
            scrolled_window.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.set_vexpand (true);
            scrolled_window.set_child (games_list);

            //
            spinner = new Gtk.Spinner ();
            spinner.set_size_request (50, 50);
            spinner.set_halign (Gtk.Align.CENTER);
            spinner.set_valign (Gtk.Align.CENTER);

            //
            var overlay = new Gtk.Overlay ();
            overlay.set_child (scrolled_window);
            overlay.add_overlay (spinner);

            //
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
            box.append (search_entry);
            box.append (search_filter_box);
            box.append (legend_box);
            box.append (overlay);

            //
            var clamp = new Adw.Clamp ();
            clamp.set_margin_start (10);
            clamp.set_margin_end (10);
            clamp.set_margin_bottom (10);
            clamp.set_maximum_size (820);
            clamp.set_child (box);

            //
            toast_overlay = new Adw.ToastOverlay ();
            toast_overlay.set_child (clamp);

            //
            this.append (header);
            this.append (toast_overlay);
        }

        void on_download_button_clicked () {
            download_popover.popup ();
        }

        void on_search_entry_activated () {
            //
            spinner.start ();

            //
            games_list.set_sensitive (false);

            //
            search_entry.set_sensitive (false);

            //
            games_list.remove_all ();

            //
            var system = search_filter_box.system_dropdown.get_selected_item () as Models.System;

            //
            system_label.set_visible (system.id == "");

            //
            system.get_games_by_title.begin (search_entry.get_text (), (obj, res) => {
                //
                search_results = system.get_games_by_title.end (res);

                //
                foreach (var game in search_results) {
                    //
                    var row = new SearchRow (game, system.id == "");

                    //
                    games_list.append (row);
                }

                //
                spinner.stop ();

                //
                games_list.set_sensitive (true);

                //
                search_entry.set_sensitive (true);
            });
        }

        void on_search_entry_icon_pressed (Gtk.EntryIconPosition entry_icon_position) {
            if (entry_icon_position == Gtk.EntryIconPosition.SECONDARY)search_filter_box.set_visible (!search_filter_box.get_visible ());
        }

        void on_game_list_row_selected (Gtk.ListBoxRow? row) {
            //
            if (row == null)return;

            //
            var game = search_results.nth_data (row.get_index ());

            //
            if (game == null)return;

            //
            spinner.start ();

            //
            games_list.set_sensitive (false);

            //
            search_entry.set_sensitive (false);

            //
            game.load.begin ((obj, res) => {
                //
                var error = !game.load.end (res);

                //
                spinner.stop ();

                //
                games_list.set_sensitive (true);

                //
                search_entry.set_sensitive (true);

                //
                if (!error) {
                    if (game.medias.length () > 0) {
                        var game_detail_modal = new GameDetailModal (game);
                        game_detail_modal.download_clicked.connect (on_download_started);
                        game_detail_modal.show ();
                    } else {
                        error = true;
                    }
                }

                //
                if (error) {
                    var toast = new Adw.Toast (_("An error occured while opening") + " " + game.title);

                    toast_overlay.add_toast (toast);
                }
            });
        }

        void on_download_started (Models.Game game, Models.Media media) {
            download_popover.add_download (game, media);

            var toast = new Adw.Toast (game.title + " " + _("download queued"));

            toast_overlay.add_toast (toast);
        }

        void on_download_finished (Models.Game game) {
            var toast = new Adw.Toast (game.title + " " + _("finished downloading"));

            toast_overlay.add_toast (toast);
        }

        void on_download_cancelled (Models.Game game) {
            var toast = new Adw.Toast (game.title + " " + _("download cancelled"));

            toast_overlay.add_toast (toast);
        }

        void on_download_error (Models.Game game) {
            var toast = new Adw.Toast (game.title + " " + _("could not download due to an error"));

            toast_overlay.add_toast (toast);
        }

        void on_download_file_exists (Models.Game game) {
            var toast = new Adw.Toast (game.title + " " + _(" is already downloaded"));

            toast_overlay.add_toast (toast);
        }
    }
}