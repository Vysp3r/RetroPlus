namespace RetroPlus.Models {
    public class Region : Object {
        public string title;
        string flag_filename;

        public delegate void flag_callback (Models.Region region);

        public Region (string title, string flag_filename) {
            this.title = title;
            this.flag_filename = flag_filename;
        }

        public string get_flag_url () {
            return @"https://vimm.net/images/flags/$flag_filename";
        }

        public string get_flag_path () {
            return get_flags_location () + flag_filename;
        }

        public async bool download_flag () {
            try {
                if (FileUtils.test (get_flag_path (), GLib.FileTest.EXISTS))return true;

                var session = new Soup.Session ();
                session.set_user_agent (Utils.Web.get_user_agent ());

                var message = new Soup.Message ("GET", get_flag_url ());

                var input_stream = session.send (message, null);

                if (message.status_code != 200) {
                    GLib.message (message.reason_phrase);
                    return false;
                }

                var file = GLib.File.new_for_path (get_flag_path ());

                FileOutputStream output_stream = file.create (FileCreateFlags.REPLACE_DESTINATION, null);

                const size_t chunk_size = 4096;
                ulong bytes_downloaded = 0;

                while (true) {
                    var chunk = input_stream.read_bytes (chunk_size);

                    if (chunk.get_size () == 0) {
                        break;
                    }

                    bytes_downloaded += output_stream.write (chunk.get_data ());
                }

                output_stream.close ();

                session.abort ();

                return true;
            } catch (GLib.Error e) {
                GLib.message (e.message);
                return false;
            }
        }

        public static async void load_flags (List<Models.Region> regions, flag_callback flag_callback) {
            foreach (var region in regions) {
                flag_callback (region);
            }
        }

        public static string get_flags_location () {
            return Environment.get_user_data_dir () + @"/flags/";
        }

        public static bool initialize () {
            //
            if (!FileUtils.test (get_flags_location (), FileTest.IS_DIR)) {
                bool flags_valid = Utils.Filesystem.CreateDirectory (get_flags_location ());
                if (!flags_valid)return false;
            }

            //
            return true;
        }
    }
}