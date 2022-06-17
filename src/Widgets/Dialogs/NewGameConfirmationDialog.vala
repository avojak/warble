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

public class Warble.Widgets.Dialogs.NewGameConfirmationDialog : Granite.MessageDialog {

    public NewGameConfirmationDialog (Gtk.Window window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: window,
            modal: true
        );
    }

    construct {
        image_icon = new ThemedIcon ("dialog-warning");
        primary_text = _("Start a new game?");
        secondary_text = _("All progress will be lost, and the current game will be recorded as a loss.");

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        var remove_button = add_button (_("Yes, Start New Game"), Gtk.ResponseType.OK);
        unowned Gtk.StyleContext style_context = remove_button.get_style_context ();
        style_context.add_class ("destructive-action");
    }

}
