/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.ResetGameplayStatisticsWarningDialog : Granite.MessageDialog {

    public ResetGameplayStatisticsWarningDialog (Gtk.Window window) {
        Object (
            image_icon: new ThemedIcon ("dialog-warning"),
            primary_text: _("Reset gameplay statistics?"),
            secondary_text: _("All gameplay history (including wins and losses) will be lost."),
            transient_for: window,
            modal: true
        );
    }

    construct {
        add_action_widget (new Gtk.Button.with_label (_("Cancel")), Gtk.ResponseType.CANCEL);
        var reset_button = new Gtk.Button.with_label (_("Yes, Reset"));
        reset_button.get_style_context ().add_class ("destructive-action");
        add_action_widget (reset_button, Gtk.ResponseType.OK);

        set_default_response (Gtk.ResponseType.CANCEL);
    }

}
