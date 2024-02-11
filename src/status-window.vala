namespace RetroPlus {
    public class StatusWindow : Adw.ApplicationWindow {
        Adw.StatusPage status_page { get; set; }

        construct {
            //
            this.set_title (Constants.APP_NAME);
            this.set_size_request (410, 500);
            this.set_default_size (410, 500);

            //
            var header = new Adw.HeaderBar ();
            header.set_name (Constants.APP_NAME);
            header.add_css_class ("flat");

            //
            status_page = new Adw.StatusPage ();
            status_page.set_vexpand (true);
            status_page.set_hexpand (true);

            //
            var toolbar_view = new Adw.ToolbarView ();
            toolbar_view.add_top_bar (header);
            toolbar_view.set_content (status_page);

            //
            this.set_content (toolbar_view);
        }

        public void initialize (string? status_page_icon_name, string? status_page_title, string? status_page_description) {
            status_page.set_icon_name (status_page_icon_name);
            status_page.set_title (status_page_title);
            status_page.set_description (status_page_description);
        }
    }
}