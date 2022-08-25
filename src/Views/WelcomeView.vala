/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Warble.Views.WelcomeView : Gtk.Box {

    public WelcomeView () {
        Object (
            vexpand: true,
            hexpand: true,
            orientation: Gtk.Orientation.VERTICAL
        );
    }

    construct {
        var header_title = new Gtk.Label (_("Welcome to %s!").printf (Constants.APP_NAME)) {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_top = 20,
            margin_bottom = 20,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var high_contrast_button = new Gtk.Switch ();
        Warble.Application.settings.bind (
            "high-contrast-mode",
            high_contrast_button,
            "active",
            SettingsBindFlags.DEFAULT
        );

        var high_contrast_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10) {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_start = 30,
            margin_end = 30,
            margin_top = 20,
        };
        high_contrast_box.append (new Gtk.Label (_("High Contrast Mode")));
        high_contrast_box.append (high_contrast_button);

        var button = new Gtk.Button.with_label (_("Let's Get Started!")) {
            margin_top = 20,
            margin_bottom = 20,
            halign = Gtk.Align.CENTER
        };
        button.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        button.clicked.connect (() => {
            start_game ();
        });

        append (header_title);
        append (new Warble.Widgets.Rules ());
        append (high_contrast_box);
        append (button);
    }

    public signal void start_game ();

}
