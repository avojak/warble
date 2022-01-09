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

public enum Warble.Models.Difficulty {

    EASY,
    NORMAL,
    HARD;

    public string get_display_string () {
        switch (this) {
            case EASY:
                return _("Easy");
            case NORMAL:
                return _("Normal");
            case HARD:
                return _("Hard");
            default:
                assert_not_reached ();
        }
    }

    public string get_details_markup () {
        switch (this) {
            case EASY:
                return _("%s Difficulty: 5 letters, 6 guesses".printf (get_display_string ()));
            case NORMAL:
                return _("%s Difficulty: 5 letters, 6 guesses\n<small>All green and yellow letters must be used in subsequent guesses</small>".printf (get_display_string ()));
            case HARD:
                return _("%s Difficulty: 6 letters, 7 guesses\n<small>All green and yellow letters must be used in subsequent guesses</small>".printf (get_display_string ()));
            default:
                assert_not_reached ();
        }
    }

    public int get_num_letters () {
        switch (this) {
            case EASY:
                return 5;
            case NORMAL:
                return 5;
            case HARD:
                return 6;
            default:
                assert_not_reached ();
        }
    }

    public int get_num_guesses () {
        switch (this) {
            case EASY:
                return 6;
            case NORMAL:
                return 6;
            case HARD:
                return 7;
            default:
                assert_not_reached ();
        }
    }

    public bool must_use_clues () {
        switch (this) {
            case EASY:
                return false;
            case NORMAL:
                return true;
            case HARD:
                return true;
            default:
                assert_not_reached ();
        }
    }

    public string get_short_name () {
        switch (this) {
            case EASY:
                return "EASY";
            case NORMAL:
                return "NORMAL";
            case HARD:
                return "HARD";
            default:
                assert_not_reached ();
        }
    }

    public static Difficulty get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "EASY":
                return EASY;
            case "NORMAL":
                return NORMAL;
            case "HARD":
                return HARD;
            default:
                assert_not_reached ();
        }
    }

    public static Difficulty get_value_by_name (string name) {
        EnumClass enumc = (EnumClass) typeof (Difficulty).class_ref ();
        unowned EnumValue? eval = enumc.get_value_by_name (name);
        if (eval == null) {
            assert_not_reached ();
        }
        return (Difficulty) eval.value;
    }

}