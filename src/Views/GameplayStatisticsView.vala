/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Views.GameplayStatisticsView : Gtk.Box {

    public GameplayStatisticsView () {
        Object (
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        var header_title = new Gtk.Label (_("Gameplay Statistics")) {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_top = 20,
            margin_bottom = 20,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var reset_button = new Gtk.Button.with_label (_("Reset…"));
        reset_button.set_tooltip_text (_("Reset Gameplay Statistics"));
        reset_button.get_style_context ().add_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);
        reset_button.clicked.connect (() => {
            reset_button_clicked ();
        });

        var continue_button = new Gtk.Button.with_label (_("Continue Game"));
        continue_button.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        continue_button.clicked.connect (() => {
            continue_game ();
        });

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            halign = Gtk.Align.CENTER,
            homogeneous = true,
            margin_top = 20
        };
        button_box.append (reset_button);
        button_box.append (continue_button);

        append (header_title);
        append (new Warble.Widgets.GameplayStatistics ());
        append (button_box);
    }

    public signal void reset_button_clicked ();
    public signal void continue_game ();

}
