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

public enum Warble.Models.State {

    BLANK,
    CORRECT,
    INCORRECT,
    CLOSE;

    public string get_short_name () {
        switch (this) {
            case BLANK:
                return "BLANK";
            case CORRECT:
                return "CORRECT";
            case INCORRECT:
                return "INCORRECT";
            case CLOSE:
                return "CLOSE";
            default:
                assert_not_reached ();
        }
    }

    public static State get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "BLANK":
                return BLANK;
            case "CORRECT":
                return CORRECT;
            case "INCORRECT":
                return INCORRECT;
            case "CLOSE":
                return CLOSE;
            default:
                assert_not_reached ();
        }
    }

}
