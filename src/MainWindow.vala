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
            resizable: false
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
