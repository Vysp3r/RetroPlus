namespace RetroPlus.Widgets {
    public class DownloadPopover : Gtk.Popover {
        Gtk.ListBox download_list { get; set; }

        public signal void download_cancelled (Models.Game game);

        public signal void download_finished (Models.Game game);

        public signal void download_error (Models.Game game);

        public signal void download_file_exists (Models.Game game);

        construct {
            //
            var placeholder_label = new Gtk.Label (_("No download in progress"));
            placeholder_label.add_css_class ("p-10");

            //
            download_list = new Gtk.ListBox ();
            download_list.set_placeholder (placeholder_label);
            download_list.set_vexpand (true);
            download_list.add_css_class ("boxed-list");
            download_list.set_selection_mode (Gtk.SelectionMode.NONE);

            //
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.append (download_list);

            //
            this.set_child (box);
        }

        public void add_download (Models.Game game, Models.Media media) {
            //
            var cancelled = false;

            //
            var row = new DownloadRow (game);

            //
            row.cancel_button.clicked.connect (() => {
                //
                row.set_cancelling ();

                //
                cancelled = true;

                //
                var previous_row = download_list.get_row_at_index (0) as DownloadRow;

                //
                download_list.remove (row);

                //
                download_cancelled (game);

                //
                var first_row = download_list.get_row_at_index (0) as DownloadRow;
                if (first_row != null && previous_row == row) {
                    first_row.start_download ();
                }
            });

            //
            row.start_download.connect (() => {
                //
                row.set_starting ();

                //
                game.download.begin (media, () => cancelled, row.set_progress, row.set_download_speed, (obj, res) => {
                    //
                    var download_result = game.download.end (res);

                    //
                    if (cancelled)return;

                    //
                    download_list.remove (row);

                    //
                    switch (download_result) {
                        case Models.Game.DownloadResults.SUCCESS:
                            download_finished (game);
                            break;
                        case Models.Game.DownloadResults.FILE_EXISTS:
                            download_file_exists (game);
                            break;
                        case Models.Game.DownloadResults.ERROR:
                            download_error (game);
                            break;
                    }

                    //
                    var first_row = download_list.get_row_at_index (0) as DownloadRow;
                    if (first_row != null) {
                        first_row.start_download ();
                    }
                });
            });

            //
            download_list.append (row);

            //
            var first_row = download_list.get_row_at_index (0) as DownloadRow;
            if (first_row == row) {
                first_row.start_download ();
            }
        }
    }
}