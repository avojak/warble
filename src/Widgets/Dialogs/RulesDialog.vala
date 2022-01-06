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
        var header_grid = new Gtk.Grid () {
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 30,
            column_spacing = 10
        };

        var header_title = new Gtk.Label ("🤔️ How to Play");
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.CENTER;
        header_title.hexpand = true;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);

        header_grid.attach (header_title, 0, 0);

        // Create the main rules body
        var rules_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 8
        };

        rules_grid.attach (new Gtk.Label ("Guess the 5-letter word in 6 guesses or less!"), 0, 0);
        rules_grid.attach (new Gtk.Label ("As you type, the squares on the board will be filled in."), 0, 1);

        // Explain the keys
        var accelerator_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            margin_start = 30,
            margin_end = 30,
            column_spacing = 10,
            row_spacing = 8,
            hexpand = false
        };

        accelerator_grid.attach (new Granite.AccelLabel ("Undo a typed letter", "Delete"), 0, 2);
        accelerator_grid.attach (new Granite.AccelLabel ("Submit your guess", "Return"), 0, 3);

        // Explain the color changes
        var square_colors_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 8
        };
        square_colors_grid.attach (new Gtk.Label ("If you guess a letter in its correct position, the square will turn green.") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 30,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        }, 0, 0);
        square_colors_grid.attach (new Warble.Widgets.Square () {
            letter = 'A',
            state = Warble.Widgets.Square.State.CORRECT
        }, 1, 0);
        square_colors_grid.attach (new Gtk.Label ("If the letter does not appear anywhere in the answer, the square will turn dark grey.") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 30,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        }, 0, 1);
        square_colors_grid.attach (new Warble.Widgets.Square () {
            letter = 'B',
            state = Warble.Widgets.Square.State.INCORRECT
        }, 1, 1);
        square_colors_grid.attach (new Gtk.Label ("If the letter appears in the answer but not in the position that you have guessed, the square will turn yellow.") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 30,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        }, 0, 2);
        square_colors_grid.attach (new Warble.Widgets.Square () {
            letter = 'C',
            state = Warble.Widgets.Square.State.CLOSE
        }, 1, 2);

        var key_colors_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 8
        };
        key_colors_grid.attach (new Gtk.Label ("The keys on the keyboard will similarly change colors to help you keep track of which letters have been used.") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            max_width_chars = 40,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        }, 0, 0, 3, 1);
        key_colors_grid.attach (new Warble.Widgets.Key ('A') {
            state = Warble.Widgets.Key.State.CORRECT
        }, 0, 1, 1, 1);
        key_colors_grid.attach (new Warble.Widgets.Key ('B') {
            state = Warble.Widgets.Key.State.INCORRECT
        }, 1, 1, 1, 1);
        key_colors_grid.attach (new Warble.Widgets.Key ('C') {
            state = Warble.Widgets.Key.State.CLOSE
        }, 2, 1, 1, 1);

        body.add (header_grid);
        body.add (rules_grid);
        body.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_start = 30,
            margin_end = 30,
            margin_top = 10,
            margin_bottom = 10
        });
        body.add (square_colors_grid);
        body.add (key_colors_grid);
        body.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_start = 30,
            margin_end = 30,
            margin_top = 10,
            margin_bottom = 10
        });
        body.add (accelerator_grid);

        // Add action buttons
        var start_button = new Gtk.Button.with_label (_("Let's Get Started!"));
        start_button.get_style_context ().add_class ("suggested-action");
        start_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (start_button, 1);
    }

}
