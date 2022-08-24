/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.DifficultyChangeWarningDialog : Granite.MessageDialog {

    public DifficultyChangeWarningDialog (Gtk.Window window) {
        Object (
            image_icon: new ThemedIcon ("dialog-warning"),
            primary_text: _("Start a new game?"),
            secondary_text: _("To change the difficulty you must start a new game. All progress on the current game will be lost, and the current game will be recorded as a loss."),
            transient_for: window,
            modal: true
        );
    }

    construct {
        add_action_widget (new Gtk.Button.with_label (_("Cancel")), Gtk.ResponseType.CANCEL);
        var remove_button = new Gtk.Button.with_label (_("Yes, Start New Game"));
        remove_button.get_style_context ().add_class ("destructive-action");
        add_action_widget (remove_button, Gtk.ResponseType.OK);

        set_default_response (Gtk.ResponseType.CANCEL);
    }

}
