/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.ActionManager : GLib.Object {

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_NEW_GAME = "action_new_game";
    public const string ACTION_HELP = "action_help";
    public const string ACTION_ABOUT = "action_about";
    public const string ACTION_QUIT = "action_quit";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_NEW_GAME, action_new_game },
        { ACTION_HELP, action_help },
        { ACTION_ABOUT, action_about },
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

    private void action_about () {
        window.show_about_dialog ();
    }

    private void action_quit () {
        window.destroy ();
    }

}
