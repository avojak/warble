/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.MainLayout : Gtk.Grid {

    private const int NUM_ROWS = 6;
    private const int NUM_COLS = 5;

    public unowned Warble.MainWindow window { get; construct; }

    private Adw.HeaderBar header_bar;
    private Gtk.Stack stack;
    private Gtk.Overlay game_area_overlay;
    //  private Gtk.Revealer rules_revealer;
    private Gtk.Revealer endgame_revealer;
    private Gtk.Revealer statistics_revealer;
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
        //  rules_revealer = new Gtk.Revealer () {
        //      transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
        //      transition_duration = 500,
        //      hexpand = true,
        //      vexpand = true
        //  };
        //  rules_revealer.child = new Warble.Widgets.Rules ();
        endgame_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 500,
            hexpand = true,
            vexpand = true
        };
        //  endgame_revealer.visible = false;
        //  endgame_revealer.hide ();

        statistics_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 500,
            hexpand = true,
            vexpand = true
        };
        //  statistics_revealer.visible = false;
        //  statistics_revealer.hide ();

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
        game_area.game_won.connect ((answer) => {
            show_victory_view (answer);
        });
        game_area.game_lost.connect ((answer) => {
            show_defeat_view (answer);
        });
        game_area.prompt_submit_guess.connect (() => {
            submit_guess_toast.send_notification ();
        });

        game_area_overlay = new Gtk.Overlay ();
        game_area_overlay.add_controller (new Gtk.GestureClick ());
        game_area_overlay.child = game_area;
        game_area_overlay.add_overlay (insufficient_letters_toast);
        game_area_overlay.add_overlay (invalid_word_toast);
        game_area_overlay.add_overlay (must_use_clues_toast);
        game_area_overlay.add_overlay (submit_guess_toast);
        //  overlay.add_overlay (rules_revealer);
        //  game_area_overlay.add_overlay (endgame_revealer);
        //  game_area_overlay.add_overlay (statistics_revealer);

        var rules_view = new Warble.View.RulesView ();
        rules_view.continue_game.connect (() => {
            toggle_rules ();
        });

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN
        };
        stack.add_named (rules_view, "rules");
        stack.add_named (game_area_overlay, "game-area");
        stack.set_visible_child_name ("game-area");

        header_bar = create_header_bar ();

        attach (header_bar, 0, 0);
        attach (stack, 0, 1);

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

        var difficulty_button_group = new Warble.Widgets.CheckButtonGroup (Gtk.Orientation.VERTICAL, 12) {
            margin_top = margin_bottom = margin_start = margin_end = 12
        };
        difficulty_button_group.prepend (new Gtk.Label (_("<b>Difficulty</b>")) {
            halign = Gtk.Align.START,
            use_markup = true,
            sensitive = false
        });
        difficulty_button_group.button_added.connect ((index, button) => {
            button.set_tooltip_markup (((Warble.Models.Difficulty) index).get_details_markup ());
            // When the user changes the difficulty, prompt them if in the middle of the game,
            // because changing the difficulty starts a new game and will register as a loss
            // if they are in the middle of a game.
            button.notify["active"].connect (() => {
                if (button.active) {
                    var current_difficulty = (int) game_area.difficulty;
                    var new_difficulty = index;
                    if (current_difficulty == new_difficulty) {
                        return;
                    }
                    if (game_area.can_safely_start_new_game ()) {
                        Warble.Application.settings.set_int ("difficulty", new_difficulty);
                        game_area.new_game ();
                        return;
                    }
                    var dialog = new Warble.Widgets.Dialogs.DifficultyChangeWarningDialog (window);
                    dialog.response.connect ((response_id) => {
                        if (response_id == Gtk.ResponseType.DELETE_EVENT) {
                            return;
                        } else if (response_id == Gtk.ResponseType.OK) {
                            Warble.Application.settings.set_int ("difficulty", new_difficulty);
                            game_area.new_game (true);
                        } else {
                            difficulty_button_group.set_active (current_difficulty);
                        }
                        dialog.close ();
                    });
                    dialog.present ();

                }
            });
        });
        difficulty_button_group.append_label (Warble.Models.Difficulty.EASY.get_display_string ());
        difficulty_button_group.append_label (Warble.Models.Difficulty.NORMAL.get_display_string ());
        difficulty_button_group.append_label (Warble.Models.Difficulty.HARD.get_display_string ());

        difficulty_button_group.set_active (Warble.Application.settings.get_int ("difficulty"));

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
            _("Show/Hide Rules"),
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
        menu_popover_grid.attach (difficulty_button_group, 0, 0, 3, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 1, 1, 1);
        menu_popover_grid.attach (new_game_menu_item, 0, 2, 1, 1);
        menu_popover_grid.attach (gameplay_stats_menu_item, 0, 3, 1, 1);
        menu_popover_grid.attach (high_contrast_button, 0, 4, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 5, 1, 1);
        menu_popover_grid.attach (help_menu_item, 0, 6, 1, 1);
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
        if (stack.get_visible_child_name () != "game-area") {
            return false;
        }
        if (keyval == Gdk.Key.Return) {
            game_area.return_pressed ();
            return false;
        }
        if (keyval == Gdk.Key.BackSpace) {
            game_area.backspace_pressed ();
            return false;
        }
        char letter = ((char) Gdk.keyval_to_unicode (keyval)).toupper ();
        if (Warble.Application.alphabet.contains (letter)) {
            game_area.letter_key_pressed (letter);
            return false;
        }
        return true;
    }

    private void check_first_launch () {
        // Show the rules dialog on the first launch of the game
        if (Warble.Application.settings.get_boolean ("first-launch")) {
            Idle.add (() => {
                new Warble.Widgets.Dialogs.WelcomeDialog (window).present ();
                return false;
            });
            Warble.Application.settings.set_boolean ("first-launch", false);
        }
    }

    public void toggle_rules () {
        if (stack.get_visible_child_name () == "rules") {
            //  stack.set_transition_type (Gtk.StackTransitionType.SLIDE_UP);
            stack.set_visible_child_name ("game-area");
        } else {
            //  stack.set_transition_type (Gtk.StackTransitionType.SLIDE_DOWN);
            stack.set_visible_child_name ("rules");
        }
    }

    public void new_game () {
        hide_revealers ();
        stack.set_visible_child_name ("game-area");
        // If we can safely start a new game, don't need to prompt the user
        if (game_area.can_safely_start_new_game ()) {
            game_area.new_game ();
            return;
        }
        var new_game_confirmation_dialog = new Warble.Widgets.Dialogs.NewGameConfirmationDialog (window);
        new_game_confirmation_dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.OK) {
                game_area.new_game (true);
            }
            new_game_confirmation_dialog.close ();
        });
        new_game_confirmation_dialog.present ();
    }

    private void hide_revealers () {
        statistics_revealer.set_reveal_child (false);
        endgame_revealer.set_reveal_child (false);

        game_area_overlay.remove_overlay (statistics_revealer);
        game_area_overlay.remove_overlay (endgame_revealer);

        game_area.get_style_context ().remove_class ("faded");
    }

    private void show_victory_view (string answer) {
        //  var dialog = new Warble.Widgets.Dialogs.VictoryDialog (window);
        //  dialog.play_again_button_clicked.connect (() => {
        //      dialog.close ();
        //      game_area.new_game ();
        //  });
        //  dialog.present ();

        game_area.get_style_context ().add_class ("faded");
        var endgame_view = new Warble.View.EndgameView.for_victory (answer);
        endgame_view.response.connect ((response_id) => {
            endgame_revealer.set_reveal_child (false);
            game_area.get_style_context ().remove_class ("faded");
            if (response_id == Gtk.ResponseType.YES) {
                game_area.new_game ();
            }
        });
        game_area_overlay.add_overlay (endgame_revealer);
        endgame_revealer.child = endgame_view;
        endgame_revealer.set_reveal_child (true);
        //  stack.add_named (new Warble.View.EndgameView.for_victory (answer), "endgame-view");
        //  stack.set_visible_child_full ("endgame-view", Gtk.StackTransitionType.CROSSFADE);
    }

    private void show_defeat_view (string answer) {
        //  var dialog = new Warble.Widgets.Dialogs.DefeatDialog (window, answer);
        //  dialog.play_again_button_clicked.connect (() => {
        //      dialog.close ();
        //      game_area.new_game ();
        //  });
        //  dialog.present ();

        game_area.get_style_context ().add_class ("faded");
        var endgame_view = new Warble.View.EndgameView.for_defeat (answer);
        endgame_view.response.connect ((response_id) => {
            hide_revealers ();
            if (response_id == Gtk.ResponseType.YES) {
                game_area.new_game ();
            }
        });
        game_area_overlay.add_overlay (endgame_revealer);
        endgame_revealer.child = endgame_view;
        endgame_revealer.set_reveal_child (true);
    }

    private void show_gameplay_statistics_dialog () {
        game_area.get_style_context ().add_class ("faded");
        game_area_overlay.add_overlay (statistics_revealer);
        statistics_revealer.child = new Warble.View.GameplayStatisticsView ();
        statistics_revealer.set_reveal_child (true);
        //  var dialog = new Warble.Widgets.Dialogs.GameplayStatisticsDialog (window);
        //  dialog.reset_button_clicked.connect (() => {
        //      dialog.close ();
        //      Idle.add (() => {
        //          show_reset_gameplay_statistics_warning_dialog ();
        //          return false;
        //      });
        //  });
        //  dialog.present ();
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
