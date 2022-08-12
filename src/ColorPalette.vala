/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Warble.ColorPalette {

    TEXT_COLOR;

    private const string BLACK_700 = "#1a1a1a";

    public string get_value () {
        switch (this) {
            case TEXT_COLOR:
                return BLACK_700;
            default:
                assert_not_reached ();
        }
    }

}
