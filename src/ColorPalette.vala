/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.ColorPalette {

    private const string SILVER_100 = "#FAFAFA";
    private const string BLACK_700 = "#1A1A1A";

    public static string get_text_color (Warble.Models.State? background_state = null) {
        bool dark_theme = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme;
        if (background_state == null
            || background_state == Warble.Models.State.BLANK
            || background_state == Warble.Models.State.ACTIVE
        ) {
            if (dark_theme) {
                return SILVER_100;
            } else {
                return BLACK_700;
            }
        }
        return BLACK_700;
    }

}
