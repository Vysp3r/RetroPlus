namespace RetroPlus.Models {
    public class System : Object {
        public string id { get; private set; }
        public string title { get; private set; }
        public bool handheld { get; private set; }
        public uint year { get; private set; }
        public bool extra_info_loaded { get; set; }
        public uint media_count { get; set; }
        public uint media_total { get; set; }
        public string media_last_synchronization_date { get; set; }
        public unowned List<Models.Game> monthly_top_ten_downloads_list { get; set; }
        public unowned List<Models.Game> overall_rating_list { get; set; }
        public unowned List<Models.Game> graphics_list { get; set; }
        public unowned List<Models.Game> sound_list { get; set; }
        public unowned List<Models.Game> gameplay_list { get; set; }

        public string get_url() {
            return "https://vimm.net/vault/" + id;
        }

        public float get_media_pourcentage() {
            return (media_count / (float) media_total) * 100;
        }

        public System(string id, string title, bool handheld, uint year) {
            this.id = id;
            this.title = title;
            this.handheld = handheld;
            this.year = year;
        }

        public bool load_extra_info(bool force_load = false) {
            //
            if (extra_info_loaded && !force_load)return true;

            //
            var res = "";
            var res_valid = Utils.Web.get_request(get_url(), ref res);

            //
            if (!res_valid)return false;

            //
            var temp_system = this;
            var parsed = Utils.Parser.parse_system_request(res, ref temp_system);

            //
            return extra_info_loaded = !parsed;
        }

        public async List<Models.Game> get_games_by_title(string game_title) {
            SourceFunc callback = get_games_by_title.callback;

            var games = new List<Models.Game> ();

            ThreadFunc<void> run = () => {
                //
                string res = "";

                //
                var res_valid = Utils.Web.get_request(@"https://vimm.net/vault/?mode=adv&p=list&system=$id&q=$game_title&players=%3E%3D&playersValue=1&simultaneous=&publisher=&year=%3D&yearValue=&rating=%3E%3D&ratingValue=&region=All&sort=Title&sortOrder=ASC", ref res);
                if (!res_valid)return;

                //
                var parsing_valid = Utils.Parser.parse_search_request(res, ref games);
                if (!parsing_valid)return;

                //
                Idle.add((owned) callback);

                //
                return;
            };
            new Thread<bool> ("search", (owned) run);

            yield;
            return (owned) games;
        }

        public static bool get_systems(ref Gee.HashMap<string, Models.System> systems) {
            //
            var system = new System("", "All", false, 0);
            systems.set(system.id, system);

            //
            uint[] console_years = { 1977, 1982, 1983, 1985, 1986, 1988, 1990, 1994, 1994, 1994, 1996, 1998, 2000, 2001, 2001, 2005, 2006, 2006, 2008 };
            string[] console_ids = { "Atari2600", "Atari5200", "NES", "SMS", "Atari7800", "Genesis", "SNES", "32X", "Saturn", "PS1", "N64", "Dreamcast", "PS2", "GameCube", "Xbox", "Xbox360", "PS3", "Wii", "WiiWare" };
            string[] console_names = { "Atari 2600", "Atari 5200", "Nintendo", "Master System", "Atari 7800", "Genesis", "Super Nintendo", "Sega 32X", "Saturn", "PlayStation", "Nintendo 64", "Dreamcast", "PlayStation 2", "GameCube", "Xbox", "Xbox 360", "PlayStation 3", "Wii", "WiiWare" };

            for (var i = 0; i < console_names.length; i++) {
                system = new System(console_ids[i], console_names[i], false, console_years[i]);
                systems.set(console_ids[i], system);
            }

            //
            uint[] handheld_years = { 1989, 1989, 1990, 1995, 1998, 2001, 2004, 2004 };
            string[] handheld_ids = { "GB", "Lynx", "GG", "VB", "GBC", "GBA", "DS", "PSP" };
            string[] handheld_names = { "Game Boy", "Lynx", "Game Gear", "Virtual Boy", "Game Boy Color", "Game Boy Advance", "Nintendo DS", "PlayStation Portable" };

            for (var i = 0; i < handheld_names.length; i++) {
                system = new System(handheld_ids[i], handheld_names[i], true, handheld_years[i]);
                systems.set(handheld_ids[i], system);
            }

            //
            return true;
        }
    }
}