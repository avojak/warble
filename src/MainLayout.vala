/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.MainLayout : Gtk.Grid {

    private const int NUM_ROWS = 6;
    private const int NUM_COLS = 5;

    private const string STYLE_CLASS_TITLEBAR = "titlebar";
    private const string STYLE_CLASS_FADED = "faded";

    public unowned Warble.MainWindow window { get; construct; }

    private Adw.HeaderBar header_bar;
    private Gtk.Overlay overlay;
    private Gtk.Revealer welcome_revealer;
    private Gtk.Revealer rules_revealer;
    private Gtk.Revealer endgame_revealer;
    private Gtk.Revealer statistics_revealer;
    private Granite.Toast insufficient_letters_toast;
    private Granite.Toast invalid_word_toast;
    private Granite.Toast must_use_clues_toast;
    private Granite.Toast submit_guess_toast;
    private Warble.Views.GameArea game_area;

    public MainLayout (Warble.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        // Use multiple revealers so that transitions between them are smooth as well
        welcome_revealer = create_revealer ();
        rules_revealer = create_revealer ();
        endgame_revealer = create_revealer ();
        statistics_revealer = create_revealer ();

        insufficient_letters_toast = new Granite.Toast (_("Not enough letters!"));
        invalid_word_toast = new Granite.Toast (_("That's not a word!"));
        must_use_clues_toast = new Granite.Toast ("");
        submit_guess_toast = new Granite.Toast (_("Press \"Enter\" to submit your guess!"));

        game_area = new Warble.Views.GameArea ();
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

        overlay = new Gtk.Overlay ();
        overlay.add_controller (new Gtk.GestureClick ());
        overlay.child = game_area;
        overlay.add_overlay (insufficient_letters_toast);
        overlay.add_overlay (invalid_word_toast);
        overlay.add_overlay (must_use_clues_toast);
        overlay.add_overlay (submit_guess_toast);
        overlay.add_overlay (welcome_revealer);
        overlay.add_overlay (rules_revealer);
        overlay.add_overlay (endgame_revealer);
        overlay.add_overlay (statistics_revealer);

        header_bar = create_header_bar ();

        attach (header_bar, 0, 0);
        attach (overlay, 0, 1);

        check_first_launch ();
    }

    private Adw.HeaderBar create_header_bar () {
        var title_widget = new Gtk.Label (Constants.APP_NAME);
        title_widget.get_style_context ().add_class (Granite.STYLE_CLASS_TITLE_LABEL);
        var header_bar = new Adw.HeaderBar () {
            title_widget = title_widget,
            hexpand = true
        };

        header_bar.get_style_context ().add_class (STYLE_CLASS_TITLEBAR);
        header_bar.get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);
        header_bar.get_style_context ().add_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        var menu_popover = new Gtk.Popover () {
            autohide = true
        };

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
                    hide_revealers ();
                    if (game_area.can_safely_start_new_game ()) {
                        Warble.Application.settings.set_int ("difficulty", new_difficulty);
                        game_area.new_game ();
                        return;
                    }
                    menu_popover.popdown ();
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
                    dialog.show ();
                }
            });
        });
        difficulty_button_group.append_label (Warble.Models.Difficulty.EASY.get_display_string ());
        difficulty_button_group.append_label (Warble.Models.Difficulty.NORMAL.get_display_string ());
        difficulty_button_group.append_label (Warble.Models.Difficulty.HARD.get_display_string ());

        difficulty_button_group.set_active (Warble.Application.settings.get_int ("difficulty"));

        var new_game_menu_item = create_button_menu_item (_("New Game"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME);
        new_game_menu_item.clicked.connect (() => {
            menu_popover.popdown ();
        });

        var gameplay_stats_menu_item = create_button_menu_item (_("Gameplay Statistics"), null);
        gameplay_stats_menu_item.clicked.connect (() => {
            menu_popover.popdown ();
        });

        var high_contrast_button = new Granite.SwitchModelButton (_("High Contrast Mode"));
        high_contrast_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var help_menu_item = create_button_menu_item (_("Help"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP);
        help_menu_item.clicked.connect (() => {
            menu_popover.popdown ();
        });

        var about_menu_item = create_button_menu_item (_("About…"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_ABOUT);
        about_menu_item.clicked.connect (() => {
            menu_popover.popdown ();
        });

        var quit_menu_item = create_button_menu_item (_("Quit"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT);

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
        menu_popover.child = menu_popover_grid;

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            tooltip_text = _("Menu"),
            has_frame = false,
            valign = Gtk.Align.CENTER,
            popover = menu_popover
        };

        header_bar.pack_end (menu_button);

        gameplay_stats_menu_item.clicked.connect (() => {
            show_gameplay_statistics ();
        });

        Warble.Application.settings.bind (
            "high-contrast-mode",
            high_contrast_button,
            "active",
            SettingsBindFlags.DEFAULT
        );

        return header_bar;
    }

    private Gtk.Button create_button_menu_item (string label, string? action_name) {
        var button = new Gtk.Button () {
            child = (action_name == null)
                ? new Granite.AccelLabel (label)
                : new Granite.AccelLabel.from_action_name (label, action_name)
        };
        button.set_action_name (action_name);
        button.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        return button;
    }

    private Gtk.Revealer create_revealer () {
        return new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            transition_duration = 500,
            hexpand = true,
            vexpand = true,
            can_target = false
        };
    }

    private Gtk.Separator create_menu_separator () {
        return new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };
    }

    public bool on_key_pressed_event (Gtk.EventControllerKey controller, uint keyval, uint keycode,
            Gdk.ModifierType state) {
        if (is_revealer_revealed ()) {
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
            show_welcome_view ();
            Warble.Application.settings.set_boolean ("first-launch", false);
        }
    }

    public void show_rules () {
        hide_revealers ();
        game_area.get_style_context ().add_class (STYLE_CLASS_FADED);
        var view = new Warble.Views.RulesView ();
        view.continue_game.connect (() => {
            hide_revealers ();
        });
        show_revealer (rules_revealer, view);
    }

    public void new_game () {
        hide_revealers ();
        // If we can safely start a new game, don't need to prompt the user
        if (game_area.can_safely_start_new_game ()) {
            game_area.new_game ();
            return;
        }

        var dialog = new Warble.Widgets.Dialogs.NewGameConfirmationDialog (window);
        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.OK) {
                game_area.new_game (true);
            }
            dialog.close ();
        });
        dialog.show ();
    }

    private bool is_revealer_revealed () {
        return welcome_revealer.get_child_revealed ()
            || rules_revealer.get_child_revealed ()
            || statistics_revealer.get_child_revealed ()
            || endgame_revealer.get_child_revealed ();
    }

    private void hide_revealers () {
        welcome_revealer.set_reveal_child (false);
        statistics_revealer.set_reveal_child (false);
        endgame_revealer.set_reveal_child (false);
        rules_revealer.set_reveal_child (false);

        // Allow mouse events to pass through to the virtual keyboard
        welcome_revealer.can_target = false;
        statistics_revealer.can_target = false;
        endgame_revealer.can_target = false;
        rules_revealer.can_target = false;

        game_area.get_style_context ().remove_class (STYLE_CLASS_FADED);
    }

    private void show_revealer (Gtk.Revealer revealer, Gtk.Widget child) {
        // Capture mouse events so that buttons in the revealed child will work
        revealer.can_target = true;
        revealer.child = child;
        revealer.set_reveal_child (true);
    }

    private void show_welcome_view () {
        game_area.get_style_context ().add_class (STYLE_CLASS_FADED);
        var view = new Warble.Views.WelcomeView ();
        view.start_game.connect (() => {
            hide_revealers ();
        });
        show_revealer (welcome_revealer, view);
    }

    private void show_victory_view (string answer) {
        show_endgame_view (new Warble.Views.EndgameView.for_victory (answer));
    }

    private void show_defeat_view (string answer) {
        show_endgame_view (new Warble.Views.EndgameView.for_defeat (answer));
    }

    private void show_endgame_view (Warble.Views.EndgameView view) {
        game_area.get_style_context ().add_class (STYLE_CLASS_FADED);
        view.response.connect ((response_id) => {
            hide_revealers ();
            if (response_id == Gtk.ResponseType.YES) {
                game_area.new_game ();
            }
        });
        show_revealer (endgame_revealer, view);
    }

    private void show_gameplay_statistics () {
        hide_revealers ();
        game_area.get_style_context ().add_class (STYLE_CLASS_FADED);
        var view = new Warble.Views.GameplayStatisticsView ();
        view.reset_button_clicked.connect (() => {
            show_reset_gameplay_statistics_warning_dialog ();
        });
        view.continue_game.connect (() => {
            hide_revealers ();
        });
        show_revealer (statistics_revealer, view);
    }

    private void show_reset_gameplay_statistics_warning_dialog () {
        var dialog = new Warble.Widgets.Dialogs.ResetGameplayStatisticsWarningDialog (window);
        dialog.response.connect ((response_id) => {
            dialog.close ();
            if (response_id == Gtk.ResponseType.OK) {
                game_area.reset_gameplay_statistics ();
            }
            Idle.add (() => {
                show_gameplay_statistics ();
                return false;
            });
        });
        dialog.show ();
    }

    public void show_about_dialog () {
        var about_dialog = new Gtk.AboutDialog () {
            authors = new string[] { "Andrew Vojak", null },
            comments = "The word-guessing game",
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
        about_dialog.close_request.connect (() => {
            about_dialog.close ();
            return false;
        });
        about_dialog.show ();
        about_dialog.set_focus (null);
    }

}
