namespace RetroPlus.Models {
    public abstract class Game : Object {
        public string title { get; internal set; }

        public virtual async bool load () {
            return true;
        }

        public abstract async Utils.Web.DownloadResults download (string download_url, string download_directory, Utils.Web.download_cancel_callback download_cancel_callback, Utils.Web.download_progress_callback download_progress_callback, Utils.Web.download_speed_callback download_speed_callback);

        public abstract bool is_valid ();
    }
}