/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.GameplayStatisticsDialog : Granite.Dialog {

    public GameplayStatisticsDialog (Warble.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: "Gameplay Statistics",
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

        var header_title = new Gtk.Label ("Gameplay Statistics") {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_end = 10,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        header_grid.attach (header_title, 0, 0);

        body.append (header_grid);
        body.append (new Warble.Widgets.GameplayStatistics ());

        // Add action buttons
        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });
        var reset_button = new Gtk.Button.with_label (_("Reset…"));
        reset_button.set_tooltip_text (_("Reset Gameplay Statistics"));
        reset_button.get_style_context ().add_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);
        reset_button.clicked.connect (() => {
            reset_button_clicked ();
        });
        add_action_widget (reset_button, Gtk.ResponseType.DELETE_EVENT);
        add_action_widget (close_button, Gtk.ResponseType.CLOSE);

        close_button.grab_focus ();
    }

    public signal void reset_button_clicked ();

}
