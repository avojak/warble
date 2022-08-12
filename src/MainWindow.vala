/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.MainWindow : Adw.ApplicationWindow {

    public unowned Warble.Application app { get; construct; }

    private Warble.ActionManager action_manager;
    //  private Gtk.AccelGroup accel_group;
    private Gtk.ShortcutController shortcut_controller;

    private Warble.MainLayout main_layout;

    public MainWindow (Warble.Application application) {
        Object (
            title: Constants.APP_NAME,
            application: application,
            app: application,
            //  border_width: 0,
            resizable: true
        );
    }

    construct {
        //  accel_group = new Gtk.AccelGroup ();
        //  add_accel_group (accel_group);
        shortcut_controller = new Gtk.ShortcutController () {
            scope = Gtk.ShortcutScope.GLOBAL
        };
        add_controller (shortcut_controller);
        action_manager = new Warble.ActionManager (app, this);

        main_layout = new Warble.MainLayout (this);
        //  add (main_layout);
        content = main_layout;

        //  move (Warble.Application.settings.get_int ("pos-x"), Warble.Application.settings.get_int ("pos-y"));

        //  this.key_press_event.connect ((event_key) => {
        //      if (event_key.keyval == Gdk.Key.Escape) {
        //          set_focus (null);
        //      }
        //      if (event_key.keyval == Gdk.Key.Return) {
        //          main_layout.return_pressed ();
        //          return false;
        //      }
        //      if (event_key.keyval == Gdk.Key.BackSpace) {
        //          set_focus (null);
        //          main_layout.backspace_pressed ();
        //          return false;
        //      }
        //      char letter = event_key.str.up ()[0];
        //      if (alphabet.contains (letter)) {
        //          set_focus (null);
        //          main_layout.letter_key_pressed (letter);
        //          return false;
        //      }
        //  });

        //  this.destroy.connect (() => {
        //      // Do stuff before closing the application
        //      GLib.Process.exit (0);
        //  });
        //  this.delete_event.connect (before_destroy);

        var key_event_controller = new Gtk.EventControllerKey ();
        key_event_controller.key_pressed.connect (main_layout.on_key_pressed_event);
        key_event_controller.key_pressed.connect (on_key_pressed_event);
        ((Gtk.Widget) this).add_controller (key_event_controller);

        show_app ();

        set_focus (null);
    }

    public void show_app () {
        //  show ();
        present ();
    }

    //  public bool before_destroy () {
    //      //  update_position_settings ();
    //      destroy ();
    //      return true;
    //  }

    private bool on_key_pressed_event (Gtk.EventControllerKey controller, uint keyval, uint keycode, Gdk.ModifierType state) {
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

    //  private void update_position_settings () {
    //      int x, y;
    //      get_position (out x, out y);
    //      Warble.Application.settings.set_int ("pos-x", x);
    //      Warble.Application.settings.set_int ("pos-y", y);
    //  }

}
