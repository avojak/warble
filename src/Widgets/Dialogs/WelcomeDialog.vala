/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.WelcomeDialog : Granite.Dialog {

    public WelcomeDialog (Warble.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: "Welcome to Warble!",
            transient_for: main_window,
            modal: true,
            width_request: 300,
            hexpand: false
        );
    }

    construct {
        var body = get_content_area ();

        // Create the header
        var header_title = new Gtk.Label ("Welcome to Warble!");
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.CENTER;
        header_title.hexpand = true;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);

        var header_grid = create_grid ();
        header_grid.attach (header_title, 0, 0);

        var high_contrast_button = new Gtk.Switch ();

        var high_contrast_grid = create_grid ();
        high_contrast_grid.margin_bottom = 20;
        high_contrast_grid.margin_top = 20;
        high_contrast_grid.attach (new Gtk.Label ("High Contrast Mode"), 0, 0);
        high_contrast_grid.attach (high_contrast_button, 1, 0);

        body.add (header_grid);
        body.add (new Warble.Widgets.Rules ());
        body.add (high_contrast_grid);

        // Add action buttons
        var start_button = new Gtk.Button.with_label (_("Let's Get Started!"));
        start_button.get_style_context ().add_class ("suggested-action");
        start_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (start_button, 1);

        Warble.Application.settings.bind (
            "high-contrast-mode",
            high_contrast_button,
            "active",
            SettingsBindFlags.DEFAULT
        );
    }

    private Gtk.Grid create_grid () {
        return new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            row_spacing = 8,
            column_spacing = 10
        };
    }

}
