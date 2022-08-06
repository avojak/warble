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

public class Warble.Widgets.GameplayStatistics : Gtk.Grid {

    public GameplayStatistics () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            halign: Gtk.Align.CENTER,
            hexpand: true,
            margin_start: 8,
            margin_end: 8,
            margin_top: 8,
            margin_bottom: 8,
            row_spacing: 8,
            column_spacing: 8
        );
    }

    construct {
        // Load stats and do calculations
        int num_games_won = get_int_stat ("num-games-won");
        int num_games_lost = get_int_stat ("num-games-lost");
        int total_games = num_games_won + num_games_lost;
        int win_percent = total_games > 0 ? (int) (((double) num_games_won / (double) total_games) * 100) : 0;
        int win_streak = get_int_stat ("win-streak");
        int max_win_streak = get_int_stat ("max-win-streak");
        string[] guess_distribution = get_string_stat ("guess-distribution").split ("|");

        var stats_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            halign = Gtk.Align.CENTER,
            margin_top = 8,
            margin_bottom = 8,
            margin_start = 8,
            margin_end = 8,
            row_spacing = 8,
            column_spacing = 8
        };
        var games_played_value = new Gtk.Label ("<b>%s</b>".printf (total_games.to_string ())) {
            use_markup = true
        };
        games_played_value.get_style_context ().add_class ("h3");
        var games_played_label = new Gtk.Label ("Number of Games Played") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            max_width_chars = 10,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        var win_percent_value = new Gtk.Label ("<b>%d%%</b>".printf (win_percent)) {
            use_markup = true
        };
        win_percent_value.get_style_context ().add_class ("h3");
        var win_percent_label = new Gtk.Label ("Win Percent") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            max_width_chars = 10,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        var win_streak_value = new Gtk.Label ("<b>%d</b>".printf (win_streak)) {
            use_markup = true
        };
        win_streak_value.get_style_context ().add_class ("h3");
        var win_streak_label = new Gtk.Label ("Current Win Streak") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            max_width_chars = 10,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        var longest_win_streak_value = new Gtk.Label ("<b>%d</b>".printf (max_win_streak)) {
            use_markup = true
        };
        longest_win_streak_value.get_style_context ().add_class ("h3");
        var longest_win_streak_label = new Gtk.Label ("Longest Win Streak") {
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,
            max_width_chars = 10,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        stats_grid.attach (games_played_value, 0, 0);
        stats_grid.attach (games_played_label, 0, 1);
        stats_grid.attach (win_percent_value, 1, 0);
        stats_grid.attach (win_percent_label, 1, 1);
        stats_grid.attach (win_streak_value, 2, 0);
        stats_grid.attach (win_streak_label, 2, 1);
        stats_grid.attach (longest_win_streak_value, 3, 0);
        stats_grid.attach (longest_win_streak_label, 3, 1);

        var guess_distribution_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            hexpand = true,
            row_spacing = 4
        };
        var guess_distribution_label = new Gtk.Label ("Guess Distribution") {
            margin_bottom = 10,
            justify = Gtk.Justification.CENTER,
            halign = Gtk.Align.CENTER
        };
        guess_distribution_label.get_style_context ().add_class ("h3");
        guess_distribution_grid.attach (guess_distribution_label, 0, 0, 3, 1);

        int max_guesses = 0;
        for (int i = 0; i < guess_distribution.length; i++) {
            int num_guesses = int.parse (guess_distribution[i].split (":")[1]);
            if (num_guesses > max_guesses) {
                max_guesses = num_guesses;
            }
        }
        for (int i = 0; i < guess_distribution.length; i++) {
            string key = guess_distribution[i].split (":")[0];
            int val = int.parse (guess_distribution[i].split (":")[1]);

            var label = new Gtk.Label (@"<b>$key</b>") {
                margin_end = 4,
                use_markup = true
            };
            guess_distribution_grid.attach (label, 0, i + 1, 1, 1);

            var level_bar = new Gtk.LevelBar.for_interval (0, max_guesses) {
                mode = Gtk.LevelBarMode.CONTINUOUS,
                value = val,
                hexpand = true
            };
            level_bar.add_offset_value (Gtk.LEVEL_BAR_OFFSET_FULL, 0.0);
            guess_distribution_grid.attach (level_bar, 1, i + 1, 1, 1);

            var guess_count = new Gtk.Label (val > 0 ? "<small>%s</small>".printf (val.to_string ()) : "") {
                margin_end = 4,
                use_markup = true
            };
            guess_distribution_grid.attach (guess_count, 2, i + 1, 1, 1);
        }

        attach (stats_grid, 0, 0);
        attach (guess_distribution_grid, 0, 1);
    }

    private int get_int_stat (string name) {
        return Warble.Application.settings.get_int (name);
    }

    private string get_string_stat (string name) {
        return Warble.Application.settings.get_string (name);
    }

}
