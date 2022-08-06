/*
 * Copyright (c) 2020 Andrew Vojak (https://avojak.com)
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

public class Warble.ActionManager : GLib.Object {

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_NEW_GAME = "action_new_game";
    public const string ACTION_HELP = "action_help";
    public const string ACTION_QUIT = "action_quit";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_NEW_GAME, action_new_game },
        { ACTION_HELP, action_help },
        { ACTION_QUIT, action_quit }
    };

    private static Gee.MultiMap<string, string> accelerators;

    public unowned Warble.Application application { get; construct; }
    public unowned Warble.MainWindow window { get; construct; }

    private GLib.SimpleActionGroup action_group;

    public ActionManager (Warble.Application application, Warble.MainWindow window) {
        Object (
            application: application,
            window: window
        );
    }

    static construct {
        accelerators = new Gee.HashMultiMap<string, string> ();
        accelerators.set (ACTION_NEW_GAME, "<Control>n");
        accelerators.set (ACTION_HELP, "<Control>h");
        accelerators.set (ACTION_QUIT, "<Control>q");
    }

    construct {
        action_group = new GLib.SimpleActionGroup ();
        action_group.add_action_entries (ACTION_ENTRIES, this);
        window.insert_action_group ("win", action_group);

        foreach (var action in accelerators.get_keys ()) {
            var accelerators_array = accelerators[action].to_array ();
            accelerators_array += null;
            application.set_accels_for_action (ACTION_PREFIX + action, accelerators_array);
        }
    }

    public static void action_from_group (string action_name, ActionGroup action_group, Variant? parameter = null) {
        action_group.activate_action (action_name, parameter);
    }

    private void action_new_game () {
        window.new_game ();
    }

    private void action_help () {
        window.show_rules ();
    }

    private void action_quit () {
        window.destroy ();
    }

}
