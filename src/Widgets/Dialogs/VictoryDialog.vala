/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.VictoryDialog : Granite.Dialog {

    public VictoryDialog (Warble.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: "Victory!",
            transient_for: main_window,
            modal: true
        );
    }

    construct {
        var body = get_content_area ();

        // Create the header
        var header_grid = new Gtk.Grid () {
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 30,
            column_spacing = 10
        };

        var header_title = new Gtk.Label ("🎉️ You Win!") {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_end = 10,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        header_grid.attach (header_title, 0, 0);

        body.append (header_grid);
        body.append (new Warble.Widgets.GameplayStatistics ());
        body.append (new Gtk.Label ("Would you like to play again?") {
            margin_top = 30,
            margin_bottom = 10
        });

        // Add action buttons
        var not_now_button = new Gtk.Button.with_label (_("Not Now"));
        not_now_button.clicked.connect (() => {
            close ();
        });

        var play_again_button = new Gtk.Button.with_label (_("Play Again"));
        play_again_button.get_style_context ().add_class ("suggested-action");
        play_again_button.clicked.connect (() => {
            play_again_button_clicked ();
        });

        add_action_widget (not_now_button, 0);
        add_action_widget (play_again_button, 1);
    }

    public signal void play_again_button_clicked ();

}
