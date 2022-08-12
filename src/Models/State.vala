/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Warble.Models.State {

    BLANK,
    ACTIVE,
    CORRECT,
    INCORRECT,
    CLOSE;

    public string get_short_name () {
        switch (this) {
            case BLANK:
                return "BLANK";
            case ACTIVE:
                return "ACTIVE";
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
            case "ACTIVE":
                return ACTIVE;
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
