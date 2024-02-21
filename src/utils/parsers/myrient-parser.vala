namespace RetroPlus.Utils {
    public class MyrientParser : Parser {
        public override bool parse_search_request (string html, ref List<Models.Game> games) {
            if (html.length == 0)return false;
            if (html.contains ("No matches found."))return true;

            var start_text = "<tbody>";
            var start = html.index_of (start_text);

            var end_text = "</tbody>";
            var end = html.index_of (end_text, start);

            var temp_list = html.substring (start + start_text.length, html.length - start - start_text.length - (html.length - end));

            var context = new Html.ParserCtxt ();
            var doc = context.read_memory (temp_list.to_utf8 (), temp_list.length, "", "UTF-8", Html.ParserOption.NOERROR);

            if (doc == null) {
                warning ("Error parsing HTML");
                return false;
            }

            var root_node = doc->get_root_element ();

            var tr_nodes = new List<Xml.Node*> ();
            process_node_by_name ("tr", root_node, ref tr_nodes);

            foreach (var tr_node in tr_nodes) {
                var nodes = new List<Xml.Node*> ();
                process_node_by_name (null, tr_node, ref nodes);

                string title = null, file_size = null, file_name = null;

                foreach (var node in nodes) {
                    if (node->name == "a") {
                        title = node->get_content ().replace (".zip", "");

                        file_name = node->get_prop ("title");
                    }

                    if (node->get_prop ("class") == "size") {
                        file_size = node->get_content ();
                    }
                }

                if (title == "Parent directory/") {
                    continue;
                }

                if (title == null || file_name == null || file_size == null) {
                    continue;
                }

                var game = new Models.MyrientGame (title, file_size, file_name);

                games.append (game);
            }

            free (doc);

            return true;
        }
    }
}