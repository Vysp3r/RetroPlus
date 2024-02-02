namespace RetroPlus.Models {
    public class Media : Object {
        public int id;
        public double version;
        public string? crc;
        public string? md5;
        public string? sha1;
        public bool has_hash {
            get {
                return crc != null && md5 != null && sha1 != null;
            }
        }
        public double download_size;

        public string get_formatted_download_size () {
            if (download_size > 1048576) {
                return "%.2f GB".printf (download_size / 1048576);
            }

            if (download_size > 1024) {
                return "%.2f MB".printf (download_size / 1024);
            }

            return "%.2f KB".printf (download_size);
        }

        public Media (double version) {
            this.version = version;
        }

        public Media.extra (int id, double version, string? crc, string? md5, string? sha1, double download_size) {
            this.id = id;
            this.version = version;
            this.crc = crc;
            this.md5 = md5;
            this.sha1 = sha1;
            this.download_size = download_size;
        }
    }
}