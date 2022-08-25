/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Square : Gtk.DrawingArea {

    private const int WIDTH = 70;
    private const int HEIGHT = 70;
    private const int FONT_SIZE = 30;

    private char _letter = ' ';
    public char letter {
        get { return this._letter; }
        set { this._letter = value; queue_draw (); }
    }

    private Warble.Models.State _state = Warble.Models.State.BLANK;
    public Warble.Models.State state {
        get { return this._state; }
        set { this._state = value; update_style (); }
    }

    public Square () {
        Object (
            hexpand: false,
            vexpand: false,
            width_request: WIDTH,
            height_request: HEIGHT
        );
    }

    construct {
        get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        get_style_context ().add_class (Granite.STYLE_CLASS_ROUNDED);

        set_draw_func (draw_func);

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

    public void update_style () {
        clear_style_classes ();
        switch (state) {
            case BLANK:
                break;
            case ACTIVE:
                get_style_context ().add_class ("tile-active");
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

}
