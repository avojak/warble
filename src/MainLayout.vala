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
            //  width_request: 450,
            //  height_request: 625
        );
    }

    construct {
        header_bar = create_header_bar ();
        //  header_bar.get_style_context ().add_class ("default-decoration");
        //  header_bar.gameplay_statistics_menu_item_clicked.connect (() => {
        //      show_gameplay_statistics_dialog ();
        //  });

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

        //  var key_event_controller = new Gtk.EventControllerKey ();
        //  key_event_controller.key_pressed.connect (on_key_pressed_event);
        //  this.add_controller (key_event_controller);

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
            //  decoration_layout = Gtk.Settings.get_default ().gtk_decoration_layout.replace ("maximize", "").replace ("minimize", ""),
            hexpand = true
        };

        header_bar.get_style_context ().add_class ("titlebar");
        header_bar.get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);
        header_bar.get_style_context ().add_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        //  var difficulty_button = new Granite.Widgets.ModeButton () {
        //      margin = 12
        //  };
        //  difficulty_button.mode_added.connect ((index, widget) => {
        //      widget.set_tooltip_markup (((Warble.Models.Difficulty) index).get_details_markup ());
        //  });
        //  difficulty_button.append_text (Warble.Models.Difficulty.EASY.get_display_string ());
        //  difficulty_button.append_text (Warble.Models.Difficulty.NORMAL.get_display_string ());
        //  difficulty_button.append_text (Warble.Models.Difficulty.HARD.get_display_string ());
        //  Warble.Application.settings.bind ("difficulty", difficulty_button, "selected", GLib.SettingsBindFlags.DEFAULT);

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

        var new_game_menu_item = new Gtk.Button ();
        new_game_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        new_game_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME;
        new_game_menu_item.child = new_game_accellabel;

        var gameplay_stats_menu_item = new Gtk.Button ();
        gameplay_stats_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        gameplay_stats_menu_item.child = new Granite.AccelLabel (_("Gameplay Statistics…"));

        var high_contrast_button = new Granite.SwitchModelButton (_("High Contrast Mode"));
        high_contrast_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var help_accellabel = new Granite.AccelLabel.from_action_name (
            _("Help"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP
        );

        var help_menu_item = new Gtk.Button ();
        help_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        help_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP;
        help_menu_item.child = help_accellabel;

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.Button ();
        quit_menu_item.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        quit_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT;
        quit_menu_item.child = quit_accellabel;

        var menu_popover_grid = new Gtk.Grid ();
        menu_popover_grid.margin_top = 3;
        menu_popover_grid.margin_bottom = 3;
        menu_popover_grid.orientation = Gtk.Orientation.VERTICAL;
        menu_popover_grid.width_request = 200;
        menu_popover_grid.attach (difficulty_button_box, 0, 0, 3, 1);
        menu_popover_grid.attach (new_game_menu_item, 0, 1, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 2, 1, 1);
        menu_popover_grid.attach (gameplay_stats_menu_item, 0, 3, 1, 1);
        menu_popover_grid.attach (high_contrast_button, 0, 4, 1, 1);
        menu_popover_grid.attach (help_menu_item, 0, 5, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 6, 1, 1);
        menu_popover_grid.attach (quit_menu_item, 0, 7, 1, 1);

        var menu_popover = new Gtk.Popover () {
            autohide = true
        };
        menu_popover.child = menu_popover_grid;

        var menu_button = new Gtk.MenuButton ();
        menu_button.icon_name = "open-menu-symbolic";
        menu_button.tooltip_text = _("Menu");
        menu_button.has_frame = false;
        menu_button.valign = Gtk.Align.CENTER;
        menu_button.popover = menu_popover;

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
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = 3;
        menu_separator.margin_bottom = 3;
        return menu_separator;
    }

    public bool on_key_pressed_event (Gtk.EventControllerKey controller, uint keyval, uint keycode, Gdk.ModifierType state) {
        if (keyval == Gdk.Key.Escape) {
            //  set_focus (null);
        }
        if (keyval == Gdk.Key.Return) {
            return_pressed ();
            return false;
        }
        if (keyval == Gdk.Key.BackSpace) {
            //  set_focus (null);
            backspace_pressed ();
            return false;
        }
        //  Gdk.keyval_name (keyval);
        //  Gdk.Display.get_default ().get_default_seat ().get_keyboard ();
        //  var event = controller.get_current_event () as Gdk.KeyEvent;
        char letter = ((char) Gdk.keyval_to_unicode (keyval)).toupper ();
        //  char letter = event_key.str.up ()[0];
        if (Warble.Application.alphabet.contains (letter)) {
            //  set_focus (null);
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
        //  int result = dialog.run ();
        //  dialog.close ();
    }

}
