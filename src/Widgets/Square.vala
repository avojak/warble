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

public class Warble.Widgets.Square : Gtk.Box {

    private const int SIZE = 64;

    private char _letter = ' ';
    public char letter {
        get { return this._letter; }
        set { this._letter = value; queue_draw (); }
    }

    private Warble.Models.State _state = Warble.Models.State.BLANK;
    public Warble.Models.State state {
        get { return this._state; }
        set { this._state = value; update_icon (); }
    }

    public Gtk.Image image;

    public Square () {
        Object (
            
        );
    }

    construct {
        image = new Gtk.Image () {
            gicon = new ThemedIcon (Constants.APP_ID + ".square-blank"),
            pixel_size = SIZE
        };
        append (image);

        Warble.Application.settings.changed.connect ((key) => {
            if (key == "high-contrast-mode") {
                update_icon ();
            }
        });
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
        ctx.set_font_size (30);

        Cairo.TextExtents extents;
        ctx.text_extents (letter.to_string (), out extents);
        double x = (SIZE / 2) - (extents.width / 2 + extents.x_bearing);
        double y = (SIZE / 2) - (extents.height / 2 + extents.y_bearing);
        ctx.move_to (x, y);
        ctx.show_text (letter.to_string ());
    }

    public void update_icon () {
        bool high_contrast_mode = Warble.Application.settings.get_boolean ("high-contrast-mode");
        switch (state) {
            case BLANK:
                image.gicon = new ThemedIcon (Constants.APP_ID + ".square-blank");
                break;
            case INCORRECT:
                image.gicon = new ThemedIcon (Constants.APP_ID + ".square-incorrect");
                break;
            case CLOSE:
                image.gicon = new ThemedIcon (Constants.APP_ID + ".square-close" + (high_contrast_mode ? "-high-contrast" : ""));
                break;
            case CORRECT:
                image.gicon = new ThemedIcon (Constants.APP_ID + ".square-correct" + (high_contrast_mode ? "-high-contrast" : ""));
                break;
            default:
                assert_not_reached ();
        }
    }

}
