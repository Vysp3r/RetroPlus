namespace RetroPlus.Widgets {
    public class SearchFilterBox : Gtk.Box {
        ListStore system_list_store { get; set; }
        ListStore source_list_store { get; set; }
        public Gtk.DropDown system_dropdown { get; set; }
        public Gtk.DropDown source_dropdown { get; set; }
        bool initialized { get; set; }

        construct {
            //
            this.set_orientation (Gtk.Orientation.VERTICAL);
            this.set_spacing (10);
            this.add_css_class ("card");
            this.add_css_class ("p-10");

            //
            var system_label = new Gtk.Label (_("System") + ":");

            system_list_store = new ListStore (typeof (Models.System));

            var system_factory = new Gtk.SignalListItemFactory ();
            system_factory.bind.connect (system_factory_bind);
            system_factory.setup.connect (system_factory_setup);

            system_dropdown = new Gtk.DropDown (system_list_store, null);
            system_dropdown.set_factory (system_factory);

            var system_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            system_box.append (system_label);
            system_box.append (system_dropdown);

            //
            var source_label = new Gtk.Label (_("Source") + ":");

            source_list_store = new ListStore (typeof (Models.Source));

            var source_factory = new Gtk.SignalListItemFactory ();
            source_factory.bind.connect (source_factory_bind);
            source_factory.setup.connect (source_factory_setup);

            source_dropdown = new Gtk.DropDown (source_list_store, null);
            source_dropdown.set_factory (source_factory);

            var source_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            source_box.append (source_label);
            source_box.append (source_dropdown);

            //
            var flow_box = new Gtk.FlowBox ();
            flow_box.append (system_box);
            flow_box.append (source_box);
            flow_box.set_selection_mode (Gtk.SelectionMode.NONE);

            //
            this.append (flow_box);
        }

        void system_factory_bind (Gtk.SignalListItemFactory factory, Object object) {
            var list_item = object as Gtk.ListItem;

            var system = list_item.get_item () as Models.System;

            var title = list_item.get_data<Gtk.Label> ("title");
            title.label = system.title;
        }

        void system_factory_setup (Gtk.SignalListItemFactory factory, Object object) {
            var list_item = object as Gtk.ListItem;

            var title = new Gtk.Label ("");
            title.set_halign (Gtk.Align.START);

            list_item.set_data ("title", title);
            list_item.set_child (title);
        }

        void source_factory_bind (Gtk.SignalListItemFactory factory, Object object) {
            var list_item = object as Gtk.ListItem;

            var source = list_item.get_item () as Models.Source;

            var title = list_item.get_data<Gtk.Label> ("title");
            title.label = source.title;
        }

        void source_factory_setup (Gtk.SignalListItemFactory factory, Object object) {
            var list_item = object as Gtk.ListItem;

            var title = new Gtk.Label ("");
            title.set_halign (Gtk.Align.START);

            list_item.set_data ("title", title);
            list_item.set_child (title);
        }

        public void initialize (Gee.Iterator<Models.System> systems, List<Models.Source> sources) {
            //
            system_list_store.remove_all ();

            //
            systems.foreach ((system) => {
                system_list_store.append (system);

                return true;
            });

            //
            source_list_store.remove_all ();

            //
            foreach (var source in sources) {
                source_list_store.append (source);
            }
        }
    }
}