namespace RetroPlus.Models {
    public class Source : Object {
        public string title { get; set; }

        public Source(string title) {
            this.title = title;
        }

        public static List<Models.Source> get_sources() {
            //
            var sources = new List<Models.Source> ();

            //
            string[] source_names = { "Vimm's Lair" };

            for (var i = 0; i < source_names.length; i++) {
                var source = new Source(source_names[i]);
                sources.append(source);
            }

            //
            return (owned) sources;
        }
    }
}