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

 public class Warble.Widgets.Dialogs.RulesDialog : Granite.Dialog {

    public RulesDialog (Warble.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: "How to Play Warble",
            transient_for: main_window,
            modal: true,
            width_request: 300,
            hexpand: false
        );
    }

    construct {
        var body = get_content_area ();

        // Create the header
        var header_title = new Gtk.Label ("How to Play");
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.CENTER;
        header_title.hexpand = true;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);

        var header_grid = create_grid ();
        header_grid.attach (header_title, 0, 0);

        // Create the main rules body
        var rules_grid = create_grid ();
        rules_grid.attach (new Gtk.Label ("Figure out the word before your guesses run out!"), 0, 0);
        rules_grid.attach (new Gtk.Label ("As you type, the squares on the board will be filled in."), 0, 1);

        // Explain the keys
        var accelerator_grid = create_grid ();
        accelerator_grid.attach (new Granite.AccelLabel ("Undo a typed letter", "Delete"), 0, 2);
        accelerator_grid.attach (new Granite.AccelLabel ("Submit your guess", "Return"), 0, 3);

        // Explain the color changes
        var square_colors_grid = create_grid ();
        square_colors_grid.attach (create_label ("If you guess a letter in its correct position, the square will turn green."), 0, 0);
        square_colors_grid.attach (create_label ("If the letter does not appear anywhere in the answer, the square will turn dark grey."), 0, 1);
        square_colors_grid.attach (create_label ("If the letter appears in the answer but not in the position that you have guessed, the square will turn yellow."), 0, 2);
        square_colors_grid.attach (create_word_grid (), 0, 3);

        var key_colors_grid = create_grid ();
        key_colors_grid.attach (create_label ("The keys on the keyboard at the bottom of the screen will similarly change colors to help you keep track of which letters have been used."), 0, 0, 3, 1);

        body.add (header_grid);
        body.add (rules_grid);
        body.add (accelerator_grid);
        body.add (create_separator ());
        body.add (square_colors_grid);
        body.add (key_colors_grid);

        // Add action buttons
        var start_button = new Gtk.Button.with_label (_("Let's Get Started!"));
        start_button.get_style_context ().add_class ("suggested-action");
        start_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (start_button, 1);
    }

    private Gtk.Grid create_grid () {
        return new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            row_spacing = 8
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

    private Gtk.Label create_label (string text) {
        return new Gtk.Label (text) {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 50,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
    }

    private Gtk.Grid create_word_grid () {
        var grid = create_grid ();
        grid.attach (new Warble.Widgets.Square () {
            letter = 'T',
            state = Warble.Models.State.CORRECT
        }, 0, 0);
        grid.attach (new Warble.Widgets.Square () {
            letter = 'R',
            state = Warble.Models.State.CORRECT
        }, 1, 0);
        grid.attach (new Warble.Widgets.Square () {
            letter = 'A',
            state = Warble.Models.State.INCORRECT
        }, 2, 0);
        grid.attach (new Warble.Widgets.Square () {
            letter = 'I',
            state = Warble.Models.State.INCORRECT
        }, 3, 0);
        grid.attach (new Warble.Widgets.Square () {
            letter = 'N',
            state = Warble.Models.State.CLOSE
        }, 4, 0);
        return grid;
    }

}
