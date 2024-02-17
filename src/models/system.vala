namespace RetroPlus.Models {
    public class System : Object {
        public string id { get; private set; }
        public string title { get; private set; }
        public bool handheld { get; private set; }
        public uint year { get; private set; }
        public string download_directory_setting_name { get; private set; }

        public string get_url() {
            return @"https://vimm.net/vault/$id";
        }

        public System(string id, string title, bool handheld, uint year, string download_directory_setting_name) {
            this.id = id;
            this.title = title;
            this.handheld = handheld;
            this.year = year;
            this.download_directory_setting_name = download_directory_setting_name;
        }

        public class get_games_by_title_result {
            public List<Models.Game> games;
            public bool request_error;
            public bool parsing_error;
        }

        public async get_games_by_title_result get_games_by_title(string game_title) {
            SourceFunc callback = get_games_by_title.callback;

            var result = new get_games_by_title_result();
            result.games = new List<Models.Game> ();

            ThreadFunc<void> run = () => {
                //
                string res = "";

                //
                var res_valid = Utils.Web.get_request(@"https://vimm.net/vault/?mode=adv&p=list&system=$id&q=$game_title&players=%3E%3D&playersValue=1&simultaneous=&publisher=&year=%3D&yearValue=&rating=%3E%3D&ratingValue=&region=All&sort=Title&sortOrder=ASC", ref res);
                if (!res_valid) {
                    result.request_error = true;
                } else {
                    //
                    var parsing_valid = Utils.VimmsLairParser.parse_search_request(res, ref result.games);
                    if (!parsing_valid) {
                        result.parsing_error = true;
                    }
                }

                //
                Idle.add((owned) callback);

                //
                return;
            };
            new Thread<bool> ("search", (owned) run);

            yield;
            return result;
        }

        public static Gee.HashMap<string, Models.System> get_systems() {
            //
            var systems = new Gee.HashMap<string, Models.System> ();

            //
            var system = new System("", "All", false, 0, "");
            systems.set(system.id, system);

            //
            uint[] console_years = { 1977, 1982, 1983, 1985, 1986, 1988, 1990, 1994, 1994, 1994, 1996, 1998, 2000, 2001, 2001, 2005, 2006, 2006, 2008 };
            string[] console_ids = { "Atari2600", "Atari5200", "NES", "SMS", "Atari7800", "Genesis", "SNES", "32X", "Saturn", "PS1", "N64", "Dreamcast", "PS2", "GameCube", "Xbox", "Xbox360", "PS3", "Wii", "WiiWare" };
            string[] console_names = { "Atari 2600", "Atari 5200", "Nintendo", "Master System", "Atari 7800", "Genesis", "Super Nintendo", "Sega 32X", "Saturn", "PlayStation", "Nintendo 64", "Dreamcast", "PlayStation 2", "GameCube", "Xbox", "Xbox 360", "PlayStation 3", "Wii", "WiiWare" };

            for (var i = 0; i < console_names.length; i++) {
                var setting_name = console_ids[i].ascii_down() + "-download-directory";
                if (console_ids[i] == "32X")setting_name = "sega-".concat(setting_name); // Custom rule since a setting cannot start with a number

                system = new System(console_ids[i], console_names[i], false, console_years[i], setting_name);
                systems.set(system.title, system);
            }

            //
            uint[] handheld_years = { 1989, 1989, 1990, 1995, 1998, 2001, 2004, 2004 };
            string[] handheld_ids = { "GB", "Lynx", "GG", "VB", "GBC", "GBA", "DS", "PSP" };
            string[] handheld_names = { "Game Boy", "Lynx", "Game Gear", "Virtual Boy", "Game Boy Color", "Game Boy Advance", "Nintendo DS", "PlayStation Portable" };

            for (var i = 0; i < handheld_names.length; i++) {
                var setting_name = console_ids[i].ascii_down() + "-download-directory";

                system = new System(handheld_ids[i], handheld_names[i], true, handheld_years[i], setting_name);
                systems.set(system.title, system);
            }

            //
            return (owned) systems;
        }
    }
}