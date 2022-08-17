/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Application : Gtk.Application {

    public static Gee.List<char> alphabet = new Gee.ArrayList<char>.wrap ({
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    });

    public static GLib.Settings settings;
    public static Warble.Models.Dictionary dictionary;

    private static Gtk.CssProvider provider;

    private Warble.MainWindow? main_window;

    public Application () {
        Object (
            application_id: Constants.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        info ("%s version: %s", Constants.APP_ID, Constants.VERSION);
        info ("Kernel version: %s", Posix.utsname ().release);

        provider = new Gtk.CssProvider ();
    }

    construct {
        settings = new GLib.Settings (Constants.APP_ID);
        dictionary = new Warble.Models.Dictionary ();
    }

    private void add_new_window () {
        if (main_window == null) {
            main_window = new Warble.MainWindow (this);
            add_window (main_window);
        }
    }

    protected override void activate () {
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), 
            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        force_elementary_style ();
        // Respect the system color scheme preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        load_stylesheet ();
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            load_stylesheet ();
        });
        settings.changed["high-contrast-mode"].connect (() => {
            load_stylesheet ();
        });

        this.add_new_window ();
    }

    private void load_stylesheet () {
        var gtk_settings = Gtk.Settings.get_default ();
        bool dark_mode = gtk_settings.gtk_application_prefer_dark_theme;
        bool high_contrast_mode = settings.get_boolean ("high-contrast-mode");

        if (dark_mode && high_contrast_mode) {
            provider.load_from_resource (Constants.APP_ID.replace (".", "/") + "/warble-dark-hicontrast.css");
        } else if (dark_mode && !high_contrast_mode) {
            provider.load_from_resource (Constants.APP_ID.replace (".", "/") + "/warble-dark.css");
        } else if (!dark_mode && high_contrast_mode) {
            provider.load_from_resource (Constants.APP_ID.replace (".", "/") + "/warble-light-hicontrast.css");
        } else {
            provider.load_from_resource (Constants.APP_ID.replace (".", "/") + "/warble-light.css");
        }
    }

    /**
     * Sets the app's icons, cursors, and stylesheet to elementary defaults.
     * See: https://github.com/elementary/granite/pull/501
     */
    private void force_elementary_style () {
        const string STYLESHEET_PREFIX = "io.elementary.stylesheet";
        unowned var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_cursor_theme_name = "elementary";
        gtk_settings.gtk_icon_theme_name = "elementary";

        if (!gtk_settings.gtk_theme_name.has_prefix (STYLESHEET_PREFIX)) {
            gtk_settings.gtk_theme_name = string.join (".", STYLESHEET_PREFIX, "blueberry");
        }
    }

    public static int main (string[] args) {
        var app = new Warble.Application ();
        return app.run (args);
    }

}
