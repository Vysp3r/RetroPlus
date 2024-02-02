namespace RetroPlus.Models {
    public class Game : Object {
        public int id { get; private set; }
        public string title { get; private set; }
        public string system { get; set; }
        public List<Region> regions;
        public int max_players { get; set; }
        public bool has_max_players {
            get {
                return max_players > 0;
            }
        }
        public bool simultaneous { get; set; }
        public int year { get; set; }
        public bool has_year {
            get {
                return year > 0;
            }
        }
        public string? publisher { get; set; }
        public bool has_publisher {
            get {
                return publisher != null;
            }
        }
        public string? serial { get; set; }
        public bool has_serial {
            get {
                return serial != null;
            }
        }
        public double graphics_rating { get; set; }
        public double sound_rating { get; set; }
        public double gameplay_rating { get; set; }
        public double overall_rating { get; set; }
        public int total_votes { get; set; }
        public bool rated { get; set; }
        public List<Media> medias;
        public string last_verification_date { get; set; }
        public bool support_play_online { get; set; }
        public bool missing { get; set; }
        public int manual_id { get; set; }
        public bool has_manual {
            get {
                return manual_id > 0;
            }
        }
        public List<Extra> extras;
        public bool loaded { get; set; }
        public string download_server { get; set; }

        public Game (int id, string title) {
            this.id = id;
            this.title = title;
        }

        public delegate bool download_cancel_callback ();

        public delegate void download_progress_callback (double progress);

        public delegate void download_speed_callback (double bytes);

        public Game.from_search (int id, string system, string title, int manual_id, List<Extra> extras, List<Region> regions, Media media) {
            this.id = id;
            this.system = system;
            this.title = title;
            this.manual_id = manual_id;

            this.medias.append (media);

            foreach (var extra in extras) {
                this.extras.append (extra);
            }

            foreach (var region in regions) {
                this.regions.append (region);
            }
        }

        public string get_url () {
            return @"https://vimm.net/vault/$id";
        }

        public string get_download_url (int media_id) {
            return @"$download_server?mediaId=$media_id";
        }

        public string get_rating_url () {
            return @"https://vimm.net/vault/?p=rating&id=$id";
        }

        public string get_play_online_url () {
            return @"https://vimm.net/vault/?p=play&id=$id";
        }

        public string get_screen_image_url () {
            return @"https://vimm.net/image.php?type=screen&id=$id";
        }

        public string get_box_image_url () {
            return @"https://vimm.net/image.php?type=box&id=$id";
        }

        public string get_manual_url () {
            return @"https://vimm.net/manual/?p=details&id=$manual_id";
        }

        public async bool load () {
            if (loaded)return true;

            SourceFunc callback = load.callback;
            bool output = true;

            ThreadFunc<bool> run = () => {
                string res = "";
                if (!Utils.Web.get_request (get_url (), ref res)) {
                    return output = false;
                }

                var game = this;

                if (!Utils.Parser.parse_game_request (res, ref game)) {
                    return output = false;
                }

                loaded = true;

                Idle.add ((owned) callback);
                return true;
            };
            new Thread<bool> ("game-load", (owned) run);

            yield;
            return output;
        }

        public enum DownloadResults {
            SUCCESS,
            FILE_EXISTS,
            ERROR
        }

        public async DownloadResults download (Models.Media media, download_cancel_callback download_cancel_callback, download_progress_callback download_progress_callback, download_speed_callback download_speed_callback) {
            try {
                var session = new Soup.Session ();
                session.set_user_agent (Utils.Web.get_user_agent ());

                var message = new Soup.Message ("GET", get_download_url (media.id));
                message.request_headers.append ("Accept-Encoding", "gzip, deflate, br");
                message.request_headers.append ("Referer", "https://vimm.net/");
                message.request_headers.append ("Sec-Fetch-Dest", "document");
                message.request_headers.append ("Sec-Fetch-Mode", "navigate");
                message.request_headers.append ("Sec-Fetch-Site", "same-site");
                message.request_headers.append ("Sec-Fetch-User", "?1");
                message.request_headers.append ("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8");

                var input_stream = yield session.send_async (message, GLib.Priority.DEFAULT, null);

                if (message.status_code != 200) {
                    GLib.message (message.reason_phrase);
                    return DownloadResults.ERROR;
                }

                string disposition;
                GLib.HashTable<string, string> params;
                message.response_headers.get_content_disposition (out disposition, out params);

                if (!params.contains ("filename"))return DownloadResults.ERROR;

                var path = Application.settings.get_string ("download-directory") + "/" + params.get ("filename");

                var file = GLib.File.new_for_path (path);

                if (file.query_exists ())return DownloadResults.FILE_EXISTS;

                FileOutputStream output_stream = yield file.create_async (FileCreateFlags.NONE, GLib.Priority.DEFAULT, null);

                const size_t chunk_size = 4096;
                ulong bytes_downloaded = 0;
                int64 total_bytes = message.response_headers.get_content_length ();
                uint64 last_update = GLib.get_real_time ();

                while (true) {
                    if (download_cancel_callback ()) {
                        if (file.query_exists ()) {
                            file.delete ();
                        }
                        break;
                    }

                    var chunk = yield input_stream.read_bytes_async (chunk_size);

                    if (chunk.get_size () == 0) {
                        break;
                    }

                    bytes_downloaded += output_stream.write (chunk.get_data ());

                    if (download_progress_callback != null) {
                        double progress = (bytes_downloaded * 1.0f) / (total_bytes * 1.0f);
                        download_progress_callback (progress);
                    }

                    if (download_speed_callback != null) {
                        var download_speed = (int) (((double) bytes_downloaded) / (double) (get_real_time () - last_update) * ((double) 1000000));
                        download_speed_callback (download_speed);
                    }
                }

                yield output_stream.close_async ();

                session.abort ();

                yield nap (2000);

                return DownloadResults.SUCCESS;
            } catch (GLib.Error e) {
                GLib.message (e.message);
                return DownloadResults.ERROR;
            }
        }

        async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
            GLib.Timeout.add (interval, () => {
                nap.callback ();
                return false;
              }, priority);
            yield;
        }
    }
}