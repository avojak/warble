/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Views.EndgameView : Gtk.Box {

    public string? emoji { get; construct; default = null; }
    public string title_str { get; construct; }
    public string correct_answer { get; construct; }

    public EndgameView.for_victory (string correct_answer) {
        Object (
            emoji: "🎉️",
            title_str: _("You Win!"),
            correct_answer: correct_answer,
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    public EndgameView.for_defeat (string correct_answer) {
        Object (
            title_str: _("Game Over"),
            correct_answer: correct_answer,
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        var header_title = new Gtk.Label (title_str) {
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_top = 20,
            margin_bottom = 20
        };
        if (emoji != null) {
            var emoji_label = new Gtk.Label (emoji);
            emoji_label.get_style_context ().add_class ("jiggle");
            emoji_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
            header_box.append (emoji_label);
        }
        header_box.append (header_title);

        append (header_box);
        append (new Gtk.Label (_("The correct answer was: <b>%s</b>").printf (correct_answer)) {
            use_markup = true
        });
        append (new Warble.Widgets.GameplayStatistics ());
        append (new Gtk.Label (_("Would you like to play again?")) {
            margin_top = 30,
            margin_bottom = 10
        });

        // Add action buttons
        var not_now_button = new Gtk.Button.with_label (_("Not Now"));
        not_now_button.clicked.connect (() => {
            response (Gtk.ResponseType.NO);
        });

        var play_again_button = new Gtk.Button.with_label (_("Play Again"));
        play_again_button.get_style_context ().add_class ("suggested-action");
        play_again_button.clicked.connect (() => {
            response (Gtk.ResponseType.YES);
        });

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.CENTER,
            homogeneous = true,
            margin_top = 20
        };
        button_box.append (not_now_button);
        button_box.append (play_again_button);

        append (button_box);
    }

    public signal void response (int response_id);

}
