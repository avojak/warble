/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.CheckButtonGroup : Gtk.Box {

    private Gee.Map<int, Gtk.CheckButton> children = new Gee.HashMap<int, Gtk.CheckButton> ();

    public CheckButtonGroup (Gtk.Orientation orientation, int spacing) {
        Object (
            orientation: orientation,
            spacing: spacing
        );
    }

    /**
     * Appends a button with the given label
     */
    public void append_label (string? label) {
        int new_index = children.size;
        var button = new Gtk.CheckButton.with_label (label);
        if (new_index > 0) {
            button.group = children.get (0);
        }
        children.set (new_index, button);
        append (button);
        button_added (new_index, button);
    }

    public void set_active (int index) {
        children.get (index).active = true;
    }

    public signal void button_added (int index, Gtk.CheckButton button);

}
