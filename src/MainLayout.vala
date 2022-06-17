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

public class Warble.MainLayout : Gtk.Grid {

    private const int NUM_ROWS = 6;
    private const int NUM_COLS = 5;

    public unowned Warble.MainWindow window { get; construct; }

    private Warble.Widgets.Dialogs.WelcomeDialog? welcome_dialog = null;
    private Warble.Widgets.Dialogs.RulesDialog? rules_dialog = null;
    private Warble.Widgets.Dialogs.VictoryDialog? victory_dialog = null;
    private Warble.Widgets.Dialogs.DefeatDialog? defeat_dialog = null;
    private Warble.Widgets.Dialogs.NewGameConfirmationDialog? new_game_confirmation_dialog = null;
    private Warble.Widgets.Dialogs.GameplayStatisticsDialog? gameplay_statistics_dialog = null;

    private Warble.Widgets.HeaderBar header_bar;
    private Gtk.Overlay overlay;
    private Granite.Toast insufficient_letters_toast;
    private Granite.Toast invalid_word_toast;
    private Granite.Toast must_use_clues_toast;
    private Granite.Toast submit_guess_toast;
    private Warble.Widgets.GameArea game_area;

    public MainLayout (Warble.MainWindow window) {
        Object (
            window: window,
            width_request: 450,
            height_request: 625
        );
    }

    construct {
        header_bar = new Warble.Widgets.HeaderBar ();
        header_bar.get_style_context ().add_class ("default-decoration");
        header_bar.gameplay_statistics_menu_item_clicked.connect (() => {
            show_gameplay_statistics_dialog ();
        });

        overlay = new Gtk.Overlay ();

        insufficient_letters_toast = new Granite.Toast (_("Not enough letters!"));
        invalid_word_toast = new Granite.Toast (_("That's not a word!"));
        must_use_clues_toast = new Granite.Toast ("");
        submit_guess_toast = new Granite.Toast ("Press \"Enter\" to submit your guess!");

        game_area = new Warble.Widgets.GameArea ();
        game_area.insufficient_letters.connect (() => {
            insufficient_letters_toast.send_notification ();
        });
        game_area.invalid_word.connect (() => {
            invalid_word_toast.send_notification ();
        });
        game_area.unused_clues.connect ((message) => {
            must_use_clues_toast.title = message;
            must_use_clues_toast.send_notification ();
        });
        game_area.game_won.connect (() => {
            show_victory_dialog ();
        });
        game_area.game_lost.connect ((answer) => {
            show_defeat_dialog (answer);
        });
        game_area.prompt_submit_guess.connect (() => {
            submit_guess_toast.send_notification ();
        });

        overlay.add_overlay (game_area);
        overlay.add_overlay (insufficient_letters_toast);
        overlay.add_overlay (invalid_word_toast);
        overlay.add_overlay (must_use_clues_toast);
        overlay.add_overlay (submit_guess_toast);

        attach (header_bar, 0, 0);
        attach (overlay, 0, 1);

        // When the user changes the difficulty, prompt them if in the middle of the game,
        // because changing the difficulty starts a new game and will register as a loss
        // if they are in the middle of a game.
        Warble.Application.settings.changed.connect ((key) => {
            if (key == "difficulty") {
                var current_difficulty = (int) game_area.difficulty;
                var new_difficulty = Warble.Application.settings.get_int ("difficulty");
                if (current_difficulty == new_difficulty) {
                    return;
                }
                if (!game_area.can_safely_start_new_game ()) {
                    Idle.add (() => {
                        var dialog = new Warble.Widgets.Dialogs.DifficultyChangeWarningDialog (window);
                        int result = dialog.run ();
                        dialog.close ();
                        // Either start a new game, or revert the difficulty
                        if (result == Gtk.ResponseType.OK) {
                            game_area.new_game (true);
                        } else {
                            Warble.Application.settings.set_int ("difficulty", current_difficulty);
                        }
                        return false;
                    });
                } else {
                    game_area.new_game ();
                }
            }
        });

        check_first_launch ();
    }

