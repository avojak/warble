/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.DifficultyChangeWarningDialog : Granite.MessageDialog {

    public DifficultyChangeWarningDialog (Gtk.Window window) {
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
        secondary_text = _("To change the difficulty you must start a new game. All progress on the current game will be lost, and the current game will be recorded as a loss.");

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        var remove_button = add_button (_("Yes, Start New Game"), Gtk.ResponseType.OK);
        unowned Gtk.StyleContext style_context = remove_button.get_style_context ();
        style_context.add_class ("destructive-action");
    }

}
