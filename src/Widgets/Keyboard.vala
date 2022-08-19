/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Keyboard : Gtk.Grid {

    public const char[] ROW_1_LETTERS = {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'};
    public const char[] ROW_2_LETTERS = {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'};
    public const char[] ROW_3_LETTERS = {'Z', 'X', 'C', 'V', 'B', 'N', 'M'};

    private Gee.Map<char, Warble.Widgets.Key> keys = new Gee.HashMap<char, Warble.Widgets.Key> ();

    public Keyboard () {
        Object (
            hexpand: true,
            vexpand: true,
            orientation: Gtk.Orientation.VERTICAL,
            halign: Gtk.Align.CENTER,
            valign: Gtk.Align.START,
            margin_start: 8,
            margin_end: 8,
            margin_top: 8,
            margin_bottom: 8,
            row_spacing: 8,
            column_spacing: 8
        );
    }

    construct {
        var row_1_grid = create_row (ROW_1_LETTERS);
        var row_2_grid = create_row (ROW_2_LETTERS);
        var row_3_grid = create_row (ROW_3_LETTERS, true);

        attach (row_1_grid, 0, 0);
        attach (row_2_grid, 0, 1);
        attach (row_3_grid, 0, 2);
    }

    private Gtk.Grid create_row (char[] letters, bool include_control_keys = false) {
        var row_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.END,
            hexpand = true,
            row_spacing = 8,
            column_spacing = 8
        };
        int col = 0;
        if (include_control_keys) {
            Warble.Widgets.ControlKey return_key = new Warble.Widgets.ControlKey.with_text ("Enter");
            return_key.clicked.connect (() => {
                return_key_clicked ();
            });
            row_grid.attach (return_key, col++, 0);
        }
        foreach (char letter in letters) {
            Warble.Widgets.Key key = new Warble.Widgets.Key (letter);
            key.clicked.connect ((letter) => {
                key_clicked (letter);
            });
            keys.set (letter, key);
            row_grid.attach (key, col++, 0);
        }
        if (include_control_keys) {
            Warble.Widgets.ControlKey backspace_key = new Warble.Widgets.ControlKey.with_icon ("edit-clear-symbolic");
            backspace_key.clicked.connect (() => {
                backspace_key_clicked ();
            });
            row_grid.attach (backspace_key, col++, 0);
        }
        return row_grid;
    }

    public Warble.Models.State get_key_state (char letter) {
        return keys.get (letter).state;
    }

    public void update_key_state (char letter, Warble.Models.State new_state) {
        keys.get (letter).state = new_state;
    }

    public signal void key_clicked (char letter);
    public signal void return_key_clicked ();
    public signal void backspace_key_clicked ();

}
