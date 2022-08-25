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
        // XXX: Fixed in Granite with https://github.com/elementary/granite/pull/616
        // This can be removed once the fix is delivered in a Granite release
        secondary_label.width_chars = secondary_label.max_width_chars;

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        add_button (_("Yes, Reset"), Gtk.ResponseType.OK)
            .get_style_context ().add_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        set_default_response (Gtk.ResponseType.CANCEL);
    }

}
