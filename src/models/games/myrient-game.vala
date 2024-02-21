namespace RetroPlus.Models {
    public class MyrientGame : Game {
        public string file_size { get; set; }
        public string file_name { get; set; }

        public MyrientGame (string title, string file_size, string file_name) {
            this.title = title;
            this.file_size = file_size;
            this.file_name = file_name;
        }

        public string get_download_url (string system_path) {
            return @"https://myrient.erista.me/files/$system_path/$file_name";
        }

        public override bool is_valid () {
            return true;
        }

        public override async Utils.Web.DownloadResults download (string download_url, string download_directory, Utils.Web.download_cancel_callback download_cancel_callback, Utils.Web.download_progress_callback download_progress_callback, Utils.Web.download_speed_callback download_speed_callback) {
            var referer = download_url.substring (0, download_url.last_index_of_char ('/', 0)) + "/";

            return yield Utils.Web.download (download_url, download_directory, file_name, referer, download_cancel_callback, download_progress_callback, download_speed_callback);
        }
    }
}