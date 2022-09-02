/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.ControlKey : Gtk.Box {

    private const int WIDTH = 48;
    private const int HEIGHT = 32;
    private const int FONT_SIZE = 13;

    public string? text { get; construct; }
    public string? icon_name { get; construct; }

    private Gtk.DrawingArea drawing_area;
    private Gtk.Image? overlay_icon;

    public ControlKey.with_text (string text) {
        Object (
            text: text,
            icon_name: null,
            hexpand: false,
            vexpand: false,
            width_request: WIDTH,
            height_request: HEIGHT
        );
    }

    public ControlKey.with_icon (string icon_name) {
        Object (
            text: null,
            icon_name: icon_name,
            hexpand: false,
            vexpand: false,
            width_request: WIDTH,
            height_request: HEIGHT
        );
    }

    construct {
        get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        get_style_context ().add_class (Granite.STYLE_CLASS_ROUNDED);

        drawing_area = new Gtk.DrawingArea () {
            hexpand = true,
            vexpand = true
        };
        drawing_area.set_draw_func (draw_func);

        var overlay = new Gtk.Overlay () {
            child = drawing_area
        };
        if (icon_name != null) {
            overlay_icon = new Gtk.Image () {
                gicon = new GLib.ThemedIcon (icon_name)
            };
            overlay.add_overlay (overlay_icon);
        }

        append (overlay);

        var gesture_event_controller = new Gtk.GestureClick ();
        gesture_event_controller.pressed.connect (on_press_event);
        gesture_event_controller.released.connect (on_release_event);
        this.add_controller (gesture_event_controller);
    }

    private void draw_func (Gtk.DrawingArea drawing_area, Cairo.Context ctx, int width, int height) {
        if (text != null) {
            var color = Gdk.RGBA ();
            color.parse (Warble.ColorPalette.get_text_color ());
            ctx.set_source_rgb (color.red, color.green, color.blue);

            ctx.select_font_face ("Inter", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
            ctx.set_font_size (FONT_SIZE);

            Cairo.TextExtents extents;
            ctx.text_extents (text.to_string (), out extents);
            double x = (WIDTH / 2) - (extents.width / 2 + extents.x_bearing);
            double y = (HEIGHT / 2) - (extents.height / 2 + extents.y_bearing);
            ctx.move_to (x, y);
            ctx.show_text (text.to_string ());
        }
    }

    private void on_press_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        get_style_context ().add_class ("key-pressed");
        clicked ();
    }

    private void on_release_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        get_style_context ().remove_class ("key-pressed");
    }

    public signal void clicked ();

}
