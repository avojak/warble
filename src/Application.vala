/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

    private GLib.List<Warble.MainWindow> windows;

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
        windows = new GLib.List<Warble.MainWindow> ();

        startup.connect ((handler) => {
            Hdy.init ();
        });
    }

    public override void window_added (Gtk.Window window) {
        windows.append (window as Warble.MainWindow);
        base.window_added (window);
    }

    public override void window_removed (Gtk.Window window) {
        windows.remove (window as Warble.MainWindow);
        base.window_removed (window);
    }

    private Warble.MainWindow add_new_window () {
        var window = new Warble.MainWindow (this);
        this.add_window (window);
        return window;
    }

    protected override void activate () {
        // Respect the system style preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        this.add_new_window ();
    }

    public static int main (string[] args) {
        var app = new Warble.Application ();
        return app.run (args);
    }

}
