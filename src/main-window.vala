namespace RetroPlus {
    public class MainWindow : Adw.ApplicationWindow {
        Gtk.Entry search_entry { get; set; }
        Widgets.SearchFilterBox search_filter_box { get; set; }
        ListStore game_list_store { get; set; }
        Gtk.GridView game_grid { get; set; }
        Gtk.Spinner spinner { get; set; }
        Widgets.DownloadPopover download_popover { get; set; }
        Adw.ToastOverlay toast_overlay { get; set; }
        Models.Source.get_games_by_title_result search_results;
        Gtk.Label system_label { get; set; }
        Gtk.Box legend_box { get; set; }
        Adw.StatusPage status_page { get; set; }

        construct {
            this.set_title (Constants.APP_NAME);
            this.set_size_request (410, 500);
            this.set_default_size (410, 500);

            var download_button = new Gtk.Button.from_icon_name ("download-symbolic");
            download_button.clicked.connect (on_download_button_clicked);

            download_popover = new Widgets.DownloadPopover ();
            download_popover.set_parent (download_button);
            download_popover.set_autohide (true);
            download_popover.download_finished.connect (on_download_finished);
            download_popover.download_cancelled.connect (on_download_cancelled);
            download_popover.download_error.connect (on_download_error);
            download_popover.download_file_exists.connect (on_download_file_exists);

            var menu_model = new GLib.Menu ();
            menu_model.append (_("Preferences"), "app.show-preferences");
            menu_model.append (_("Keyboard Shortcuts"), "win.show-help-overlay");
            menu_model.append (_("About RetroPlus"), "app.show-about");

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_icon_name ("open-menu-symbolic");
            menu_button.set_menu_model (menu_model);

            var header = new Adw.HeaderBar ();
            header.add_css_class ("flat");
            header.pack_start (download_button);
            header.pack_end (menu_button);

            search_entry = new Gtk.Entry ();
            search_entry.set_hexpand (true);
            search_entry.set_placeholder_text (_("Search a game by name"));
            search_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY, "search-symbolic");
            search_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "funnel-fill-symbolic");
            search_entry.set_icon_tooltip_text (Gtk.EntryIconPosition.SECONDARY, _("Advanced filtering options"));
            search_entry.icon_press.connect (on_search_entry_icon_pressed);
            search_entry.activate.connect (on_search_entry_activated);

            search_filter_box = new Widgets.SearchFilterBox ();
            search_filter_box.set_visible (false);
            search_filter_box.source_dropdown.notify["selected-item"].connect (on_source_dropdown_selected_item_changed);

            system_label = new Gtk.Label (_("System"));
            system_label.set_halign (Gtk.Align.CENTER);
            system_label.set_size_request (80, 0);

            var title_label = new Gtk.Label (_("Title"));
            title_label.set_halign (Gtk.Align.CENTER);
            title_label.set_hexpand (true);

            var region_label = new Gtk.Label (_("Region"));
            region_label.set_halign (Gtk.Align.CENTER);
            region_label.set_size_request (50, 0);

            var version_label = new Gtk.Label (_("Version"));
            version_label.set_halign (Gtk.Align.CENTER);
            version_label.set_size_request (55, 0);

            legend_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            legend_box.set_margin_start (10);
            legend_box.set_margin_end (12);
            legend_box.append (system_label);
            legend_box.append (title_label);
            legend_box.append (region_label);
            legend_box.append (version_label);

            game_list_store = new ListStore (typeof (Models.Game));

            var game_selection = new Gtk.SingleSelection (game_list_store);

            var game_factory = new Gtk.SignalListItemFactory ();
            game_factory.bind.connect (game_factory_bind);
            game_factory.setup.connect (game_factory_setup);

            game_grid = new Gtk.GridView (game_selection, game_factory);
            game_grid.set_single_click_activate (true);
            game_grid.set_hexpand (true);
            game_grid.add_css_class ("transparent-grid");
            game_grid.set_max_columns (1);
            game_grid.activate.connect (on_game_grid_activate);

            var scrolled_window = new Gtk.ScrolledWindow ();
            scrolled_window.set_propagate_natural_width (false);
            scrolled_window.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.set_vexpand (true);
            scrolled_window.set_child (game_grid);

            spinner = new Gtk.Spinner ();
            spinner.set_size_request (50, 50);
            spinner.set_halign (Gtk.Align.CENTER);
            spinner.set_valign (Gtk.Align.CENTER);

            status_page = new Adw.StatusPage ();
            status_page.set_description (_("Feels empty in here.\n"
                                           + "Why not search for a game?"));
            status_page.set_icon_name ("search-symbolic");
            status_page.set_valign (Gtk.Align.CENTER);

            var overlay = new Gtk.Overlay ();
            overlay.set_child (scrolled_window);
            overlay.add_overlay (spinner);
            overlay.add_overlay (status_page);

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
            box.append (search_entry);
            box.append (search_filter_box);
            box.append (legend_box);
            box.append (overlay);

            var clamp = new Adw.Clamp ();
            clamp.set_margin_start (10);
            clamp.set_margin_end (10);
            clamp.set_margin_bottom (10);
            clamp.set_maximum_size (820);
            clamp.set_child (box);

            toast_overlay = new Adw.ToastOverlay ();
            toast_overlay.set_child (clamp);

            var toolbar_view = new Adw.ToolbarView ();
            toolbar_view.add_top_bar (header);
            toolbar_view.set_content (toast_overlay);

            this.set_content (toolbar_view);
        }

        public void initialize (Gee.Iterator<Models.Source> sources) {
            search_filter_box.initialize (sources);
        }

        void game_factory_bind (Gtk.SignalListItemFactory factory, Object object) {
            var list_item = object as Gtk.ListItem;

            var game = list_item.get_item () as Models.Game;

            var system = search_filter_box.system_dropdown.get_selected_item () as Models.System;

            var row = list_item.get_data<Widgets.SearchRow> ("row");
            row.initialize (game, system.path == "");
        }

        void game_factory_setup (Gtk.SignalListItemFactory factory, Object object) {
            var list_item = object as Gtk.ListItem;

            var row = new Widgets.SearchRow ();

            list_item.set_data ("row", row);
            list_item.set_child (row);
        }

        void on_download_button_clicked () {
            download_popover.popup ();
        }

        void on_search_entry_activated () {
            if (status_page.get_visible ())status_page.set_visible (false);

            spinner.start ();

            game_grid.set_sensitive (false);

            search_entry.set_sensitive (false);

            game_list_store.remove_all ();

            var system = search_filter_box.system_dropdown.get_selected_item () as Models.System;

            system_label.set_visible (system.path == "");

            var source = search_filter_box.source_dropdown.get_selected_item () as Models.Source;

            legend_box.set_visible (source.title == "Vimm's Lair");

            string request_url = null;

            switch (source.title) {
            case "Vimm's Lair":
                request_url = Models.Source.get_vimms_lair_request_url (system.path, search_entry.get_text ());
                break;
            case "Myrient":
                request_url = Models.Source.get_myrient_request_url (system.path, search_entry.get_text ());
                break;
            }

            source.get_games_by_title.begin (request_url, (obj, res) => {
                search_results = source.get_games_by_title.end (res);

                if (search_results.request_error) {
                    status_page.set_icon_name ("wifi-off-symbolic");
                    status_page.set_description (_("Can't reach the servers.\n"
                                                   + "Please report this on our GitHub if you think this is a bug."));
                    status_page.set_visible (true);
                } else if (search_results.parsing_error) {
                    status_page.set_icon_name ("bug-symbolic");
                    status_page.set_description (_("An unknown error occurred.\n"
                                                   + "Please report this on our GitHub."));
                    status_page.set_visible (true);
                } else if (search_results.games == null) {
                    status_page.set_icon_name ("emoji-frown-symbolic");
                    status_page.set_description (_("Nothing found, try searching again."));
                    status_page.set_visible (true);
                } else {
                    foreach (var game in search_results.games) {
                        game_list_store.append (game);
                    }
                }

                spinner.stop ();

                game_grid.set_sensitive (true);

                search_entry.set_sensitive (true);
            });
        }

        void on_search_entry_icon_pressed (Gtk.EntryIconPosition entry_icon_position) {
            if (entry_icon_position == Gtk.EntryIconPosition.SECONDARY)search_filter_box.set_visible (!search_filter_box.get_visible ());
        }

        void on_game_grid_activate (uint position) {
            var game = search_results.games.nth_data (position);

            if (game == null)return;

            spinner.start ();

            game_grid.set_sensitive (false);

            search_entry.set_sensitive (false);

            game.load.begin ((obj, res) => {
                var error = !game.load.end (res);

                spinner.stop ();

                game_grid.set_sensitive (true);

                search_entry.set_sensitive (true);

                if (!error) {
                    if (game.is_valid ()) {
                        if (game is Models.VimmsLairGame) {
                            var vimms_lair_game_detail_dialog = new Widgets.VimmsLairGameDetailDialog (game as Models.VimmsLairGame); // TODO Add init instead of passing to be able to re-use the widget
                            vimms_lair_game_detail_dialog.set_transient_for (this);
                            vimms_lair_game_detail_dialog.download_clicked.connect (on_download_started);
                            vimms_lair_game_detail_dialog.present ();
                        } else if (game is Models.MyrientGame) {
                            var system = (Models.System) search_filter_box.system_dropdown.get_selected_item ();
                            var myrient_game_detail_dialog = new Widgets.MyrientGameDetailDialog ();
                            myrient_game_detail_dialog.set_transient_for (this);
                            myrient_game_detail_dialog.download_clicked.connect (on_download_started);
                            myrient_game_detail_dialog.initialize (game as Models.MyrientGame, system.path);
                            myrient_game_detail_dialog.present ();
                        }
                    } else {
                        error = true;
                    }
                }

                if (error) {
                    var toast = new Adw.Toast (_("An error occured while opening %s").printf (game.title));

                    toast_overlay.add_toast (toast);
                }
            });
        }

        void on_source_dropdown_selected_item_changed () {
            var source = (Models.Source) search_filter_box.source_dropdown.get_selected_item ();

            switch (source.title) {
            case "Vimm's Lair":
                break;
            }
        }

        void on_download_started (Models.Game game, string download_url) {
            Models.System system = null;

            if (game is Models.VimmsLairGame) {
                var source = (Models.Source) search_filter_box.source_dropdown.get_selected_item ();
                var vimms_lair_game = (Models.VimmsLairGame) game;
                system = source.systems.get (vimms_lair_game.system);

                // TODO Find a better solution then this to display that
                if (vimms_lair_game.missing || vimms_lair_game.removed) {
                    var toast = new Adw.Toast (_("%s is currently missing/unavailable").printf (game.title));
                    toast_overlay.add_toast (toast);

                    return;
                }
            } else {
                system = (Models.System) search_filter_box.system_dropdown.get_selected_item ();
            }

            if (system == null) {
                on_download_error (game);
                return;
            }

            download_popover.add_download (game, download_url, Application.settings.get_string (system.download_directory_setting_name ()));

            var toast = new Adw.Toast (_("%s download queued").printf (game.title));
            toast_overlay.add_toast (toast);
        }

        void on_download_finished (Models.Game game) {
            var toast = new Adw.Toast (_("%s finished downloading").printf (game.title));
            toast_overlay.add_toast (toast);
        }

        void on_download_cancelled (Models.Game game) {
            var toast = new Adw.Toast (_("%s download cancelled").printf (game.title));
            toast_overlay.add_toast (toast);
        }

        void on_download_error (Models.Game game) {
            var toast = new Adw.Toast (_("%s could not download due to an error").printf (game.title));
            toast_overlay.add_toast (toast);
        }

        void on_download_file_exists (Models.Game game) {
            var toast = new Adw.Toast (_("%s is already downloaded").printf (game.title));
            toast_overlay.add_toast (toast);
        }
    }
}