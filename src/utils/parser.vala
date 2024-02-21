namespace RetroPlus.Utils {
    public abstract class Parser {
        internal static void process_node_by_name (string? name, Xml.Node* node, ref List<Xml.Node*> node_list) {
            if (node->name == name || name == null) {
                node_list.append (node);
            }

            for (Xml.Node* child = node->children; child != null; child = child->next) {
                process_node_by_name (name, child, ref node_list);
            }
        }

        public abstract bool parse_search_request (string html, ref List<Models.Game> games);
    }
}