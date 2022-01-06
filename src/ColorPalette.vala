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

    SQUARE_BORDER,
    SQUARE_BG_BLANK,
    SQUARE_BG_CORRECT,
    SQUARE_BG_CLOSE,
    SQUARE_BG_INCORRECT,
    TEXT;

    private const string STRAWBERRY_300 = "#ed5353";
    private const string STRAWBERRY_500 = "#c6262e";
    private const string ORANGE_300 = "#ffa154";
    private const string ORANGE_700 = "#cc3b02";
    private const string BANANA_300 = "#ffe16b";
    private const string BANANA_500 = "#f9c440";
    private const string BANANA_700 = "#d48e15";
    private const string LIME_300 = "#9bdb4d";
    private const string LIME_500 = "#68b723";
    private const string LIME_700 = "#3a9104";
    private const string BLUEBERRY_300 = "#64baff";
    private const string BLUEBERRY_500 = "#3689e6";
    private const string SILVER_100 = "#fafafa";
    private const string SILVER_300 = "#d4d4d4";
    private const string SILVER_500 = "#abacae";
    private const string SILVER_900 = "#555761";
    private const string BLACK_700 = "#1a1a1a";

    public string get_value () {
        var prefer_dark_style = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme;
        // Colors defined by the elementary OS Human Interface Guidelines
        // When in the "dark style", use shades that are one step lighter than the "middle" value
        switch (this) {
            case SQUARE_BORDER:
                return prefer_dark_style ? SILVER_300 : SILVER_500;
            case SQUARE_BG_BLANK:
                return prefer_dark_style ? SILVER_300 : SILVER_500;
            case SQUARE_BG_CORRECT:
                return LIME_300; // prefer_dark_style ? LIME_700 : LIME_500;
            case SQUARE_BG_CLOSE:
                return BANANA_300; // prefer_dark_style ? LIME_700 : LIME_500;
            case SQUARE_BG_INCORRECT:
                return SILVER_900; // prefer_dark_style ? LIME_700 : LIME_500;
            case TEXT:
                return BLACK_700; // prefer_dark_style ? SILVER_100 : BLACK_700;
            default:
                assert_not_reached ();
        }
    }

}