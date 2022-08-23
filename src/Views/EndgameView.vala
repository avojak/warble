/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.View.EndgameView : Gtk.Box {

    public string title_str { get; construct; }
    public string correct_answer { get; construct; }

    public EndgameView.for_victory (string correct_answer) {
        Object (
            title_str: "🎉️ You Win!",
            correct_answer: correct_answer,
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    public EndgameView.for_defeat (string correct_answer) {
        Object (
            title_str: "Game Over",
            correct_answer: correct_answer,
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        var header_title = new Gtk.Label (title_str) {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_top = 20,
            margin_bottom = 20,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        append (header_title);
        append (new Gtk.Label (@"The correct answer was: <b>$correct_answer</b>") {
            use_markup = true
        });
        append (new Warble.Widgets.GameplayStatistics ());
        append (new Gtk.Label ("Would you like to play again?") {
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
