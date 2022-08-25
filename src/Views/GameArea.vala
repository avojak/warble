/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Views.GameArea : Gtk.Grid {

    public Warble.Models.Difficulty difficulty { get; set; }

    private int num_rows;
    private int num_cols;
    private bool must_use_clues;

    private Gee.List<Gee.List<Warble.Widgets.Square>> rows;

    private Gtk.Grid base_grid;
    private Warble.Widgets.Keyboard keyboard;

    private int current_row;
    private int current_col;
    private string answer;
    private bool is_game_in_progress;
    private uint? guess_timer_id = null;

    public GameArea () {
        Object (
            hexpand: true,
            vexpand: true,
            orientation: Gtk.Orientation.VERTICAL,
            halign: Gtk.Align.CENTER,
            margin_start: 8,
            margin_end: 8,
            margin_top: 8,
            margin_bottom: 8
        );
    }

    construct {
        initialize ();
    }

    public void new_game (bool should_record_loss = false) {
        // Current game is no longer in progress
        Warble.Application.settings.set_boolean ("is-game-in-progress", false);
        // Record a loss if we're interrupting a current game
        if (should_record_loss) {
            record_loss ();
        }
        dispose_ui ();
        initialize ();
    }

    private void initialize () {
        // Initialize the difficulty settings
        difficulty = (Warble.Models.Difficulty) Warble.Application.settings.get_int ("difficulty");
        debug ("Difficulty: %s", difficulty.get_display_string ());
        num_cols = difficulty.get_num_letters ();
        num_rows = difficulty.get_num_guesses ();
        must_use_clues = difficulty.must_use_clues ();

        if (should_restore_saved_state ()) {
            answer = Warble.Application.settings.get_string ("answer");
        } else {
            answer = Warble.Application.dictionary.get_random_word (num_cols);
        }
        debug ("Answer: %s", answer);

        setup_ui ();
        if (should_restore_saved_state ()) {
            load_squares_state ();
            load_keyboard_state ();
        }

        // Initialize game data
        if (should_restore_saved_state ()) {
            current_row = Warble.Application.settings.get_int ("current-row");
            current_col = Warble.Application.settings.get_int ("current-col");
        } else {
            current_row = 0;
            current_col = 0;
        }
        if (current_row < num_rows && current_col < num_cols) {
            rows.get (current_row).get (current_col).state = Warble.Models.State.ACTIVE;
        }
        is_game_in_progress = true;
    }

    private void setup_ui () {
        var square_grid = new Gtk.Grid () {
            margin_top = 8,
            margin_bottom = 8,
            margin_start = 8,
            margin_end = 8,
            hexpand = false,
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            row_spacing = 8,
            column_spacing = 8
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
        keyboard.key_clicked.connect (letter_key_pressed);
        keyboard.return_key_clicked.connect (return_pressed);
        keyboard.backspace_key_clicked.connect (backspace_pressed);

        base_grid = new Gtk.Grid () {
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.CENTER
        };
        base_grid.attach (square_grid, 0, 0);
        base_grid.attach (keyboard, 0, 1);

        attach (base_grid, 0, 0);
    }

    private void dispose_ui () {
        remove (base_grid);
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
        rows.get (current_row).get (current_col).state = Warble.Models.State.BLANK;
        rows.get (current_row).get (current_col).letter = letter;
        rows.get (current_row).get (current_col).queue_draw ();

        // Increment the column
        current_col++;
        if (current_col < num_cols) {
            rows.get (current_row).get (current_col).state = Warble.Models.State.ACTIVE;
        }

        // Update the saved state
        write_state ();

        // Check if row is full
        if (current_col == num_cols && Warble.Application.settings.get_boolean ("should-prompt-to-submit")) {
            start_guess_timer ();
        }
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

        // Cancel the timer (if present)
        stop_guess_timer ();

        // Decrement the column
        if (current_col < num_cols) {
            rows.get (current_row).get (current_col).state = Warble.Models.State.BLANK;
        }
        current_col--;
        rows.get (current_row).get (current_col).state = Warble.Models.State.ACTIVE;

        // Clear the square
        rows.get (current_row).get (current_col).letter = ' ';

        // Update the saved state
        write_state ();
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

        // Cancel the timer (if present)
        stop_guess_timer (true);

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
        if (current_row < num_rows) {
            rows.get (current_row).get (current_col).state = Warble.Models.State.ACTIVE;
        }

        // Check if game lost
        if (current_row == num_rows) {
            on_game_lost ();
        }

        // Update the saved state
        write_state ();
    }

    private void start_guess_timer () {
        if (guess_timer_id != null) {
            return;
        }
        guess_timer_id = GLib.Timeout.add (5000, () => {
            Warble.Application.settings.set_boolean ("should-prompt-to-submit", false);
            prompt_submit_guess ();
            guess_timer_id = null;
            return false;
        });
    }

    private void stop_guess_timer (bool should_disable_prompt = false) {
        if (guess_timer_id != null) {
            GLib.Source.remove (guess_timer_id);
            guess_timer_id = null;
        }
        // If the user pressed Enter, no need to prompt again
        if (should_disable_prompt) {
            Warble.Application.settings.set_boolean ("should-prompt-to-submit", false);
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

        // Check if all clues were used (depending on difficulty setting)
        if (must_use_clues && current_row > 0) {
            Gee.Map<char, int> close_guessed_letters = new Gee.HashMap<char, int> ();
            Gee.List<int> correct_indices = new Gee.ArrayList<int> ();
            for (int col_index = 0; col_index < num_cols; col_index++) {
                var prior_square = rows.get (current_row - 1).get (col_index);
                var current_square = rows.get (current_row).get (col_index);

                // If letter was previously found to be correct, it must be used in the same place again
                if (prior_square.state == Warble.Models.State.CORRECT) {
                    if (prior_square.letter != current_square.letter) {
                        unused_clues (_("The %s letter must be \"%s\"").printf (get_ordinal_string (col_index + 1),
                            prior_square.letter.to_string ()));
                        return false;
                    } else {
                        correct_indices.add (col_index);
                    }
                }

                // If the letter was close, save it for the second pass
                if (prior_square.state == Warble.Models.State.CLOSE) {
                    if (!close_guessed_letters.has_key (prior_square.letter)) {
                        close_guessed_letters.set (prior_square.letter, 0);
                    }
                    close_guessed_letters.set (prior_square.letter,
                        close_guessed_letters.get (prior_square.letter) + 1);
                }
            }

            // Update close_guessed_letters to find unused clues
            for (int col_index = 0; col_index < num_cols; col_index++) {
                if (correct_indices.contains (col_index)) {
                    continue;
                }
                var letter = rows.get (current_row).get (col_index).letter;
                if (close_guessed_letters.has_key (letter)) {
                    close_guessed_letters.set (letter, close_guessed_letters.get (letter) - 1);
                }
            }
            foreach (var entry in close_guessed_letters.entries) {
                if (entry.value > 0) {
                    // entry.key must be a guessed letter
                    unused_clues (_("\"%s\" must be a guessed letter").printf (entry.key.to_string ()));
                    return false;
                }
            }
        }
        return true;
    }

    // https://stackoverflow.com/a/13627586/3300205
    private string get_ordinal_string (int pos) {
        var j = pos % 10;
        var k = pos % 100;
        if (j == 1 && k != 11) {
            return _("%dst").printf (pos);
        }
        if (j == 2 && k != 12) {
            return _("%dnd").printf (pos);
        }
        if (j == 3 && k != 13) {
            return _("%drd").printf (pos);
        }
        return _("%dth").printf (pos);
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

        Gee.Map<int, Warble.Models.State> new_states = new Gee.HashMap<int, Warble.Models.State> ();

        // Do a first pass for correct guesses
        Gee.List<int> correct_indices = new Gee.ArrayList<int> ();
        for (int col_index = 0; col_index < num_cols; col_index++) {
            char current_letter = current_guess[col_index];
            // Correct place?
            if (current_letter == answer[col_index]) {
                new_states.set (col_index, Warble.Models.State.CORRECT);
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
                    new_states.set (col_index, Warble.Models.State.CLOSE);
                    letter_guess_counts.set (current_letter, letter_guess_counts.get (current_letter) - 1);
                } else {
                    new_states.set (col_index, Warble.Models.State.INCORRECT);
                }
            } else {
                new_states.set (col_index, Warble.Models.State.INCORRECT);
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
            if (old_state == Warble.Models.State.BLANK || old_state == Warble.Models.State.CLOSE) {
                keyboard.update_key_state (current_letter, Warble.Models.State.CORRECT);
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
                case Warble.Models.State.BLANK:
                    if (new_state == Warble.Models.State.INCORRECT) {
                        keyboard.update_key_state (current_letter, Warble.Models.State.INCORRECT);
                    } else if (new_state == Warble.Models.State.CLOSE) {
                        keyboard.update_key_state (current_letter, Warble.Models.State.CLOSE);
                    } else if (new_state == Warble.Models.State.CORRECT) {
                        keyboard.update_key_state (current_letter, Warble.Models.State.CORRECT);
                    }
                    break;
                case Warble.Models.State.CLOSE:
                    if (new_state == Warble.Models.State.CLOSE) {
                        keyboard.update_key_state (current_letter, Warble.Models.State.CLOSE);
                    } else if (new_state == Warble.Models.State.CORRECT) {
                        keyboard.update_key_state (current_letter, Warble.Models.State.CORRECT);
                    }
                    break;
                case Warble.Models.State.INCORRECT:
                case Warble.Models.State.CORRECT:
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

        // Update the saved state
        write_state ();

        // Update statistics
        increment_stat ("num-games-won");
        increment_stat ("win-streak");
        if (get_int_stat ("win-streak") > get_int_stat ("max-win-streak")) {
            set_int_stat ("max-win-streak", get_int_stat ("win-streak"));
        }
        increment_guess_distribution (num_guesses);

        // Call signals
        game_won (answer, num_guesses);
    }

    private void on_game_lost () {
        // Stop processing input
        is_game_in_progress = false;

        // Update the saved state
        write_state ();

        // Update statistics
        record_loss ();

        // Call signals
        game_lost (answer);
    }

    public void record_loss () {
        increment_stat ("num-games-lost");
        set_int_stat ("win-streak", 0);
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

    private void write_state () {
        if (is_game_in_progress && (current_row > 0 || current_col > 0)) {
            Warble.Application.settings.set_boolean ("is-game-in-progress", true);
            Warble.Application.settings.set_string ("answer", answer);
            Warble.Application.settings.set_string ("squares-state", create_squares_state ());
            Warble.Application.settings.set_string ("keyboard-state", create_keyboard_state ());
            Warble.Application.settings.set_int ("current-row", current_row);
            Warble.Application.settings.set_int ("current-col", current_col);
        } else {
            Warble.Application.settings.set_boolean ("is-game-in-progress", false);
            Warble.Application.settings.set_string ("answer", "");
            Warble.Application.settings.set_string ("squares-state", "");
            Warble.Application.settings.set_string ("keyboard-state", "");
            Warble.Application.settings.set_int ("current-row", 0);
            Warble.Application.settings.set_int ("current-col", 0);
        }
    }

    public void reset_gameplay_statistics () {
        set_int_stat ("num-games-won", 0);
        set_int_stat ("num-games-lost", 0);
        set_int_stat ("win-streak", 0);
        set_int_stat ("max-win-streak", 0);
        set_string_stat ("guess-distribution", "1:0|2:0|3:0|4:0|5:0|6:0");
    }

    private string create_squares_state () {
        var sb = new GLib.StringBuilder ();
        foreach (var row in rows) {
            foreach (var square in row) {
                sb.append ("%s:%s,".printf (square.letter.to_string (), square.state.get_short_name ()));
            }
            sb.erase (sb.str.length - 1, 1); // Trim trailing comma
            sb.append ("|");
        }
        sb.erase (sb.str.length - 1, 1); // Trim trailing pipe
        return sb.str;
    }

    private string create_keyboard_state () {
        var sb = new GLib.StringBuilder ();
        foreach (char letter in Warble.Widgets.Keyboard.ROW_1_LETTERS) {
            sb.append ("%s:%s,".printf (letter.to_string (), keyboard.get_key_state (letter).get_short_name ()));
        }
        foreach (char letter in Warble.Widgets.Keyboard.ROW_2_LETTERS) {
            sb.append ("%s:%s,".printf (letter.to_string (), keyboard.get_key_state (letter).get_short_name ()));
        }
        foreach (char letter in Warble.Widgets.Keyboard.ROW_3_LETTERS) {
            sb.append ("%s:%s,".printf (letter.to_string (), keyboard.get_key_state (letter).get_short_name ()));
        }
        sb.erase (sb.str.length - 1, 1); // Trim trailing comma
        return sb.str;
    }

    private void load_squares_state () {
        var data = Warble.Application.settings.get_string ("squares-state");
        var row_data = data.split ("|");
        for (int row_index = 0; row_index < row_data.length; row_index++) {
            var col_data = row_data[row_index].split (",");
            for (int col_index = 0; col_index < col_data.length; col_index++) {
                char letter = col_data[col_index].split (":")[0][0];
                var state = Warble.Models.State.get_value_by_short_name (col_data[col_index].split (":")[1]);
                rows.get (row_index).get (col_index).letter = letter;
                rows.get (row_index).get (col_index).state = state;
                rows.get (row_index).get (col_index).queue_draw ();
            }
        }
    }

    private void load_keyboard_state () {
        foreach (var data in Warble.Application.settings.get_string ("keyboard-state").split (",")) {
            char letter = data.split (":")[0][0];
            var state = Warble.Models.State.get_value_by_short_name (data.split (":")[1]);
            keyboard.update_key_state (letter, state);
        }
    }

    private bool should_restore_saved_state () {
        return Warble.Application.settings.get_boolean ("is-game-in-progress");
    }

    public signal void insufficient_letters ();
    public signal void invalid_word ();
    public signal void unused_clues (string message);
    public signal void game_won (string answer, int num_guesses);
    public signal void game_lost (string answer);
    public signal void prompt_submit_guess ();

}
