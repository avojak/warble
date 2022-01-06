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

public class Warble.Widgets.HeaderBar : Hdy.HeaderBar {

    public HeaderBar () {
        Object (
            title: Constants.APP_NAME,
            show_close_button: true,
            has_subtitle: false,
            decoration_layout: "close:" // Disable the maximize/restore button
        );
    }

    construct {
        unowned Gtk.StyleContext style_context = get_style_context ();
        style_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var new_game_accellabel = new Granite.AccelLabel.from_action_name (
            _("New Game"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME
        );

        var new_game_menu_item = new Gtk.ModelButton ();
        new_game_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME;
        new_game_menu_item.get_child ().destroy ();
        new_game_menu_item.add (new_game_accellabel);

        var help_accellabel = new Granite.AccelLabel.from_action_name (
            _("Help"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP
        );

        var help_menu_item = new Gtk.ModelButton ();
        help_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_HELP;
        help_menu_item.get_child ().destroy ();
        help_menu_item.add (help_accellabel);

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.ModelButton ();
        quit_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_QUIT;
        quit_menu_item.get_child ().destroy ();
        quit_menu_item.add (quit_accellabel);

        var menu_popover_grid = new Gtk.Grid ();
        menu_popover_grid.margin_top = 3;
        menu_popover_grid.margin_bottom = 3;
        menu_popover_grid.orientation = Gtk.Orientation.VERTICAL;
        menu_popover_grid.width_request = 200;
        menu_popover_grid.attach (new_game_menu_item, 0, 0);
        menu_popover_grid.attach (create_menu_separator (), 0, 1);
        menu_popover_grid.attach (help_menu_item, 0, 2);
        menu_popover_grid.attach (create_menu_separator (), 0, 3);
        menu_popover_grid.attach (quit_menu_item, 0, 4);
        menu_popover_grid.show_all ();

        var menu_popover = new Gtk.Popover (null);
        menu_popover.add (menu_popover_grid);

        var menu_button = new Gtk.MenuButton ();
        menu_button.image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        menu_button.tooltip_text = _("Menu");
        menu_button.relief = Gtk.ReliefStyle.NONE;
        menu_button.valign = Gtk.Align.CENTER;
        menu_button.popover = menu_popover;

        pack_end (menu_button);
    }

    private Gtk.Separator create_menu_separator (int margin_top = 0) {
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = margin_top;
        return menu_separator;
    }

}
