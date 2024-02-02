namespace RetroPlus.Utils {
    public class Parser {
        public static bool parse_markup (string text, out string parsed_text) {
            try {
                Pango.AttrList attr_list;
                unichar accel_char;
                Pango.parse_markup (text, text.length, 0, out attr_list, out parsed_text, out accel_char);
                return true;
            } catch {
                return false;
            }
        }

        public static bool parse_search_request (string res, ref List<Models.Game> games) {
            if (res.length == 0)return false;

            var start_text = "</caption>";
            var start = res.index_of (start_text, res.index_of (start_text) + start_text.length);

            var end_text = "</table>";
            var end = res.index_of (end_text, start);

            var temp_list = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            if (temp_list.contains ("No matches found."))return true;

            var offset = res.contains (">System</td>") ? 1 : 0;

            while (temp_list.length != 0) {
                temp_list = temp_list.strip ();

                var raw_id = "";
                var raw_title = "";
                var raw_manual_id = "";
                var extras = new List<Models.Extra> ();
                var regions = new List<Models.Region> ();
                Models.Media media = null;
                var system = "";

                start_text = "<tr>";
                start = temp_list.index_of (start_text);

                end_text = "</tr>";
                end = temp_list.index_of (end_text);

                var temp_game = temp_list.substring (start + start_text.length, end - (start + start_text.length));

                temp_list = temp_list.substring (temp_game.length + start_text.length + end_text.length);

                if (temp_game.contains ("</tr>"))break;

                for (int i = 0; i < 5; i++) {
                    start_text = "<td";
                    start = temp_game.index_of (start_text);

                    end_text = "</td>";
                    end = temp_game.index_of (end_text);

                    var temp_line = temp_game.substring (start, end - start + end_text.length);

                    temp_game = temp_game.substring (temp_line.length);
                   
                    //
                    if (i == 0 && offset == 1) {
                        start_text = ">";
                        start = temp_line.index_of (start_text);

                        end_text = "<";
                        end = temp_line.index_of (end_text, start);

                        system = temp_line.substring (start + start_text.length, end - (start + start_text.length));
                    }

                    //
                    if (i == 0 + offset) {
                        //
                        start_text = "href=\"";
                        start = temp_line.index_of (start_text);
        
                        if (temp_line.contains("onmouseover")) {
                            end_text = "\" onmouseover";
                        } else {
                            end_text = "\">";
                        }
                        
                        end = temp_line.index_of (end_text, start);

                        raw_id = temp_line.substring (start + start_text.length, end - (start + start_text.length));
                        raw_id = raw_id.replace ("/vault/", "");

                        //
                        start_text = ">";
                        start = temp_line.index_of (start_text, end);

                        end_text = "</a>";
                        end = temp_line.index_of (end_text, start);

                        raw_title = temp_line.substring (start + start_text.length, end - (start + start_text.length));
                        raw_title = raw_title.replace ("<br>", "");

                        //
                        var extra_start = temp_line.index_of ("redBorder", end);

                        if (extra_start != -1) {
                            //
                            start_text = "title=\"";
                            start = temp_line.index_of (start_text, extra_start);
    
    
                            end_text = "\">";
                            end = temp_line.index_of (end_text, start);
    
                            var extra_title = temp_line.substring (start + start_text.length, end - (start + start_text.length));

                            //
                            start_text = ">";
                            start = temp_line.index_of (start_text, end);
    
                            end_text = "</b>";
                            end = temp_line.index_of (end_text, start);
    
                            var extra_short_title = temp_line.substring (start + start_text.length, end - (start + start_text.length));

                            //
                            var extra = new Models.Extra (extra_title, extra_short_title);
                            extras.append (extra);

                            //
                            extra_start = temp_line.index_of ("redBorder", end);

                            if (extra_start != -1) {
                                //
                                start_text = "title=\"";
                                start = temp_line.index_of (start_text, extra_start);
        
        
                                end_text = "\">";
                                end = temp_line.index_of (end_text, start);
        
                                extra_title = temp_line.substring (start + start_text.length, end - (start + start_text.length));

                                //
                                start_text = ">";
                                start = temp_line.index_of (start_text, extra_start);
        
        
                                end_text = "</b>";
                                end = temp_line.index_of (end_text, start);
        
                                extra_short_title = temp_line.substring (start + start_text.length, end - (start + start_text.length));
                                    
                                //
                                extra = new Models.Extra (extra_title, extra_short_title);
                                extras.append (extra);
                            }
                        }

                        //
                        if (temp_line.contains ("/images/manual_1.gif")) {
                            start_text = "manual/";
                            start = temp_line.index_of (start_text, end);

                            end_text = "\">";
                            end = temp_line.index_of (end_text, start);

                            raw_manual_id = temp_line.substring (start + start_text.length, end - (start + start_text.length));
                        }
                    }

                    //
                    if (i == 1 + offset) {
                        //
                        end = 0;

                        //
                        while (true) {
                            //
                            start_text = "flags/";
                            start = temp_line.index_of (start_text, end);

                            end_text = "\" class";
                            end = temp_line.index_of (end_text, start);

                            var region_flag_filename = temp_line.substring (start + start_text.length, end - (start + start_text.length));

                            //
                            start_text = "title=\"";
                            start = temp_line.index_of (start_text, end);

                            end_text = "\" style";
                            end = temp_line.index_of (end_text, start);

                            var region_title = temp_line.substring (start + start_text.length, end - (start + start_text.length));

                            //
                            var region = new Models.Region (region_title, region_flag_filename);

                            //
                            regions.append (region);

                            //
                            if (temp_line.index_of ("title", end) == -1) break;
                        }
                    }

                    //
                    if (i == 2 + offset) {
                        start_text = "\">";
                        start = temp_line.index_of (start_text);

                        end_text = "<";
                        end = temp_line.index_of (end_text, start);

                        var raw_version = temp_line.substring (start + start_text.length, end - (start + start_text.length));

                        double version;
                        if (!double.try_parse (raw_version, out version)) {
                            warning (@"Unable to parse the version ($raw_version)");
                            return false;
                        }

                        media = new Models.Media (version);
                    }
                }

                int id;
                var id_parsed = int.try_parse (raw_id, out id);
                if (!id_parsed) {
                    warning (@"Unable to parse the id ($raw_id)");
                    continue;
                }

                string title;
                var title_parsed = parse_markup(raw_title, out title);
                if (!title_parsed) {
                    warning (@"Unable to parse the title ($raw_title)");
                    continue;
                }

                int manual_id;
                var manual_parsed = int.try_parse (raw_manual_id, out manual_id);
                if (!manual_parsed) {
                    warning (@"Unable to parse the manual id ($raw_manual_id)");
                    continue;
                }

                if (media == null) {
                    warning (@"Unable to parse the media");
                    continue;
                }

                var game = new Models.Game.from_search (id, system, title, manual_id, extras, regions, media);
                games.append (game);
            }

            return true;
        }

        public static bool parse_game_request (string res, ref Models.Game game) {
            //
            var missing = res.contains ("This game is not currently in The Vault.");

            game.missing = missing;

            if (missing) {
                warning (@"Unable to parse the game " + game.title + " since it's not currently in Vimm vault");
                return false;
            }

            //
            var start_text = "sectionTitle";
            var start = res.last_index_of (start_text) + 2;

            var end_text = "</div>";
            var end = res.index_of (end_text, start);

            var system = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            game.system = system;

            //
            start_text = "Players";
            start = res.index_of (start_text, start) + 59;

            end_text = "</td>";
            end = res.index_of (end_text, start);

            var raw_max_players = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));
            raw_max_players = raw_max_players.strip ();

            if (raw_max_players.contains ("Simultaneous")) {
                raw_max_players = raw_max_players.split (" ")[0];
                game.simultaneous = true;
            }

            if (raw_max_players.contains ("?")) {
                game.max_players = -1;
            } else {
                int max_players;
                if (!int.try_parse (raw_max_players, out max_players)) {
                    warning (@"Unable to parse the max players ($raw_max_players)");
                    return false;
                }

                game.max_players = max_players;
            }

            //
            start_text = "Year";
            start = res.index_of (start_text, start) + 38;

            end_text = "</td>";
            end = res.index_of (end_text, start);

            var raw_year = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            if (raw_year.contains ("?")) {
                game.year = -1;
            } else {
                int year;
                if (!int.try_parse (raw_year, out year)) {
                    warning (@"Unable to parse the year ($raw_year)");
                    return false;
                }
    
                game.year = year;
            }

            //
            start_text = "Publisher";
            start = res.index_of (start_text, start) + 18;

            end_text = "</tr>";
            end = res.index_of (end_text, start) - 5;

            var publisher = start - 18 == -1 ? "" : res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            if (publisher.length > 0) {
                game.publisher = publisher;
            }
            
            //
            start_text = "Serial #";
            start = res.index_of (start_text, start) + 18;
            if (res.contains ("id=\"serials\">"))start += 13;

            end_text = "</tr>";
            end = res.index_of (end_text, start) - 5;

            var serial = start - 18 == -1 ? "" : res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));
            serial = serial.replace ("<br>", " ");

            if (serial.length > 0) {
                game.serial = serial;
            }

            //
            if (game.rated = !res.contains ("Rating")) {
                //
                start_text = "Graphics";
                start = res.index_of (start_text, start) + 18;
    
                end_text = "</tr>";
                end = res.index_of (end_text, start) - 5;
    
                var raw_graphics_rating = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));
    
                double graphics_rating;
                if (!double.try_parse (raw_graphics_rating, out graphics_rating)) {
                    warning (@"Unable to parse the graphics rating ($raw_graphics_rating)");
                    return false;
                }
        
                game.graphics_rating = graphics_rating;
    
                //
                start_text = "Sound";
                start = res.index_of (start_text, start) + 18;
    
                end_text = "</tr>";
                end = res.index_of (end_text, start) - 5;
    
                var raw_sound_rating = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

                double sound_rating;
                if (!double.try_parse (raw_sound_rating, out sound_rating)) {
                    warning (@"Unable to parse the sound rating ($raw_sound_rating)");
                    return false;
                }
        
                game.sound_rating = sound_rating;
    
                //
                start_text = "Gameplay";
                start = res.index_of (start_text, start) + 18;
    
                end_text = "</tr>";
                end = res.index_of (end_text, start) - 5;
    
                var raw_gameplay_rating = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

                double gameplay_rating;
                if (!double.try_parse (raw_gameplay_rating, out gameplay_rating)) {
                    warning (@"Unable to parse the gameplay rating ($raw_gameplay_rating)");
                    return false;
                }
        
                game.gameplay_rating = gameplay_rating;
    
                //
                start_text = "Overall";
                start = res.index_of (start_text, start) + 18;
    
                end_text = "<span";
                end = res.index_of (end_text, start) - 6;
    
                var raw_overall_rating = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

                double overall_rating;
                if (!double.try_parse (raw_overall_rating, out overall_rating)) {
                    warning (@"Unable to parse the overall rating ($raw_overall_rating)");
                    return false;
                }
        
                game.overall_rating = overall_rating;
    
                //
                start_text = ">(";
                start = res.index_of (start_text, start);
    
                end_text = " vote";
                end = res.index_of (end_text, start);
    
                var raw_total_votes = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

                int total_votes;
                if (!int.try_parse (raw_total_votes, out total_votes)) {
                    warning (@"Unable to parse the total votes ($raw_total_votes)");
                    return false;
                }

                game.total_votes = total_votes;
            }

            //
            start_text = "data-date";
            start = res.index_of (start_text, start) + 2;

            end_text = "</span>";
            end = res.index_of (end_text, start);

            var last_verification_date = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            game.last_verification_date = last_verification_date;

            //
            var play_online_support = res.contains ("Play Online");

            game.support_play_online = play_online_support;

            //
            start_text = "var allMedia = [];";
            start = res.index_of (start_text);

            end_text = "document.addEventListener(";
            end = res.index_of (end_text, start);

            var medias_text = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));
            var medias_text_split = medias_text.split ("allMedia.push(media);");

            while (game.medias.length () > 0) {
                game.medias.remove (game.medias.nth_data (0));
            }

            for (var i = 0; i < medias_text_split.length; i++) {
                //
                if (i == medias_text_split.length - 1) break;

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

            //
            start_text = "//download";
            start = res.index_of (start_text, 0);
                    
            end_text = "\" method=";
            end = res.index_of (end_text, start);
                    
            game.download_server = "https:" + res.substring (start, end - start);

            //
            return true;
        }

        public static bool parse_system_request (string res, ref Models.System console) {
            //
            var start_text = "<td>Have ";
            var start = res.index_of (start_text);

            var end_text = " of ";
            var end = res.index_of (end_text);

            var media_count = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            //
            start_text = " of ";
            start = end;

            end_text = "media";
            end = res.index_of (end_text, start);

            var media_total = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            //
            start_text = "dat: ";
            start = res.index_of (start_text, end);

            end_text = "</td>";
            end = res.index_of (end_text, start);

            var media_last_synchronization_date = res.substring (start + start_text.length, res.length - start - start_text.length - (res.length - end));

            //
            console.media_count = int.parse (media_count);
            console.media_total = int.parse (media_total);
            console.media_last_synchronization_date = media_last_synchronization_date;

            //
            start_text = "<tr";
            start = res.index_of (start_text, end);

            end_text = "</tbody>";
            end = res.index_of (end_text, start);

            var top_ten = res.substring (start, res.length - start - (res.length - end));
            var top_ten_rows = top_ten.split ("<tr");

            for (int i = 1; i < top_ten_rows.length; i++) {
                //
                start_text = "href=\"";
                start = top_ten_rows[i].index_of (start_text);

                end_text = ">";
                end = top_ten_rows[i].index_of (end_text, start) - 1;

                var id_str = top_ten_rows[i].substring (start + start_text.length, top_ten_rows[i].length - start - start_text.length - (top_ten_rows[i].length - end));

                if (id_str.contains ("onMouseOver")) {
                    id_str = id_str.substring (0, id_str.index_of("onMouseOver") - 2);
                }

                int id;
                var id_parsed = int.try_parse (id_str, out id);

                if (!id_parsed) {
                    warning (@"Unable to parse the following id: $id_str");
                    continue;
                }

                //
                start_text = ">";
                start = top_ten_rows[i].index_of (start_text, end);

                end_text = "<";
                end = top_ten_rows[i].index_of (end_text, start);

                var title = top_ten_rows[i].substring (start + start_text.length, top_ten_rows[i].length - start - start_text.length - (top_ten_rows[i].length - end));
                var title_parsed = parse_markup(title, out title);

                if (!title_parsed) {
                    warning (@"Unable to parse the title of $title");
                    continue;
                }

                //
                var game = new Models.Game (id, title);
                console.monthly_top_ten_downloads_list.append (game);
            }

            //
            start_text = "<caption>Overall Rating</caption>";
            start = res.index_of (start_text, end);

            end_text = "</table>";
            end = res.index_of (end_text, start);

            var overall_rating = res.substring (start, res.length - start - (res.length - end));
            var overall_rating_rows = overall_rating.split ("<tr>");

            for (int i = 1; i < overall_rating_rows.length; i++) {
                //
                start_text = "href=\"";
                start = overall_rating_rows[i].index_of (start_text);

                end_text = "\">";
                end = overall_rating_rows[i].index_of (end_text);

                var id = overall_rating_rows[i].substring (start + start_text.length, overall_rating_rows[i].length - start - start_text.length - (overall_rating_rows[i].length - end));
                id = id.replace ("/vault/", "");

                //
                start_text = end_text;
                start = end;

                end_text = "<";
                end = overall_rating_rows[i].index_of (end_text, start);

                var title = overall_rating_rows[i].substring (start + start_text.length, overall_rating_rows[i].length - start - start_text.length - (overall_rating_rows[i].length - end));
                parse_markup(title, out title);

                //
                var game = new Models.Game (int.parse (id), title);
                console.overall_rating_list.append (game);
            }

            //
            start_text = "<caption>Graphics</caption>";
            start = res.index_of (start_text, end);

            end_text = "</table>";
            end = res.index_of (end_text, start);

            var graphics = res.substring (start, res.length - start - (res.length - end));
            var graphics_rows = graphics.split ("<tr>");

            for (int i = 1; i < graphics_rows.length; i++) {
                //
                start_text = "href=\"";
                start = graphics_rows[i].index_of (start_text);

                end_text = "\">";
                end = graphics_rows[i].index_of (end_text);

                var id = graphics_rows[i].substring (start + start_text.length, graphics_rows[i].length - start - start_text.length - (graphics_rows[i].length - end));
                id = id.replace ("/vault/", "");

                //
                start_text = end_text;
                start = end;

                end_text = "<";
                end = graphics_rows[i].index_of (end_text, start);

                var title = graphics_rows[i].substring (start + start_text.length, graphics_rows[i].length - start - start_text.length - (graphics_rows[i].length - end));
                parse_markup(title, out title);

                //
                var game = new Models.Game (int.parse (id), title);
                console.graphics_list.append (game);
            }

            //
            start_text = "<caption>Sound</caption>";
            start = res.index_of (start_text, end);

            end_text = "</table>";
            end = res.index_of (end_text, start);

            var sound = res.substring (start, res.length - start - (res.length - end));
            var sound_rows = sound.split ("<tr>");

            for (int i = 1; i < sound_rows.length; i++) {
                //
                start_text = "href=\"";
                start = sound_rows[i].index_of (start_text);

                end_text = "\">";
                end = sound_rows[i].index_of (end_text);

                var id = sound_rows[i].substring (start + start_text.length, sound_rows[i].length - start - start_text.length - (sound_rows[i].length - end));
                id = id.replace ("/vault/", "");

                //
                start_text = end_text;
                start = end;

                end_text = "<";
                end = sound_rows[i].index_of (end_text, start);

                var title = sound_rows[i].substring (start + start_text.length, sound_rows[i].length - start - start_text.length - (sound_rows[i].length - end));
                parse_markup(title, out title);

                //
                var game = new Models.Game (int.parse (id), title);
                console.sound_list.append (game);
            }

            //
            start_text = "<caption>Gameplay</caption>";
            start = res.index_of (start_text, end);

            end_text = "</table>";
            end = res.index_of (end_text, start);

            var gameplay = res.substring (start, res.length - start - (res.length - end));
            var gameplay_rows = gameplay.split ("<tr>");

            for (int i = 1; i < gameplay_rows.length; i++) {
                //
                start_text = "href=\"";
                start = gameplay_rows[i].index_of (start_text);

                end_text = "\">";
                end = gameplay_rows[i].index_of (end_text);

                var id = gameplay_rows[i].substring (start + start_text.length, gameplay_rows[i].length - start - start_text.length - (gameplay_rows[i].length - end));
                id = id.replace ("/vault/", "");

                //
                start_text = end_text;
                start = end;

                end_text = "<";
                end = gameplay_rows[i].index_of (end_text, start);

                var title = gameplay_rows[i].substring (start + start_text.length, gameplay_rows[i].length - start - start_text.length - (gameplay_rows[i].length - end));
                parse_markup(title, out title);

                //
                var game = new Models.Game (int.parse (id), title);
                console.gameplay_list.append (game);
            }

            //
            return true;
        }
    }
}