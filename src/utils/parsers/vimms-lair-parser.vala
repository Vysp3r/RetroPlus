namespace RetroPlus.Utils {
    public class VimmsLairParser : Parser {
        public override bool parse_search_request (string html, ref List<Models.Game> games) {
            if (html.length == 0)return false;
            if (html.contains ("No matches found."))return true;

            var start_text = "</caption>";
            var start = html.index_of (start_text, html.index_of (start_text) + start_text.length);

            var end_text = "</table>";
            var end = html.index_of (end_text, start);

            var temp_list = html.substring (start + start_text.length, html.length - start - start_text.length - (html.length - end));

            var context = new Html.ParserCtxt ();
            var doc = context.read_memory (temp_list.to_utf8 (), temp_list.length, "", "UTF-8", Html.ParserOption.NOERROR);

            if (doc == null) {
                warning ("Error parsing HTML");
                return false;
            }

            var root_node = doc->get_root_element ();

            var game_nodes = new List<Xml.Node*> ();
            process_node_by_name ("tr", root_node, ref game_nodes);

            foreach (var node in game_nodes) {
                var td_nodes = new List<Xml.Node*> ();
                var a_nodes = new List<Xml.Node*> ();
                var img_nodes = new List<Xml.Node*> ();
                var b_nodes = new List<Xml.Node*> ();

                process_node_by_name ("td", node, ref td_nodes);
                process_node_by_name ("a", node, ref a_nodes);
                process_node_by_name ("img", node, ref img_nodes);
                process_node_by_name ("b", node, ref b_nodes);

                // Process System
                var system_name = "";
                foreach (var td_node in td_nodes) {
                    system_name = td_node->get_content ();
                    break;
                }

                // Process ID
                var id = -1;
                var raw_id = "";
                Xml.Node* id_node = null;
                foreach (var a_node in a_nodes) {
                    raw_id = a_node->get_prop ("href");
                    if (raw_id ? .contains ("/vault/")) {
                        raw_id = raw_id.replace ("/vault/", "");
                        if (int.try_parse (raw_id, out id)) {
                            id_node = a_node;
                        }
                        break;
                    }
                }
                if (id == -1) {
                    warning (@"Failed parsing the following id: $raw_id");
                    continue;
                }

                // Process Title
                if (id_node == null) {
                    warning (@"Failed finding the title of a game");
                    continue;
                }
                string title = id_node->get_content ();

                // Process Manual ID
                var manual_id = -1;
                var raw_manual_id = "";
                foreach (var a_node in a_nodes) {
                    raw_manual_id = a_node->get_prop ("href");
                    if (raw_manual_id ? .contains ("/manual/")) {
                        raw_manual_id = raw_manual_id.replace ("/manual/", "");
                        int.try_parse (raw_manual_id, out manual_id);
                        break;
                    }
                }

                // Process Extra
                var extra_list = new GLib.List<Models.Extra> ();
                var extra_title = "";
                var extra_short_title = "";
                Models.Extra extra = null;
                foreach (var b_node in b_nodes) {
                    extra_title = b_node->get_prop ("title");
                    extra_short_title = b_node->get_content ();
                    extra = new Models.Extra (extra_title, extra_short_title);
                    extra_list.append (extra);
                }

                // Process Media
                var version = -1.0d;
                Models.Media media = null;
                foreach (var td_node in td_nodes) {
                    if (double.try_parse (td_node->get_content (), out version)) {
                        media = new Models.Media (version);
                        break;
                    }
                }
                if (media == null) {
                    warning (@"Failed finding the version of a game");
                    continue;
                }

                // Process Region
                var region_list = new GLib.List<Models.Region> ();
                var region_title = "";
                var flag_filename = "";
                Models.Region region = null;
                foreach (var img_node in img_nodes) {
                    flag_filename = img_node->get_prop ("src");
                    if (flag_filename ? .contains ("/flags/")) {
                        flag_filename = flag_filename.replace ("/images/flags/", "");
                        region_title = img_node->get_prop ("title");
                        region = new Models.Region (region_title, flag_filename);
                        region_list.append (region);
                    }
                }

                // Create game
                var game = new Models.VimmsLairGame (id, system_name, title, manual_id, extra_list, region_list, media);

                // Append the game to the game list
                games.append (game);
            }

            free (doc);

            return true;
        }

        public static bool parse_game_request (string html, ref Models.VimmsLairGame game) {
            if (game.missing = html.contains ("This game is not currently in The Vault.")) {
                return true;
            }

            var context = new Html.ParserCtxt ();
            var doc = context.read_memory (html.to_utf8 (), html.length, "", "UTF-8", Html.ParserOption.NOERROR);

            if (doc == null) {
                warning ("Error parsing HTML");
                return false;
            }

            var root_node = doc->get_root_element ();

            var td_nodes = new List<Xml.Node*> ();
            process_node_by_name ("td", root_node, ref td_nodes);

            Xml.Node* data_node = null;
            foreach (var td_node in td_nodes) {
                if (td_node->get_content () == "Region") {
                    data_node = td_node->parent->parent;
                    break;
                }
            }
            if (data_node == null) {
                return false;
            }

            game.rated = !html.contains ("Rating");

            var tr_nodes = new List<Xml.Node*> ();
            process_node_by_name ("tr", data_node, ref tr_nodes);

            foreach (var tr_node in tr_nodes) {
                var nodes = new List<Xml.Node*> ();
                process_node_by_name (null, tr_node, ref nodes);

                var content = tr_node->get_content ().strip ();

                if (content.contains ("Download unavailable by request of")) {
                    game.removed = true;
                }

                foreach (var node in nodes) {
                    if (tr_node->get_prop ("id") == "row-date" && game.last_verification_date == null) {
                        if (node->get_prop ("id") == "data-date") {
                            game.last_verification_date = node->get_content ();
                        }
                    }
                    if (node->name == "form" && node->get_prop ("action").contains ("download")) {
                        game.download_server = "https:" + node->get_prop ("action");
                    }
                }


                if (tr_node->last_element_child ()->get_prop ("id") == "serials") {
                    game.serial = tr_node->last_element_child ()->get_content ();
                }

                if (content.contains ("Publisher")) {
                    game.publisher = content.replace ("Publisher", "");
                }

                if (content.contains ("Year")) {
                    var raw_year = content.replace ("Year", "");
                    var year = -1;
                    if (int.try_parse (raw_year, out year)) {
                        game.year = year;
                    }
                }

                if (content.contains ("Players")) {
                    var raw_max_players = content.replace ("Players", "").strip ();

                    if (game.simultaneous = raw_max_players.contains ("Simultaneous")) {
                        raw_max_players = raw_max_players.replace ("Simultaneous", "").strip ();
                    }

                    var max_players = -1;
                    if (int.try_parse (raw_max_players, out max_players)) {
                        game.max_players = max_players;
                    }
                }

                if (game.rated) {
                    if (game.rated && content.contains ("Graphics")) {
                        var rating = -1.0d;
                        if (double.try_parse (content.replace ("Graphics", ""), out rating)) {
                            game.graphics_rating = rating;
                        }
                    }

                    if (game.rated && content.contains ("Sound")) {
                        var rating = -1.0d;
                        if (double.try_parse (content.replace ("Sound", ""), out rating)) {
                            game.sound_rating = rating;
                        }
                    }

                    if (game.rated && content.contains ("Gameplay")) {
                        var rating = -1.0d;
                        if (double.try_parse (content.replace ("Gameplay", ""), out rating)) {
                            game.gameplay_rating = rating;
                        }
                    }

                    if (game.rated && content.contains ("Overall")) {
                        content = content.split (")")[0];

                        var list = content.split ("(");

                        var rating = -1.0d;
                        if (double.try_parse (list[0].replace ("Overall", "").replace (" ", "").strip (), out rating)) {
                            game.overall_rating = rating;
                        }

                        var votes = -1;
                        if (int.try_parse (list[1].split ("v")[0].replace (" ", "").strip (), out votes)) {
                            game.total_votes = votes;
                        }
                    }
                }
            }

            // Find if the game support play online
            game.support_play_online = html.contains ("Play Online");

            // Find all the available versions
            var start_text = "var allMedia = [];";
            var start = html.index_of (start_text);

            var end_text = "document.addEventListener";
            var end = html.index_of (end_text, start);

            var medias_text = html.substring (start + start_text.length, html.length - start - start_text.length - (html.length - end));
            var medias_text_split = medias_text.split ("allMedia.push(media);");

            while (game.medias.length () > 0) {
                game.medias.remove (game.medias.nth_data (0));
            }

            for (var i = 0; i < medias_text_split.length; i++) {
                //
                if (i == medias_text_split.length - 1)break;

                //
                var line = medias_text_split[i];

                //
                start_text = "ID\":";
                start = line.index_of (start_text, 0);

                end_text = ",";
                end = line.index_of (end_text, start);

                var raw_id = line.substring (start + start_text.length, line.length - start - start_text.length - (line.length - end));

                int id;
                if (!int.try_parse (raw_id, out id)) {
                    warning (@"Unable to parse the id ($raw_id)");
                    return false;
                }

                //
                start_text = "Version\":\"";
                start = line.index_of (start_text, 0);

                end_text = "\",";
                end = line.index_of (end_text, start);

                var raw_version = line.substring (start + start_text.length, line.length - start - start_text.length - (line.length - end));

                double version;
                if (!double.try_parse (raw_version, out version)) {
                    warning (@"Unable to parse the version ($raw_version)");
                    return false;
                }

                //
                start_text = "Zipped\":\"";
                start = line.index_of (start_text, end);

                end_text = "\",";
                end = line.index_of (end_text, start);

                var raw_download_size = line.substring (start + start_text.length, line.length - start - start_text.length - (line.length - end));

                double download_size;
                if (!double.try_parse (raw_download_size, out download_size)) {
                    warning (@"Unable to parse the download size ($raw_download_size)");
                    return false;
                }

                //
                string crc = null;
                string md5 = null;
                string sha1 = null;

                //
                start_text = "GoodHash\":\"";
                start = line.index_of (start_text, end);

                if (start != -1) {
                    end_text = "\",";
                    end = line.index_of (end_text, start);

                    crc = line.substring (start + start_text.length, line.length - start - start_text.length - (line.length - end));
                }

                //
                start_text = "GoodMd5\":\"";
                start = line.index_of (start_text, end);

                if (start != -1) {
                    end_text = "\",";
                    end = line.index_of (end_text, start);

                    md5 = line.substring (start + start_text.length, line.length - start - start_text.length - (line.length - end));
                }

                //
                start_text = "GoodSha1\":\"";
                start = line.index_of (start_text, end);

                if (start != -1) {
                    end_text = "\"}";
                    end = line.index_of (end_text, start);

                    sha1 = line.substring (start + start_text.length, line.length - start - start_text.length - (line.length - end));
                }

                //
                var media = new Models.Media.extra (id, version, crc, md5, sha1, download_size);
                game.medias.append (media);
            }

            // Find download server

            return true;
        }
    }
}