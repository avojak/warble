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

public class Warble.Widgets.ControlKey : Gtk.Box {

    private class KeyImage : Gtk.Box {

        private const int WIDTH = 48;
        private const int HEIGHT = 32;

        public string? text { get; construct; }
        public int y_offset { get; set; }
        public Gtk.Image image;

        public KeyImage (string? text) {
            Object (
                text: text,
                y_offset: 0
            );
        }

        construct {
            image = new Gtk.Image () {
                gicon = new ThemedIcon (Constants.APP_ID + ".control-key"),
                hexpand = false,
                vexpand = false,
                halign = Gtk.Align.CENTER
            };
            append (image);
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            Graphene.Rect bounds;
            this.compute_bounds (this, out bounds);
            Cairo.Context ctx = snapshot.append_cairo (bounds);
            draw (ctx);
        }

        protected bool draw (Cairo.Context ctx) {
            //  base.draw (ctx);
            ctx.save ();
            if (text != null) {
                draw_text (ctx);
            }
            ctx.restore ();
            return false;
        }

        private void draw_text (Cairo.Context ctx) {
            var color = Gdk.RGBA ();
            color.parse (Warble.ColorPalette.TEXT_COLOR.get_value ());
            ctx.set_source_rgb (color.red, color.green, color.blue);

            ctx.select_font_face ("Inter", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
            ctx.set_font_size (13);

            Cairo.TextExtents extents;
            ctx.text_extents (text.to_string (), out extents);
            double x = (WIDTH / 2) - (extents.width / 2 + extents.x_bearing);
            double y = (HEIGHT / 2) - (extents.height / 2 + extents.y_bearing) + y_offset;
            ctx.move_to (x, y);
            ctx.show_text (text.to_string ());
        }

    }

    private static Gtk.CssProvider provider;

    public string? text { get; construct; }
    public string? icon_name { get; construct; }

    private Warble.Widgets.ControlKey.KeyImage key;
    private Gtk.Image? overlay_icon;
    private bool is_pressed = false;

    public ControlKey.with_text (string text) {
        Object (
            text: text,
            icon_name: null
        );
    }

    public ControlKey.with_icon (string icon_name) {
        Object (
            text: null,
            icon_name: icon_name
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/warble/ControlKeyOverlayIcon.css");
    }

    construct {
        var overlay = new Gtk.Overlay ();
        key = new Warble.Widgets.ControlKey.KeyImage (text);
        overlay.child = key;
        if (icon_name != null) {
            overlay_icon = new Gtk.Image () {
                gicon = new GLib.ThemedIcon (icon_name)
            };
            unowned Gtk.StyleContext style_context = overlay_icon.get_style_context ();
            style_context.add_class ("control-key-overlay-icon");
            style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            overlay.add_overlay (overlay_icon);
        }
        append (overlay);

        // I *think* this will work for touchscreens, but I don't have a device to test on :(
        //  add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.TOUCH_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
        //  this.button_press_event.connect ((event) => {
        //      // Don't respond to double or triple-clicks!
        //      if (event.type != Gdk.EventType.BUTTON_PRESS) {
        //          return false;
        //      }
        //      is_pressed = true;
        //      key.y_offset = 2; // Pixels in the icon are shifted down 2 pixels to simulate being pressed
        //      if (overlay_icon != null) {
        //          overlay_icon.margin_top = 2;
        //      }
        //      update_icon ();
        //      clicked ();
        //  });
        //  this.button_release_event.connect (() => {
        //      is_pressed = false;
        //      key.y_offset = 0;
        //      if (overlay_icon != null) {
        //          overlay_icon.margin_top = 0;
        //      }
        //      update_icon ();
        //  });
        //  this.touch_event.connect (() => {
        //      // TODO: Need a way to do this for touchscreens. Not sure how to do this with a single event and
        //      //       without a device to test touch events on.
        //      clicked ();
        //  });

        var gesture_event_controller = new Gtk.GestureClick ();
        gesture_event_controller.pressed.connect (on_press_event);
        gesture_event_controller.released.connect (on_release_event);
        this.add_controller (gesture_event_controller);
    }

    private void on_press_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        is_pressed = true;
        key.y_offset = 2; // Pixels in the icon are shifted down 2 pixels to simulate being pressed
        if (overlay_icon != null) {
            overlay_icon.margin_top = 2;
        }
        update_icon ();
        clicked ();
    }

    private void on_release_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        is_pressed = false;
        key.y_offset = 0;
        if (overlay_icon != null) {
            overlay_icon.margin_top = 0;
        }
        update_icon ();
    }

    private void update_icon () {
        key.image.gicon = new ThemedIcon (Constants.APP_ID + (is_pressed ? ".control-key-pressed" : ".control-key"));
    }

    public signal void clicked ();

}
