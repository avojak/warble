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
            // TODO: Revisit this when updating to GTK4 and removing libhandy.
            // This shouldn't be necessary if using non-libhandy widgets and setting the header bar directly on
            // the application window. But for now, this will have the effect of respecting the system positioning
            // of the close button, while still hiding the maximize/restore button.
            decoration_layout: Gtk.Settings.get_default ().gtk_decoration_layout.replace ("maximize", "").replace ("minimize", "")
        );
    }

    construct {
        unowned Gtk.StyleContext style_context = get_style_context ();
        style_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var difficulty_button = new Granite.Widgets.ModeButton () {
            margin = 12
        };
        difficulty_button.mode_added.connect ((index, widget) => {
            widget.set_tooltip_markup (((Warble.Models.Difficulty) index).get_details_markup ());
        });
        difficulty_button.append_text (Warble.Models.Difficulty.EASY.get_display_string ());
        difficulty_button.append_text (Warble.Models.Difficulty.NORMAL.get_display_string ());
        difficulty_button.append_text (Warble.Models.Difficulty.HARD.get_display_string ());
        Warble.Application.settings.bind ("difficulty", difficulty_button, "selected", GLib.SettingsBindFlags.DEFAULT);

        var new_game_accellabel = new Granite.AccelLabel.from_action_name (
            _("New Game"),
            Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME
        );

        var new_game_menu_item = new Gtk.ModelButton ();
        new_game_menu_item.action_name = Warble.ActionManager.ACTION_PREFIX + Warble.ActionManager.ACTION_NEW_GAME;
        new_game_menu_item.get_child ().destroy ();
        new_game_menu_item.add (new_game_accellabel);

        var gameplay_stats_menu_item = new Gtk.ModelButton ();
        gameplay_stats_menu_item.text = "Gameplay Statistics…";

        var high_contrast_button = new Granite.SwitchModelButton ("High Contrast Mode");

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
        menu_popover_grid.attach (difficulty_button, 0, 0, 3, 1);
        menu_popover_grid.attach (new_game_menu_item, 0, 1, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 2, 1, 1);
        menu_popover_grid.attach (gameplay_stats_menu_item, 0, 3, 1, 1);
        menu_popover_grid.attach (high_contrast_button, 0, 4, 1, 1);
        menu_popover_grid.attach (help_menu_item, 0, 5, 1, 1);
        menu_popover_grid.attach (create_menu_separator (), 0, 6, 1, 1);
        menu_popover_grid.attach (quit_menu_item, 0, 7, 1, 1);
        menu_popover_grid.show_all ();

        var menu_popover = new Gtk.Popover (null);
        menu_popover.add (menu_popover_grid);

        var menu_button = new Gtk.MenuButton ();
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        menu_button.tooltip_text = _("Menu");
        menu_button.relief = Gtk.ReliefStyle.NONE;
        menu_button.valign = Gtk.Align.CENTER;
        menu_button.popover = menu_popover;

        pack_end (menu_button);

        gameplay_stats_menu_item.clicked.connect (() => {
            gameplay_statistics_menu_item_clicked ();
        });

        Warble.Application.settings.bind (
            "high-contrast-mode",
            high_contrast_button,
            "active",
            SettingsBindFlags.DEFAULT
        );
    }

    private Gtk.Separator create_menu_separator () {
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = 3;
        menu_separator.margin_bottom = 3;
        return menu_separator;
    }

    public signal void gameplay_statistics_menu_item_clicked ();

}
