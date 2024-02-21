namespace RetroPlus.Models {
    public class System : Object {
        public string title { get; private set; }
        public string path { get; private set; }

        public string download_directory_setting_name() {
            return get_download_directory_setting_name_list().get(title) + "-download-directory";
        }

        public System(string title, string path) {
            this.title = title;
            this.path = path;
        }

        public static Gee.HashMap<string, string> get_download_directory_setting_name_list() {
            var list = new Gee.HashMap<string, string> ();

            string[] setting_names = {
                "atari-2600",
                "atari-5200",
                "atari-7800",
                "atari-lynx",
                "sega-master-system",
                "sega-genesis",
                "sega-32X",
                "sega-saturn",
                "sega-dreamcast",
                "sega-game-gear",
                "nintendo-nes",
                "nintendo-snes",
                "nintendo-64",
                "nintendo-gamecube",
                "nintendo-wii",
                "nintendo-wiiware",
                "nintendo-virutal-boy",
                "nintendo-game-boy",
                "nintendo-game-boy-color",
                "nintendo-game-boy-advanced",
                "nintendo-ds",
                "sony-playstation",
                "sony-playstation-2",
                "sony-playstation-3",
                "sony-playstation-portable",
                "microsoft-xbox",
                "microsoft-xbox-360",
            };

            string[] system_names = {
                "Atari 2600",
                "Atari 5200",
                "Atari 7800",
                "Lynx",
                "Master System",
                "Genesis",
                "Sega 32X",
                "Saturn",
                "Dreamcast",
                "Game Gear",
                "Nintendo",
                "Super Nintendo",
                "Nintendo 64",
                "GameCube",
                "Wii",
                "WiiWare",
                "Virtual Boy",
                "Game Boy",
                "Game Boy Color",
                "Game Boy Advance",
                "Nintendo DS",
                "PlayStation",
                "PlayStation 2",
                "PlayStation 3",
                "PlayStation Portable",
                "Xbox",
                "Xbox 360",
            };

            for (var i = 0; i < setting_names.length; i++) {
                list.set(system_names[i], setting_names[i]);
            }

            return (owned) list;
        }

        public static Gee.HashMap<string, Models.System> get_vimms_lair_systems() {
            var systems = new Gee.HashMap<string, Models.System> ();

            var system = new System("All", "");
            systems.set(system.title, system);

            string[] paths = {
                "Atari2600",
                "Atari5200",
                "Atari7800",
                "Lynx",
                "SMS",
                "Genesis",
                "32X",
                "Saturn",
                "Dreamcast",
                "GG",
                "NES",
                "SNES",
                "N64",
                "GameCube",
                "Wii",
                "WiiWare",
                "VB",
                "GB",
                "GBC",
                "GBA",
                "DS",
                "PS1",
                "PS2",
                "PS3",
                "PSP",
                "Xbox",
                "Xbox360",
            };

            string[] names = {
                "Atari 2600",
                "Atari 5200",
                "Atari 7800",
                "Lynx",
                "Master System",
                "Genesis",
                "Sega 32X",
                "Saturn",
                "Dreamcast",
                "Game Gear",
                "Nintendo",
                "Super Nintendo",
                "Nintendo 64",
                "GameCube",
                "Wii",
                "WiiWare",
                "Virtual Boy",
                "Game Boy",
                "Game Boy Color",
                "Game Boy Advance",
                "Nintendo DS",
                "PlayStation",
                "PlayStation 2",
                "PlayStation 3",
                "PlayStation Portable",
                "Xbox",
                "Xbox 360",
            };

            for (var i = 0; i < names.length; i++) {
                system = new System(names[i], paths[i]);
                systems.set(system.title, system);
            }

            return (owned) systems;
        }

        public static Gee.HashMap<string, Models.System> get_myrient_systems() {
            var systems = new Gee.HashMap<string, Models.System> ();

            Models.System system = null;

            string[] paths = {
                "No-Intro/Atari - 2600",
                "No-Intro/Atari - 5200",
                "No-Intro/Atari - 7800",
                "No-Intro/Atari - Lynx",
                "No-Intro/Sega - Mega Drive - Genesis",
                "No-Intro/Sega - 32X",
                "Redump/Sega - Saturn",
                "Redump/Sega - Dreamcast",
                "No-Intro/Sega - Game Gear",
                "No-Intro/Nintendo - Nintendo Entertainment System (Headered)",
                "No-Intro/Nintendo - Super Nintendo Entertainment System",
                "No-Intro/Nintendo - Nintendo 64 (BigEndian)",
                "No-Intro/Nintendo - Virtual Boy",
                "No-Intro/Nintendo - Game Boy",
                "No-Intro/Nintendo - Game Boy Color",
                "No-Intro/Nintendo - Game Boy Advance",
                "No-Intro/Nintendo - Nintendo DS (Decrypted)",
                "Redump/Sony - PlayStation",
                "Redump/Sony - PlayStation 2",
                "Redump/Sony - PlayStation 3",
                "Redump/Sony - PlayStation Portable",
                "Redump/Microsoft - Xbox",
                "Redump/Microsoft - Xbox 360",
            };

            string[] names = {
                "Atari 2600",
                "Atari 5200",
                "Atari 7800",
                "Lynx",
                "Genesis",
                "Sega 32X",
                "Saturn",
                "Dreamcast",
                "Game Gear",
                "Nintendo",
                "Super Nintendo",
                "Nintendo 64",
                "Virtual Boy",
                "Game Boy",
                "Game Boy Color",
                "Game Boy Advance",
                "Nintendo DS",
                "PlayStation",
                "PlayStation 2",
                "PlayStation 3",
                "PlayStation Portable",
                "Xbox",
                "Xbox 360",
            };

            for (var i = 0; i < names.length; i++) {
                system = new System(names[i], paths[i]);
                systems.set(system.title, system);
            }

            return (owned) systems;
        }
    }
}