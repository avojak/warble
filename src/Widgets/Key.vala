/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Key : Gtk.DrawingArea {

    private const int SIZE = 32;
    private const int FONT_SIZE = 15;

    public char letter { get; construct; }

    private Warble.Models.State _state = Warble.Models.State.BLANK;
    public Warble.Models.State state {
        get { return this._state; }
        set { this._state = value; update_style (); }
    }

    public Key (char letter) {
        Object (
            letter: letter,
            hexpand: false,
            vexpand: false,
            width_request: SIZE,
            height_request: SIZE
        );
    }

    construct {
        get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        get_style_context ().add_class (Granite.STYLE_CLASS_ROUNDED);

        set_draw_func (draw_func);

        var gesture_event_controller = new Gtk.GestureClick ();
        gesture_event_controller.pressed.connect (on_press_event);
        gesture_event_controller.released.connect (on_release_event);
        this.add_controller (gesture_event_controller);

        Warble.Application.settings.changed.connect ((key) => {
            if (key == "high-contrast-mode") {
                update_style ();
            }
        });
    }

    private void draw_func (Gtk.DrawingArea drawing_area, Cairo.Context ctx, int width, int height) {
        var color = Gdk.RGBA ();
        color.parse (Warble.ColorPalette.get_text_color (state));
        ctx.set_source_rgb (color.red, color.green, color.blue);

        ctx.select_font_face ("Inter", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        ctx.set_font_size (FONT_SIZE);

        Cairo.TextExtents extents;
        ctx.text_extents (letter.to_string (), out extents);
        double x = (width / 2) - (extents.width / 2 + extents.x_bearing);
        double y = (height / 2) - (extents.height / 2 + extents.y_bearing);
        ctx.move_to (x, y);
        ctx.show_text (letter.to_string ());
    }

    private void on_press_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        get_style_context ().add_class ("key-pressed");
        clicked (letter);
    }

    private void on_release_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        get_style_context ().remove_class ("key-pressed");
    }

    private void update_style () {
        clear_style_classes ();
        switch (state) {
            case BLANK:
            case ACTIVE:
                break;
            case INCORRECT:
                get_style_context ().add_class ("guess-incorrect");
                break;
            case CLOSE:
                get_style_context ().add_class ("guess-close");
                break;
            case CORRECT:
                get_style_context ().add_class ("guess-correct");
                break;
            default:
                assert_not_reached ();
        }
    }

    private void clear_style_classes () {
        get_style_context ().remove_class ("guess-correct");
        get_style_context ().remove_class ("guess-incorrect");
        get_style_context ().remove_class ("guess-close");
        get_style_context ().remove_class ("tile-active");
    }

    public signal void clicked (char letter);

}
