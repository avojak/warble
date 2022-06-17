/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Application : Gtk.Application {

    public static GLib.Settings settings;
    public static Warble.Models.Dictionary dictionary;

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
    }

    construct {
        settings = new GLib.Settings (Constants.APP_ID);
        dictionary = new Warble.Models.Dictionary ();
    }

    private void add_new_window () {
        if (main_window == null) {
            main_window = new Warble.MainWindow (this);
            main_window.destroy.connect (() => {
                main_window = null;
            });
            add_window (main_window);
        }
    }

    protected override void activate () {
        force_elementary_style ();
        // Respect the system color scheme preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        this.add_new_window ();
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
