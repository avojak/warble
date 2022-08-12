/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Dialogs.ResetGameplayStatisticsWarningDialog : Granite.MessageDialog {

    public ResetGameplayStatisticsWarningDialog (Gtk.Window window) {
        Object (
            deletable: false,
            resizable: false,
            transient_for: window,
            modal: true
        );
    }

    construct {
        image_icon = new ThemedIcon ("dialog-warning");
        primary_text = _("Reset gameplay statistics?");
        secondary_text = _("All gameplay history (including wins and losses) will be lost.");

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        var reset_button = add_button (_("Yes, Reset"), Gtk.ResponseType.OK);
        unowned Gtk.StyleContext style_context = reset_button.get_style_context ();
        style_context.add_class ("destructive-action");

        set_default_response (Gtk.ResponseType.CANCEL);
    }

}
