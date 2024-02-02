namespace RetroPlus.Utils {
    public class Web {
        public static string get_user_agent () {
            return "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0";
        }

        public static bool get_request (string url, ref string res) {
            try {
                var session = new Soup.Session ();
                var message = new Soup.Message ("GET", url);
                session.set_user_agent (get_user_agent ());
                Bytes bytes = session.send_and_read (message);
                res = (string) bytes.get_data ();
                return true;
            } catch (GLib.Error e) {
                message (e.message);
                return false;
            }
        }
    }
}