namespace RetroPlus.Utils {
    public class Filesystem {
        public static bool GetFileContent (string path, ref string output) {
            try {
                File file = File.new_for_path (path);

                uint8[] contents;
                string etag_out;
                file.load_contents (null, out contents, out etag_out);

                output = (string) contents;

                return true;
            } catch (GLib.Error e) {
                message (e.message);
                return false;
            }
        }

        public static bool ModifyFile (string path, string content) {
            try {
                FileUtils.set_contents (path, content, content.length);
                return true;
            } catch (GLib.Error e) {
                message (e.message);
                return false;
            }
        }

        public static bool CreateFile (string path, string? content = null) {
            try {
                var file = GLib.File.new_for_path (path);
                FileOutputStream os = file.create (FileCreateFlags.PRIVATE);
                if (content != null)os.write (content.data);
                return true;
            } catch (GLib.Error e) {
                message (e.message);
                return false;
            }
        }

        public static bool CreateDirectory (string path) {
            try {
                var directory = GLib.File.new_for_path (path);
                directory.make_directory ();
                return true;
            } catch (GLib.Error e) {
                message (e.message);
                return false;
            }
        }

        public static Gdk.Pixbuf? GetPixbufFromFile (string path) {
            try {
                return new Gdk.Pixbuf.from_file (path);
            } catch (Error e) {
                // message (@"Failed loading image for $title ($id)");
                return null;
            }
        }
    }
}