    private void check_first_launch () {
        // Show the rules dialog on the first launch of the game
        if (Warble.Application.settings.get_boolean ("first-launch")) {
            Idle.add (() => {
                show_welcome_dialog ();
                return false;
            });
            Warble.Application.settings.set_boolean ("first-launch", false);
        }
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

    public void show_rules () {
        show_rules_dialog ();
    }

    public void new_game () {
        // Don't do anything if these other dialogs are open
        if (rules_dialog != null || victory_dialog != null || defeat_dialog != null) {
            return;
        }
        // If we can safely start a new game, don't need to prompt the user
        if (game_area.can_safely_start_new_game ()) {
            game_area.new_game ();
            return;
        }
        if (new_game_confirmation_dialog == null) {
            new_game_confirmation_dialog = new Warble.Widgets.Dialogs.NewGameConfirmationDialog (window);
            new_game_confirmation_dialog.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.OK) {
                    game_area.new_game (true);
                }
                new_game_confirmation_dialog.close ();
            });
            new_game_confirmation_dialog.destroy.connect (() => {
                new_game_confirmation_dialog = null;
            });
        }
        new_game_confirmation_dialog.present ();
    }

    private void show_welcome_dialog () {
        if (welcome_dialog == null) {
            welcome_dialog = new Warble.Widgets.Dialogs.WelcomeDialog (window);
            welcome_dialog.destroy.connect (() => {
                welcome_dialog = null;
            });
        }
        welcome_dialog.present ();
    }

    private void show_rules_dialog () {
        if (rules_dialog == null) {
            rules_dialog = new Warble.Widgets.Dialogs.RulesDialog (window);
            rules_dialog.destroy.connect (() => {
                rules_dialog = null;
            });
        }
        rules_dialog.present ();
    }

    private void show_victory_dialog () {
        if (victory_dialog == null) {
            victory_dialog = new Warble.Widgets.Dialogs.VictoryDialog (window);
            victory_dialog.play_again_button_clicked.connect (() => {
                victory_dialog.close ();
                game_area.new_game ();
            });
            victory_dialog.destroy.connect (() => {
                victory_dialog = null;
            });
        }
        victory_dialog.present ();
    }

    private void show_defeat_dialog (string answer) {
        if (defeat_dialog == null) {
            defeat_dialog = new Warble.Widgets.Dialogs.DefeatDialog (window, answer);
            defeat_dialog.play_again_button_clicked.connect (() => {
                defeat_dialog.close ();
                game_area.new_game ();
            });
            defeat_dialog.destroy.connect (() => {
                defeat_dialog = null;
            });
        }
        defeat_dialog.present ();
    }

    private void show_gameplay_statistics_dialog () {
        if (gameplay_statistics_dialog == null) {
            gameplay_statistics_dialog = new Warble.Widgets.Dialogs.GameplayStatisticsDialog (window);
            gameplay_statistics_dialog.reset_button_clicked.connect (() => {
                gameplay_statistics_dialog.close ();
                Idle.add (() => {
                    show_reset_gameplay_statistics_warning_dialog ();
                    return false;
                });
            });
            gameplay_statistics_dialog.destroy.connect (() => {
                gameplay_statistics_dialog = null;
            });
        }
        gameplay_statistics_dialog.present ();
    }

    private void show_reset_gameplay_statistics_warning_dialog () {
        var dialog = new Warble.Widgets.Dialogs.ResetGameplayStatisticsWarningDialog (window);
        int result = dialog.run ();
        dialog.close ();
        if (result == Gtk.ResponseType.OK) {
            game_area.reset_gameplay_statistics ();
        }
        Idle.add (() => {
            show_gameplay_statistics_dialog ();
            return false;
        });
    }

}
