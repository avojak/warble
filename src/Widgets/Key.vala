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

public class Warble.Widgets.Key : Gtk.Box {

    private class KeyImage : Gtk.Box {

        private const int SIZE = 32;

        public char letter { get; construct; }
        public int y_offset { get; set; }
        public Gtk.Image image;

        public KeyImage (char letter) {
            Object (
                letter: letter,
                y_offset: 0
            );
        }

        construct {
            image = new Gtk.Image () {
                gicon = new ThemedIcon (Constants.APP_ID + ".key-blank"),
                pixel_size = SIZE,
                vexpand = false,
                hexpand = false,
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
            draw_letter (ctx);
            ctx.restore ();
            return false;
        }

        private void draw_letter (Cairo.Context ctx) {
            //  var color = new Granite.Drawing.Color.from_string (Warble.ColorPalette.TEXT_COLOR.get_value ());
            //  ctx.set_source_rgb (color.R, color.G, color.B);
            var color = Gdk.RGBA ();
            color.parse (Warble.ColorPalette.TEXT_COLOR.get_value ());
            ctx.set_source_rgb (color.red, color.green, color.blue);

            ctx.select_font_face ("Inter", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
            ctx.set_font_size (15);

            Cairo.TextExtents extents;
            ctx.text_extents (letter.to_string (), out extents);
            double x = (SIZE / 2) - (extents.width / 2 + extents.x_bearing);
            double y = (SIZE / 2) - (extents.height / 2 + extents.y_bearing) + y_offset;
            ctx.move_to (x, y);
            ctx.show_text (letter.to_string ());
        }

    }

    public char letter { get; construct; }

    private Warble.Models.State _state = Warble.Models.State.BLANK;
    public Warble.Models.State state {
        get { return this._state; }
        set { this._state = value; update_icon (); }
    }

    private Warble.Widgets.Key.KeyImage key;
    private bool is_pressed = false;

    public Key (char letter) {
        Object (
            letter: letter
        );
    }

    construct {
        key = new Warble.Widgets.Key.KeyImage (letter);
        append (key);

        // I *think* this will work for touchscreens, but I don't have a device to test on :(
        //  add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.TOUCH_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK);
        //  this.button_press_event.connect ((event) => {
        //      // Don't respond to double or triple-clicks!
        //      if (event.type != Gdk.EventType.BUTTON_PRESS) {
        //          return false;
        //      }
        //      is_pressed = true;
        //      key.y_offset = 2; // Pixels in the icon are shifted down 2 pixels to simulate being pressed
        //      update_icon ();
        //      clicked (letter);
        //  });
        //  this.button_release_event.connect (() => {
        //      is_pressed = false;
        //      key.y_offset = 0;
        //      update_icon ();
        //  });
        //  this.touch_event.connect (() => {
        //      // TODO: Need a way to do this for touchscreens. Not sure how to do this with a single event and
        //      //       without a device to test touch events on.
        //      clicked (letter);
        //  });

        var gesture_event_controller = new Gtk.GestureClick ();
        gesture_event_controller.pressed.connect (on_press_event);
        gesture_event_controller.released.connect (on_release_event);
        this.add_controller (gesture_event_controller);

        Warble.Application.settings.changed.connect ((key) => {
            if (key == "high-contrast-mode") {
                update_icon ();
            }
        });
    }

    private void on_press_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        is_pressed = true;
        key.y_offset = 2; // Pixels in the icon are shifted down 2 pixels to simulate being pressed
        update_icon ();
        clicked (letter);
    }

    private void on_release_event (int n_press, double x, double y) {
        if (n_press != 1) {
            return;
        }
        is_pressed = false;
        key.y_offset = 0;
        update_icon ();
    }

    private void update_icon () {
        bool high_contrast_mode = Warble.Application.settings.get_boolean ("high-contrast-mode");
        switch (state) {
            case BLANK:
                key.image.gicon = new ThemedIcon (Constants.APP_ID + (is_pressed ? ".key-pressed-blank" : ".key-blank"));
                break;
            case INCORRECT:
                key.image.gicon = new ThemedIcon (Constants.APP_ID + (is_pressed ? ".key-pressed-incorrect" : ".key-incorrect"));
                break;
            case CLOSE:
                key.image.gicon = new ThemedIcon (Constants.APP_ID + (is_pressed ? ".key-pressed-close" : ".key-close") + (high_contrast_mode ? "-high-contrast" : ""));
                break;
            case CORRECT:
                key.image.gicon = new ThemedIcon (Constants.APP_ID + (is_pressed ? ".key-pressed-correct" : ".key-correct") + (high_contrast_mode ? "-high-contrast" : ""));
                break;
            default:
                assert_not_reached ();
        }
    }

    public signal void clicked (char letter);

}
