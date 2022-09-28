/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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
                return _("%s Difficulty: 5-letter words").printf (get_display_string ());
            case NORMAL:
                return _("%s Difficulty: 5-letter words\n<small>All correctly-guessed letters must be used in subsequent guesses</small>").printf (get_display_string ()); // vala-lint=line-length
            case HARD:
                return _("%s Difficulty: 6-letter words\n<small>All correctly-guessed letters must be used in subsequent guesses</small>").printf (get_display_string ()); // vala-lint=line-length
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
                return 6;
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
