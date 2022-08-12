/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Rules : Gtk.Grid {

    construct {
        var explanation_grid = create_grid ();
        explanation_grid.attach (new Gtk.Label ("Figure out the word before your guesses run out!"), 0, 0);
        explanation_grid.attach (new Gtk.Label ("As you type, the squares on the board will be filled in."), 0, 1);

        // Explain the keys
        var accelerator_grid = create_grid ();
        accelerator_grid.attach (new Granite.AccelLabel ("Undo a typed letter", "Delete"), 0, 2);
        accelerator_grid.attach (new Granite.AccelLabel ("Submit your guess", "Return"), 0, 3);

        // Explain the color changes
        var square_colors_grid = create_grid ();
        square_colors_grid.attach (create_label ("The letter is in the correct position."), 0, 0);
        square_colors_grid.attach (new Warble.Widgets.Square () {
            letter = 'A',
            state = Warble.Models.State.CORRECT
        }, 1, 0);
        square_colors_grid.attach (create_label ("The letter does not appear anywhere in the answer."), 0, 1);
        square_colors_grid.attach (new Warble.Widgets.Square () {
            letter = 'B',
            state = Warble.Models.State.INCORRECT
        }, 1, 1);
        square_colors_grid.attach (create_label ("The letter appears in the answer, but not in the position that you have guessed."), 0, 2);
        square_colors_grid.attach (new Warble.Widgets.Square () {
            letter = 'C',
            state = Warble.Models.State.CLOSE
        }, 1, 2);

        var key_colors_grid = create_grid ();
        key_colors_grid.attach (new Gtk.Label ("The keys on the keyboard at the bottom of the screen will similarly change colors to help you keep track of which letters have been used.") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 45,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        }, 0, 0, 3, 1);

        attach (explanation_grid, 0, 0);
        attach (accelerator_grid, 0, 1);
        attach (create_separator (), 0, 2);
        attach (square_colors_grid, 0, 3);
        attach (key_colors_grid, 0, 4);
    }

    private Gtk.Grid create_grid () {
        return new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            row_spacing = 8,
            column_spacing = 10
        };
    }

    private Gtk.Label create_label (string text) {
        return new Gtk.Label (text) {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 35,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            hexpand = true
        };
    }

    private Gtk.Separator create_separator () {
        return new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_start = 30,
            margin_end = 30,
            margin_top = 10,
            margin_bottom = 10
        };
    }

}
