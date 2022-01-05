/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Warble.Widgets.Square : Gtk.Image {

    public enum State {
        BLANK,
        CORRECT,
        INCORRECT,
        CLOSE
    }

    private const int SIZE = 64;

    private char _letter = ' ';
    public char letter {
        get { return this._letter; }
        set { this._letter = value; queue_draw (); }
    }

    private State state = State.BLANK;

    public Square () {
        Object (
            gicon: new ThemedIcon (Constants.APP_ID + ".square-blank"),
            pixel_size: SIZE
        );
    }

    protected override bool draw (Cairo.Context ctx) {
        base.draw (ctx);
        ctx.save ();
        draw_letter (ctx);
        ctx.restore ();
        return false;
    }

    private void draw_letter (Cairo.Context ctx) {
        var color = new Granite.Drawing.Color.from_string (Warble.ColorPalette.TEXT.get_value ());
        ctx.set_source_rgb (color.R, color.G, color.B);

        ctx.select_font_face ("Inter", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
	    ctx.set_font_size (30);

        Cairo.TextExtents extents;
        ctx.text_extents (letter.to_string (), out extents);
        double x = (SIZE / 2) - (extents.width / 2 + extents.x_bearing);
        double y = (SIZE / 2) - (extents.height / 2 + extents.y_bearing);
        ctx.move_to (x, y);
        ctx.show_text (letter.to_string ());
    }

    public void boop () {
        //  state = State.CLOSE;
        gicon = new ThemedIcon (Constants.APP_ID + ".square-close");
    }

    public void update_state (Warble.Widgets.Square.State new_state) {
        this.state = new_state;
        switch (new_state) {
            case BLANK:
                gicon = new ThemedIcon (Constants.APP_ID + ".square-blank");
                break;
            case INCORRECT:
                gicon = new ThemedIcon (Constants.APP_ID + ".square-incorrect");
                break;
            case CLOSE:
                gicon = new ThemedIcon (Constants.APP_ID + ".square-close");
                break;
            case CORRECT:
                gicon = new ThemedIcon (Constants.APP_ID + ".square-correct");
                break;
            default:
                assert_not_reached ();
        }
    }

}
