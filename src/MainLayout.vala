/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
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

    private Adw.HeaderBar header_bar;
    private Gtk.Overlay overlay;
    private Granite.Toast insufficient_letters_toast;
    private Granite.Toast invalid_word_toast;
    private Granite.Toast must_use_clues_toast;
    private Granite.Toast submit_guess_toast;
    private Warble.Widgets.GameArea game_area;

    public MainLayout (Warble.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        header_bar = create_header_bar ();

        overlay = new Gtk.Overlay ();

        insufficient_letters_toast = new Granite.Toast (_("Not enough letters!"));
        invalid_word_toast = new Granite.Toast (_("That's not a word!"));
        must_use_clues_toast = new Granite.Toast ("");
        submit_guess_toast = new Granite.Toast (_("Press \"Enter\" to submit your guess!"));

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

        overlay.child = game_area;
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
                        dialog.response.connect ((response_id) => {
                            if (response_id == Gtk.ResponseType.OK) {
                                game_area.new_game (true);
                            } else {
                                Warble.Application.settings.set_int ("difficulty", current_difficulty);
                            }
                        });
                        //  int result = dialog.run ();
                        //  dialog.close ();
                        // Either start a new game, or revert the difficulty
                        //  if (result == Gtk.ResponseType.OK) {
                        //      game_area.new_game (true);
                        //  } else {
                        //      Warble.Application.settings.set_int ("difficulty", current_difficulty);
                        //  }
                        return false;
                    });
                } else {
                    game_area.new_game ();
                }
            }
        });

        check_first_launch ();
    }

    private Adw.HeaderBar create_header_bar () {
        var title_widget = new Gtk.Label (Constants.APP_NAME);
        title_widget.get_style_context ().add_class (Granite.STYLE_CLASS_TITLE_LABEL);
        var header_bar = new Adw.HeaderBar () {
            title_widget = title_widget,
            hexpand = true
        };

        header_bar.get_style_context ().add_class ("titlebar");
        header_bar.get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);
        header_bar.get_style_context ().add_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        var difficulty_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            homogeneous = true
        };
        difficulty_button_box.get_style_context ().add_class (Granite.STYLE_CLASS_LINKED);

        var easy_button = new Gtk.ToggleButton.with_label (Warble.Models.Difficulty.EASY.get_display_string ()) {
            tooltip_markup = Warble.Models.Difficulty.EASY.get_details_markup ()
        };
        var normal_button = new Gtk.ToggleButton.with_label (Warble.Models.Difficulty.NORMAL.get_display_string ()) {
            tooltip_markup = Warble.Models.Difficulty.NORMAL.get_details_markup (),
            group = easy_button
        };
        var hard_button = new Gtk.ToggleButton.with_label (Warble.Models.Difficulty.HARD.get_display_string ()) {
            tooltip_markup = Warble.Models.Difficulty.HARD.get_details_markup (),
            group = easy_button
        };

        difficulty_button_box.append (easy_button);
        difficulty_button_box.append (normal_button);
        difficulty_button_box.append (hard_button);

        var new_game_accellabel = new Granite.AccelLabel.from_action_name (
            _("New Game"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME
        );

        var new_game_menu_item = new Gtk.Button () {
            action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME,
            child = new_game_accellabel
        };
        new_game_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var gameplay_stats_menu_item = new Gtk.Button () {
            child = new Granite.AccelLabel (_("Gameplay Statistics…"))
        };
        gameplay_stats_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var high_contrast_button = new Granite.SwitchModelButton (_("High Contrast Mode"));
        high_contrast_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var help_accellabel = new Granite.AccelLabel.from_action_name (
            _("Help"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP
        );

        var help_menu_item = new Gtk.Button () {
            action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP,
            child = help_accellabel
        };
        help_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var about_accellabel = new Granite.AccelLabel ("About…", null);
        var about_menu_item = new Gtk.Button () {
            action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_ABOUT,
            child = about_accellabel
        };
        about_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.Button () {
            action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT,
            child = quit_accellabel
        };
        quit_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var menu_popover_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        menu_popover_grid.attach (difficulty_button_box, 0, 0, 3, 1);
        menu_popover_grid.attach (new_game_menu_item, 0, 1, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 2, 1, 1);
        menu_popover_grid.attach (gameplay_stats_menu_item, 0, 3, 1, 1);
        menu_popover_grid.attach (high_contrast_button, 0, 4, 1, 1);
        menu_popover_grid.attach (help_menu_item, 0, 5, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 6, 1, 1);
        menu_popover_grid.attach (about_menu_item, 0, 7, 1, 1);
        menu_popover_grid.attach (quit_menu_item, 0, 8, 1, 1);

        var menu_popover = new Gtk.Popover () {
            autohide = true,
            child = menu_popover_grid
        };
        //  menu_popover.add_css_class (Granite.STYLE_CLASS_MENU);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            tooltip_text = _("Menu"),
            has_frame = false,
            valign = Gtk.Align.CENTER,
            popover = menu_popover
        };

        header_bar.pack_end (menu_button);

        gameplay_stats_menu_item.clicked.connect (() => {
            show_gameplay_statistics_dialog ();
        });

        Warble.Application.settings.bind (
            "high-contrast-mode",
            high_contrast_button,
            "active",
            SettingsBindFlags.DEFAULT
        );

        return header_bar;
    }

    private Gtk.Separator create_menu_separator () {
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };
        return menu_separator;
    }

    public bool on_key_pressed_event (Gtk.EventControllerKey controller, uint keyval, uint keycode, Gdk.ModifierType state) {
        if (keyval == Gdk.Key.Return) {
            return_pressed ();
            return false;
        }
        if (keyval == Gdk.Key.BackSpace) {
            backspace_pressed ();
            return false;
        }
        char letter = ((char) Gdk.keyval_to_unicode (keyval)).toupper ();
        if (Warble.Application.alphabet.contains (letter)) {
            letter_key_pressed (letter);
            return false;
        }
        return true;
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
            new_game_confirmation_dialog.close.connect (() => {
                new_game_confirmation_dialog = null;
            });
        }
        new_game_confirmation_dialog.present ();
    }

    private void show_welcome_dialog () {
        if (welcome_dialog == null) {
            welcome_dialog = new Warble.Widgets.Dialogs.WelcomeDialog (window);
            welcome_dialog.close.connect (() => {
                welcome_dialog = null;
            });
        }
        welcome_dialog.present ();
    }

    private void show_rules_dialog () {
        if (rules_dialog == null) {
            rules_dialog = new Warble.Widgets.Dialogs.RulesDialog (window);
            rules_dialog.close.connect (() => {
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
            victory_dialog.close.connect (() => {
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
            defeat_dialog.close.connect (() => {
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
            gameplay_statistics_dialog.close.connect (() => {
                gameplay_statistics_dialog = null;
            });
        }
        gameplay_statistics_dialog.present ();
    }

    private void show_reset_gameplay_statistics_warning_dialog () {
        var dialog = new Warble.Widgets.Dialogs.ResetGameplayStatisticsWarningDialog (window);
        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.OK) {
                game_area.reset_gameplay_statistics ();
            }
            Idle.add (() => {
                show_gameplay_statistics_dialog ();
                return false;
            });
        });
    }

    public void show_about_dialog () {
        var about_dialog = new Gtk.AboutDialog () {
            authors = new string[] { "Andrew Vojak", null },
            copyright = "\xc2\xa9 2022 Andrew Vojak",
            license_type = Gtk.License.GPL_3_0,
            logo_icon_name = Constants.APP_ID,
            program_name = Constants.APP_NAME,
            version = Constants.VERSION,
            website = "https://github.com/avojak/warble",
            website_label = "Website",
            modal = true,
            transient_for = window
        };
        about_dialog.close_request.connect (() =>{
            about_dialog.close ();
            return false;
        });
        about_dialog.present ();
        about_dialog.set_focus (null);
    }

}
