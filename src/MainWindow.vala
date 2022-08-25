/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.MainWindow : Adw.ApplicationWindow {

    public unowned Warble.Application app { get; construct; }

    private Warble.ActionManager action_manager;
    private Gtk.ShortcutController shortcut_controller;

    private Warble.MainLayout main_layout;

    public MainWindow (Warble.Application application) {
        Object (
            title: Constants.APP_NAME,
            application: application,
            app: application,
            resizable: true
        );
    }

    construct {
        shortcut_controller = new Gtk.ShortcutController () {
            scope = Gtk.ShortcutScope.GLOBAL
        };
        add_controller (shortcut_controller);
        action_manager = new Warble.ActionManager (app, this);

        main_layout = new Warble.MainLayout (this);
        content = main_layout;

        var key_event_controller = new Gtk.EventControllerKey ();
        key_event_controller.key_pressed.connect (main_layout.on_key_pressed_event);
        key_event_controller.key_pressed.connect (on_key_pressed_event);
        ((Gtk.Widget) this).add_controller (key_event_controller);

        present ();

        set_focus (null);
    }

    private bool on_key_pressed_event (Gtk.EventControllerKey controller, uint keyval, uint keycode,
            Gdk.ModifierType state) {
        if (keyval == Gdk.Key.Escape || keyval == Gdk.Key.BackSpace) {
            set_focus (null);
            return true;
        }
        char letter = ((char) Gdk.keyval_to_unicode (keyval)).toupper ();
        if (Warble.Application.alphabet.contains (letter)) {
            set_focus (null);
        }
        return true;
    }

    public void show_rules () {
        main_layout.show_rules ();
    }

    public void new_game () {
        main_layout.new_game ();
    }

    public void show_about_dialog () {
        main_layout.show_about_dialog ();
    }

}
