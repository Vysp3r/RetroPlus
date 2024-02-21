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

        public delegate bool download_cancel_callback ();

        public delegate void download_progress_callback (double progress);

        public delegate void download_speed_callback (double bytes);

        public enum DownloadResults {
            SUCCESS,
            FILE_EXISTS,
            ERROR
        }

        public static async DownloadResults download (string download_url, string download_directory, string? file_name, string referer, download_cancel_callback download_cancel_callback, download_progress_callback download_progress_callback, download_speed_callback download_speed_callback) {
            try {
                var session = new Soup.Session ();
                session.set_user_agent (Utils.Web.get_user_agent ());

                var message = new Soup.Message ("GET", download_url);
                message.request_headers.append ("Accept-Encoding", "gzip, deflate, br");
                message.request_headers.append ("Referer", referer);
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

                string path = download_directory + "/";

                if (file_name == null) {
                    string disposition;
                    GLib.HashTable<string, string> params;
                    message.response_headers.get_content_disposition (out disposition, out params);

                    if (!params.contains ("filename"))return DownloadResults.ERROR;

                    path += params.get ("filename");
                } else {
                    path += file_name;
                }

                var file = GLib.File.new_for_path (path);

                if (file.query_exists ()) {
                    return DownloadResults.FILE_EXISTS;
                }

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

        static async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
            GLib.Timeout.add (interval, () => {
                nap.callback ();
                return false;
            }, priority);
            yield;
        }
    }
}