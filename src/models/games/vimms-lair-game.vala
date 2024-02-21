namespace RetroPlus.Models {
    public class VimmsLairGame : Game {
        public int id { get; private set; }
        public string system { get; set; }
        public List<Region> regions;
        public int max_players { get; set; }
        public bool removed { get; set; }
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

        public VimmsLairGame (int id, string system, string title, int manual_id, List<Extra> extras, List<Region> regions, Media media) {
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
            ;
            return @"https://vimm.net/manual/?p=details&id=$manual_id";
        }

        public override bool is_valid () {
            return medias.length () > 0;
        }

        public override async bool load () {
            if (loaded)return true;

            SourceFunc callback = load.callback;
            bool output = true;

            ThreadFunc<bool> run = () => {
                string res = "";
                if (!Utils.Web.get_request (get_url (), ref res)) {
                    return output = false;
                }

                var game = this;

                if (!Utils.VimmsLairParser.parse_game_request (res, ref game)) {
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

        public override async Utils.Web.DownloadResults download (string download_url, string download_directory, Utils.Web.download_cancel_callback download_cancel_callback, Utils.Web.download_progress_callback download_progress_callback, Utils.Web.download_speed_callback download_speed_callback) {
            return yield Utils.Web.download (download_url, download_directory, null, "https://vimm.net/", download_cancel_callback, download_progress_callback, download_speed_callback);
        }
    }
}