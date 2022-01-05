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

public class Warble.Widgets.GameArea : Gtk.Grid {

    public int num_rows { get; construct; }
    public int num_cols { get; construct; }

    private Gee.List<Gee.List<Warble.Widgets.Square>> rows = new Gee.ArrayList<Gee.List<Warble.Widgets.Square>> ();

    private Gtk.Grid square_grid;
    private Warble.Widgets.Keyboard keyboard;

    private int current_row = 0;
    private int current_col = 0;

    private string word_of_the_day;

    public GameArea (int num_rows, int num_cols) {
        Object (
            expand: true,
            orientation: Gtk.Orientation.VERTICAL,
            halign: Gtk.Align.CENTER,
            margin: 8,
            num_rows: num_rows,
            num_cols: num_cols
        );
    }

    construct {
        // Grab the word now and hold it in case a game spans across midnight
        word_of_the_day = Warble.Application.dictionary.get_word_of_the_day (new GLib.DateTime.now_local (), num_cols);
        debug (word_of_the_day);

        square_grid = new Gtk.Grid () {
            margin = 8
        };
        for (int i = 0; i < num_rows; i++) {
            var row = new Gee.ArrayList<Warble.Widgets.Square> ();
            for (int j = 0; j < num_cols; j++) {
                Warble.Widgets.Square square = new Warble.Widgets.Square ();
                row.add (square);
                square_grid.attach (square, j, i);
            }
            rows.add (row);
        }

        keyboard = new Warble.Widgets.Keyboard ();

        attach (square_grid, 0, 0);
        attach (keyboard, 0, 1);
    }

    public void letter_key_pressed (char letter) {
        debug (letter.to_string ());
        // Make sure we're inbounds
        if (current_col >= num_cols || current_row >= num_rows) {
            return;
        }
        // Update the square
        rows.get (current_row).get (current_col).letter = letter;
        // Increment the column
        current_col++;
    }

    public void backspace_pressed () {
        debug ("Backspace");
        // Make sure we're inbounds
        if (current_col == 0) {
            return;
        }
        // Decrement the column
        current_col--;
        // Clear the square
        rows.get (current_row).get (current_col).letter = ' ';
    }

    public void return_pressed () {
        debug ("Return");
        // Make sure we're inbounds
        if (current_row >= num_rows) {
            return;
        }
        // Validate the row
        if (!validate_row (current_row)) {
            return;
        }
        // Increment the row and reset the column
        current_row++;
        current_col = 0;
    }

    private bool validate_row (int row_index) {
        GLib.StringBuilder sb = new GLib.StringBuilder ();
        foreach (var square in rows.get (row_index)) {
            sb.append_c (square.letter);
        }
        string current_word = sb.str.strip ();
        if (current_word.length < num_cols) {
            insufficient_letters ();
            return false;
        }
        if (!Warble.Application.dictionary.words_by_length.get (num_cols).contains (current_word)) {
            invalid_word ();
            return false;
        }
        for (int col_index = 0; col_index < num_cols; col_index++) {
            Warble.Widgets.Square square = rows.get (row_index).get (col_index);
            char current = square.letter;
            char correct = word_of_the_day[col_index];
            if (current == correct) {
                square.update_state (Warble.Widgets.Square.State.CORRECT);
                continue;
            }
            if (word_of_the_day.contains (current.to_string ())) {
                square.update_state (Warble.Widgets.Square.State.CLOSE);
                continue;
            }
            if (!word_of_the_day.contains (current.to_string ())) {
                square.update_state (Warble.Widgets.Square.State.INCORRECT);
                continue;
            }
        }
        return true;
    }

    public signal void insufficient_letters ();
    public signal void invalid_word ();

}
