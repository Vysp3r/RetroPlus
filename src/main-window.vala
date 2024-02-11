namespace RetroPlus {
    public class MainWindow : Adw.ApplicationWindow {
        Gtk.Entry search_entry { get; set; }
        Widgets.SearchFilterBox search_filter_box { get; set; }
        Gtk.ListBox games_list { get; set; }
        Gtk.Spinner spinner { get; set; }
        Widgets.DownloadPopover download_popover { get; set; }
        Adw.ToastOverlay toast_overlay { get; set; }
        Models.System.get_games_by_title_result search_results;
        Gtk.Label system_label { get; set; }
        Adw.StatusPage status_page { get; set; }

        construct {
            //
            this.set_title (Constants.APP_NAME);
            this.set_size_request (410, 500);
            this.set_default_size (410, 500);

            //
            var download_button = new Gtk.Button.from_icon_name ("download-symbolic");
            download_button.clicked.connect (on_download_button_clicked);

            //
            download_popover = new Widgets.DownloadPopover ();
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
            //Translators: Do not translate the application name
            menu_model.append (_("About RetroPlus"), "app.show-about");

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
            search_filter_box = new Widgets.SearchFilterBox ();
            search_filter_box.set_visible (false);
            search_filter_box.source_dropdown.notify["selected-item"].connect (on_source_dropdown_selected_item_changed);

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
            status_page = new Adw.StatusPage ();
            status_page.set_description (_("Feels empty in here.") + "\n" + _("Why not search for a game?"));
            status_page.set_icon_name ("search-symbolic");
            status_page.set_valign (Gtk.Align.CENTER);

            //
            var overlay = new Gtk.Overlay ();
            overlay.set_child (scrolled_window);
            overlay.add_overlay (spinner);
            overlay.add_overlay (status_page);

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
            var toolbar_view = new Adw.ToolbarView ();
            toolbar_view.add_top_bar (header);
            toolbar_view.set_content (toast_overlay);

            //
            this.set_content (toolbar_view);
        }

        public void initialize (Gee.Iterator<Models.Source> sources, Gee.Iterator<Models.System> systems) {
            search_filter_box.initialize (sources, systems);
        }

        void on_download_button_clicked () {
            download_popover.popup ();
        }

        void on_search_entry_activated () {
            //
            if (status_page.get_visible ())status_page.set_visible (false);

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
                if (search_results.request_error) {
                    status_page.set_icon_name ("wifi-off-symbolic");
                    status_page.set_description (_("Can't reach the servers.") + "\n" + _("Please report this on our GitHub if you think this is a bug."));
                    status_page.set_visible (true);
                } else if (search_results.parsing_error) {
                    status_page.set_icon_name ("bug-symbolic");
                    status_page.set_description (_("An unknown error occurred.") + "\n" + _("Please report this on our GitHub."));
                    status_page.set_visible (true);
                } else if (search_results.games == null) {
                    status_page.set_icon_name ("emoji-frown-symbolic");
                    status_page.set_description (_("Nothing found, try searching again."));
                    status_page.set_visible (true);
                } else {
                    foreach (var game in search_results.games) {
                        //
                        var row = new Widgets.SearchRow (game, system.id == "");

                        //
                        games_list.append (row);
                    }
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
            var game = search_results.games.nth_data (row.get_index ());

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
                        var game_detail_modal = new Widgets.GameDetailDialog (game); // TODO Add init instead of passing
                        game_detail_modal.set_transient_for (this);
                        game_detail_modal.download_clicked.connect (on_download_started);
                        game_detail_modal.present ();
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

        void on_source_dropdown_selected_item_changed () {
            var source = (Models.Source) search_filter_box.source_dropdown.get_selected_item ();

            switch (source.title) {
            case "Vimm's Lair" :
                break;
            }
        }

        void on_download_started (Models.Game game, Models.Media media) {
            var system = Application.systems.get (game.system);

            if (system == null) {
                on_download_error (game);
                return;
            }

            download_popover.add_download (game, media, system);

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