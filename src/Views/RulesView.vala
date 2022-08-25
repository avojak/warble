/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Views.RulesView : Gtk.Box {

    public RulesView () {
        Object (
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        var header_title = new Gtk.Label (_("How to Play")) {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_top = 20,
            margin_bottom = 20,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var button = new Gtk.Button.with_label (_("Continue Game")) {
            margin_top = 20,
            margin_bottom = 20,
            halign = Gtk.Align.CENTER
        };
        button.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        button.clicked.connect (() => {
            continue_game ();
        });

        append (header_title);
        append (new Warble.Widgets.Rules ());
        append (button);
    }

    public signal void continue_game ();

}
