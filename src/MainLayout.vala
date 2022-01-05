/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Warble.MainLayout : Gtk.Grid {

    private const int NUM_ROWS = 6;
    private const int NUM_COLS = 5;

    public unowned Warble.MainWindow window { get; construct; }

    private Warble.Widgets.HeaderBar header_bar;
    private Gtk.Overlay overlay;
    private Granite.Widgets.Toast insufficient_letters_toast;
    private Granite.Widgets.Toast invalid_word_toast;
    private Warble.Widgets.GameArea game_area;

    public MainLayout (Warble.MainWindow window) {
        Object (
            window: window,
            width_request: 500,
            height_request: 550
        );
    }

    construct {
        header_bar = new Warble.Widgets.HeaderBar ();
        header_bar.get_style_context ().add_class ("default-decoration");

        overlay = new Gtk.Overlay ();

        insufficient_letters_toast = new Granite.Widgets.Toast (_("Not enough letters!"));
        invalid_word_toast = new Granite.Widgets.Toast (_("That's not a word!"));

        game_area = new Warble.Widgets.GameArea (NUM_ROWS, NUM_COLS);
        game_area.insufficient_letters.connect (() => {
            insufficient_letters_toast.send_notification ();
        });
        game_area.invalid_word.connect (() => {
            invalid_word_toast.send_notification ();
        });

        overlay.add_overlay (game_area);
        overlay.add_overlay (insufficient_letters_toast);
        overlay.add_overlay (invalid_word_toast);

        attach (header_bar, 0, 0);
        attach (overlay, 0, 1);
        
        show_all ();
    }

    public void letter_key_pressed (char letter) {
        game_area.letter_key_pressed (letter);
    }

    public void backspace_pressed () {
        game_area.backspace_pressed ();
    }

    public void return_pressed () {
        game_area.return_pressed ();
    }

}