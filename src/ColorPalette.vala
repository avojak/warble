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

public enum Warble.ColorPalette {

    TEXT_COLOR,
    ROW_SHADOW;

    private const string BLACK_100 = "#666666";
    private const string BLACK_700 = "#1a1a1a";
    private const string SILVER_300 = "#d4d4d4";

    public string get_value () {
        var prefer_dark_style = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme;
        switch (this) {
            case TEXT_COLOR:
                return BLACK_700;
            case ROW_SHADOW:
                return prefer_dark_style ? BLACK_100 : SILVER_300;
            default:
                assert_not_reached ();
        }
    }

}
