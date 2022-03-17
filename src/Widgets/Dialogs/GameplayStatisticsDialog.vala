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
        var header_grid = new Gtk.Grid ();
        header_grid.margin_start = 30;
        header_grid.margin_end = 30;
        header_grid.margin_bottom = 30;
        header_grid.column_spacing = 10;

        var header_title = new Gtk.Label ("Gameplay Statistics");
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.CENTER;
        header_title.hexpand = true;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);

        header_grid.attach (header_title, 0, 0);

        body.add (header_grid);
        body.add (new Warble.Widgets.GameplayStatistics ());

        // Add action buttons
        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });
        var reset_button = new Gtk.Button.with_label (_("Reset…"));
        reset_button.set_tooltip_text (_("Reset Gameplay Statistics"));
        reset_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        reset_button.clicked.connect (() => {
            reset_button_clicked ();
        });
        add_action_widget (reset_button, Gtk.ResponseType.DELETE_EVENT);
        add_action_widget (close_button, Gtk.ResponseType.CLOSE);

        close_button.grab_focus ();
    }

    public signal void reset_button_clicked ();

}
