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

public class Warble.Widgets.Dialogs.RulesDialog : Granite.Dialog {

    public RulesDialog (Warble.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: "How to Play Warble",
            transient_for: main_window,
            modal: true,
            width_request: 300,
            hexpand: false
        );
    }

    construct {
        var body = get_content_area ();

        // Create the header
        var header_title = new Gtk.Label ("How to Play") {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            margin_end = 10,
            wrap = true
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var header_grid = create_grid ();
        header_grid.attach (header_title, 0, 0);

        body.append (header_grid);
        body.append (new Warble.Widgets.Rules ());

        // Add action buttons
        var start_button = new Gtk.Button.with_label (_("Close"));
        start_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (start_button, 1);
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
