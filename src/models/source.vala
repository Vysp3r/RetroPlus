namespace RetroPlus.Models {
    public class Source : Object {
        public string title { get; set; }

        public Source(string title) {
            this.title = title;
        }

        public static Gee.HashMap<string, Models.Source> get_sources() {
            //
            var sources = new Gee.HashMap<string, Models.Source> ();

            //
            string[] source_names = { "Vimm's Lair" };

            for (var i = 0; i < source_names.length; i++) {
                var source = new Source(source_names[i]);
                sources.set(source.title, source);
            }

            //
            return (owned) sources;
        }
    }
}