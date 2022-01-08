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

public class Warble.Widgets.GameArea : Gtk.Grid {

    public int num_rows { get; construct; }
    public int num_cols { get; construct; }

    private Gee.List<Gee.List<Warble.Widgets.Square>> rows;

    private Gtk.Grid status_grid;
    private Gtk.Label status_label;
    private Gtk.Label answer_label;
    private Gtk.Grid square_grid;
    private Warble.Widgets.Keyboard keyboard;

    private int current_row;
    private int current_col;
    private string answer;
    private bool is_game_in_progress;

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
        initialize ();
    }

    public void new_game () {
        dispose_ui ();
        initialize ();
        show_all ();
    }

    private void initialize () {
        // Grab the word now and hold it in case a game spans across midnight
        //  answer = Warble.Application.dictionary.get_word_of_the_day (new GLib.DateTime.now_local (), num_cols);
        answer = Warble.Application.dictionary.get_random_word (num_cols);
        debug (answer);

        setup_ui ();

        // Initialize game data
        current_row = 0;
        current_col = 0;
        is_game_in_progress = true;
    }

    private void setup_ui () {
        status_grid = new Gtk.Grid () {
            margin = 8,
            halign = Gtk.Align.CENTER
        };
        status_label = new Gtk.Label ("");
        status_label.get_style_context ().add_class ("h2");
        answer_label = new Gtk.Label ("") {
            use_markup = true
        };
        status_grid.attach (status_label, 0, 0);
        status_grid.attach (answer_label, 0, 1);

        square_grid = new Gtk.Grid () {
            margin = 8
        };
        rows = new Gee.ArrayList<Gee.List<Warble.Widgets.Square>> ();
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

        attach (status_grid, 0, 0);
        attach (square_grid, 0, 1);
        attach (keyboard, 0, 2);
    }

    private void dispose_ui () {
        status_grid.dispose ();
        square_grid.dispose ();
        keyboard.dispose ();
    }

    public void letter_key_pressed (char letter) {
        // Check if there's actually a game in progress
        if (!is_game_in_progress) {
            return;
        }
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
        // Check if there's actually a game in progress
        if (!is_game_in_progress) {
            return;
        }
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
        // Check if there's actually a game in progress
        if (!is_game_in_progress) {
            return;
        }
        // Make sure we're inbounds
        if (current_row >= num_rows) {
            return;
        }
        // Get the current guess
        GLib.StringBuilder sb = new GLib.StringBuilder ();
        foreach (var square in rows.get (current_row)) {
            sb.append_c (square.letter);
        }
        string current_guess = sb.str.strip ();
        // Validate the guess
        if (!validate_guess (current_guess)) {
            return;
        }
        // Update the square and key states
        if (update_states (current_row, current_guess)) {
            on_game_won (current_row + 1);
            return;
        }
        // Increment the row and reset the column
        current_row++;
        current_col = 0;
        // Check if game lost
        if (current_row == num_rows) {
            on_game_lost ();
        }
    }

    // Determines if a new game can be started without warning the user
    public bool can_safely_start_new_game () {
        // If there's no game in progress, safe to start new
        if (!is_game_in_progress) {
            return true;
        }
        // If user is still on the first row, they haven't submitted a guess yet
        return current_row == 0;
    }

    private bool validate_guess (string current_guess) {
        // Check if there were enough letters guessed
        if (current_guess.length < num_cols) {
            insufficient_letters ();
            return false;
        }
        // Check if the guessed word is actually a word
        if (!Warble.Application.dictionary.is_word_in_dictionary (current_guess)) {
            invalid_word ();
            return false;
        }
        return true;
    }

    private bool update_states (int current_row, string current_guess) {
        // Maintain a map of how many times each letter is guessed for the current row
        Gee.Map<char, int> letter_guess_counts = new Gee.HashMap<char, int> ();
        for (int i = 0; i < answer.length; i++) {
            char c = answer[i];
            if (!letter_guess_counts.has_key (c)) {
                letter_guess_counts.set (c, 0);
            }
            letter_guess_counts.set (c, letter_guess_counts.get (c) + 1);
        }

        Gee.Map<int, Warble.Widgets.Square.State> new_states = new Gee.HashMap<int, Warble.Widgets.Square.State> ();

        // Do a first pass for correct guesses
        Gee.List<int> correct_indices = new Gee.ArrayList<int> ();
        for (int col_index = 0; col_index < num_cols; col_index++) {
            char current_letter = current_guess[col_index];
            // Correct place?
            if (current_letter == answer[col_index]) {
                new_states.set (col_index, Warble.Widgets.Square.State.CORRECT);
                letter_guess_counts.set (current_letter, letter_guess_counts.get (current_letter) - 1);
                correct_indices.add (col_index);
            }
        }

        // On the second pass, leverage prior guesses for better feedback on close and incorrect letters
        for (int col_index = 0; col_index < num_cols; col_index++) {
            // Don't re-check squares
            if (correct_indices.contains (col_index)) {
                continue;
            }
            char current_letter = current_guess[col_index];
            // Contains?
            if (answer.contains (current_letter.to_string ())) {
                // Remaining guesses?
                if (letter_guess_counts.get (current_letter) > 0) {
                    new_states.set (col_index, Warble.Widgets.Square.State.CLOSE);
                    letter_guess_counts.set (current_letter, letter_guess_counts.get (current_letter) - 1);
                } else {
                    new_states.set (col_index, Warble.Widgets.Square.State.INCORRECT);
                }
            } else {
                new_states.set (col_index, Warble.Widgets.Square.State.INCORRECT);
            }
        }

        // Update square states
        foreach (var entry in new_states.entries) {
            rows.get (current_row).get (entry.key).state = entry.value;
        }

        // Do a first pass for correct guesses
        foreach (var index in correct_indices) {
            char current_letter = current_guess[index];
            var old_state = keyboard.get_key_state (current_letter);
            if (old_state == Warble.Widgets.Key.State.BLANK || old_state == Warble.Widgets.Key.State.CLOSE) {
                keyboard.update_key_state (current_letter, Warble.Widgets.Key.State.CORRECT);
            }
        }

        // On the second pass, only look at incorrect guesses
        foreach (var entry in new_states.entries) {
            if (correct_indices.contains (entry.key)) {
                continue;
            }
            char current_letter = current_guess[entry.key];
            var old_state = keyboard.get_key_state (current_letter);
            var new_state = entry.value;
            switch (old_state) {
                case Warble.Widgets.Key.State.BLANK:
                    if (new_state == Warble.Widgets.Square.State.INCORRECT) {
                        keyboard.update_key_state (current_letter, Warble.Widgets.Key.State.INCORRECT);
                    } else if (new_state == Warble.Widgets.Square.State.CLOSE) {
                        keyboard.update_key_state (current_letter, Warble.Widgets.Key.State.CLOSE);
                    } else if (new_state == Warble.Widgets.Square.State.CORRECT) {
                        keyboard.update_key_state (current_letter, Warble.Widgets.Key.State.CORRECT);
                    }
                    break;
                case Warble.Widgets.Key.State.CLOSE:
                    if (new_state == Warble.Widgets.Square.State.CLOSE) {
                        keyboard.update_key_state (current_letter, Warble.Widgets.Key.State.CLOSE);
                    } else if (new_state == Warble.Widgets.Square.State.CORRECT) {
                        keyboard.update_key_state (current_letter, Warble.Widgets.Key.State.CORRECT);
                    }
                    break;
                case Warble.Widgets.Key.State.INCORRECT:
                case Warble.Widgets.Key.State.CORRECT:
                    // Nothing to do
                    break;
                default:
                    break;
            }
        }

        // Return true if victory condition
        return correct_indices.size == num_cols;
    }

    private void on_game_won (int num_guesses) {
        // Stop processing input
        is_game_in_progress = false;

        // Update UI
        status_label.set_text ("You win!");

        // Update statistics
        increment_stat ("num-games-won");
        increment_stat ("win-streak");
        if (get_int_stat ("win-streak") > get_int_stat ("max-win-streak")) {
            set_int_stat ("max-win-streak", get_int_stat ("win-streak"));
        }
        increment_guess_distribution (num_guesses);

        // Call signals
        game_won (num_guesses);
    }

    private void on_game_lost () {
        // Stop processing input
        is_game_in_progress = false;

        // Update UI
        status_label.set_text ("Game Over");
        answer_label.set_markup ("Answer: <b>%s</b>".printf (answer));

        // Update statistics
        increment_stat ("num-games-lost");
        set_int_stat ("win-streak", 0);

        // Call signals
        game_lost (answer);
    }

    private int get_int_stat (string name) {
        return Warble.Application.settings.get_int (name);
    }

    private void set_int_stat (string name, int value) {
        Warble.Application.settings.set_int (name, value);
    }

    private string get_string_stat (string name) {
        return Warble.Application.settings.get_string (name);
    }

    private void set_string_stat (string name, string value) {
        Warble.Application.settings.set_string (name, value);
    }

    private void increment_stat (string name) {
        set_int_stat (name, get_int_stat (name) + 1);
    }

    private void increment_guess_distribution (int num_guesses) {
        var distribution = get_string_stat ("guess-distribution");
        string[] counts = distribution.split ("|");
        int old_count = int.parse (counts[num_guesses - 1].split (":")[1]);
        counts[num_guesses - 1] = "%d:%d".printf (num_guesses, old_count + 1);
        var new_distribution = string.joinv ("|", counts);
        set_string_stat ("guess-distribution", new_distribution);
    }

    public signal void insufficient_letters ();
    public signal void invalid_word ();
    public signal void game_won (int num_guesses);
    public signal void game_lost (string answer);

}
