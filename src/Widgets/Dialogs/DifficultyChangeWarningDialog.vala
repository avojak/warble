/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.DifficultyChangeWarningDialog : Granite.MessageDialog {

    public DifficultyChangeWarningDialog (Gtk.Window window) {
        Object (
            image_icon: new ThemedIcon ("dialog-warning"),
            primary_text: _("Start a new game?"),
            secondary_text: _("To change the difficulty you must start a new game. All progress on the current game will be lost, and the current game will be recorded as a loss."), // vala-lint=line-length
            transient_for: window,
            modal: true
        );
    }

    construct {
        // XXX: Fixed in Granite with https://github.com/elementary/granite/pull/616
        // This can be removed once the fix is delivered in a Granite release
        secondary_label.width_chars = secondary_label.max_width_chars;

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        add_button (_("Yes, Start New Game"), Gtk.ResponseType.OK)
            .get_style_context ().add_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        set_default_response (Gtk.ResponseType.CANCEL);
    }

}
