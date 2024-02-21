namespace RetroPlus.Models {
    public class Source : Object {
        public string title { get; set; }
        public Utils.Parser parser { get; set; }
        public Gee.HashMap<string, Models.System> systems { get; set; }

        public Gee.Iterator<Models.System> get_systems_ordered_by_name () {
            return systems.values.order_by ((a, b) => {
                return strcmp (a.title, b.title);
            });
        }

        public Source (string title, Utils.Parser parser, Gee.HashMap<string, Models.System> systems) {
            this.title = title;
            this.parser = parser;
            this.systems = systems;
        }

        public class get_games_by_title_result {
            public List<Models.Game> games;
            public bool request_error;
            public bool parsing_error;
        }

        public async get_games_by_title_result get_games_by_title (string request_url) {
            SourceFunc callback = get_games_by_title.callback;

            var result = new get_games_by_title_result ();
            result.games = new List<Models.Game> ();

            if (request_url == null) {
                return result;
            }

            ThreadFunc<void> run = () => {
                string res = "";

                var res_valid = Utils.Web.get_request (request_url, ref res);
                if (!res_valid) {
                    result.request_error = true;
                } else {
                    var parsing_valid = parser.parse_search_request (res, ref result.games);
                    if (!parsing_valid) {
                        result.parsing_error = true;
                    }
                }

                Idle.add ((owned) callback);

                return;
            };
            new Thread<bool> ("search", (owned) run);

            yield;
            return result;
        }

        public static Gee.HashMap<string, Models.Source> get_sources () {
            var sources = new Gee.HashMap<string, Models.Source> ();

            string[] source_names = {
                "Vimm's Lair",
                "Myrient"
            };

            Utils.Parser[] source_parsers = {
                new Utils.VimmsLairParser (),
                new Utils.MyrientParser (),
            };

            Gee.HashMap<string, Models.System>[] source_systems = {
                Models.System.get_vimms_lair_systems (),
                Models.System.get_myrient_systems (),
            };

            for (var i = 0; i < source_names.length; i++) {
                var source = new Source (source_names[i], source_parsers[i], source_systems[i]);
                sources.set (source.title, source);
            }

            return (owned) sources;
        }

        public static string get_vimms_lair_request_url (string system_path, string game_title) {
            return @"https://vimm.net/vault/?mode=adv&p=list&system=$system_path&q=$game_title&players=%3E%3D&playersValue=1&simultaneous=&publisher=&year=%3D&yearValue=&rating=%3E%3D&ratingValue=&region=All&sort=Title&sortOrder=ASC";
        }

        public static string get_myrient_request_url (string system_path, string game_title) {
            return @"https://myrient.erista.me/files/$system_path/?filter=$game_title";
        }
    }
}