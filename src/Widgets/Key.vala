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

public class Warble.Widgets.Key : Gtk.DrawingArea {

    private const int WIDTH = 20;
    private const int HEIGHT = 30;

    public char letter { get; construct; }

    public Key (char letter) {
        Object (
            expand: false,
            margin: 4,
            width_request: WIDTH,
            height_request: HEIGHT,
            letter: letter
        );
    }

    construct {
        draw.connect (on_draw);
    }

    private bool on_draw (Gtk.Widget drawing_area, Cairo.Context ctx) {
        draw_fill (ctx);
        //  draw_outline (ctx);
        draw_letter (ctx);
        return false;
    }

    private void draw_outline (Cairo.Context ctx) {
        //  var color = new Granite.Drawing.Color.from_string (Warble.ColorPalette.SQUARE_BORDER.get_value ());
        //  ctx.set_source_rgb (color.R, color.G, color.B);

        //  ctx.set_line_width (3);
        //  ctx.set_tolerance (0.1);
        //  ctx.set_line_join (Cairo.LineJoin.ROUND);
        
        //  ctx.new_path ();
        //  ctx.move_to (0, 0);
        //  ctx.rel_line_to (SIZE, 0);
        //  ctx.rel_line_to (0, SIZE);
        //  ctx.rel_line_to (-SIZE, 0);
        //  ctx.close_path ();

        //  ctx.stroke ();

        var color = new Granite.Drawing.Color.from_string (Warble.ColorPalette.SQUARE_BORDER.get_value ());
        ctx.set_source_rgb (color.R, color.G, color.B);

        ctx.set_line_width (2);
        ctx.set_tolerance (0.1);
        ctx.set_line_join (Cairo.LineJoin.ROUND);
        
        // Method C: https://www.cairographics.org/cookbook/roundedrectangles/
        var r = 10;
        var x = 5;
        var y = 5;
        var w = WIDTH - 10;
        var h = HEIGHT - 10;
        ctx.new_path ();
        ctx.move_to(x+r,y);
        ctx.line_to(x+w-r,y);
        ctx.curve_to(x+w,y,x+w,y,x+w,y+r);
        ctx.line_to(x+w,y+h-r);
        ctx.curve_to(x+w,y+h,x+w,y+h,x+w-r,y+h);
        ctx.line_to(x+r,y+h);
        ctx.curve_to(x,y+h,x,y+h,x,y+h-r);
        ctx.line_to(x,y+r);
        ctx.curve_to(x,y,x,y,x+r,y);
        ctx.close_path ();

        //  ctx.new_path ();
        //  ctx.move_to (0, 0);
        //  ctx.rel_line_to (SIZE, 0);
        //  ctx.rel_line_to (0, SIZE);
        //  ctx.rel_line_to (-SIZE, 0);
        //  ctx.close_path ();

        ctx.stroke ();
    }

    private void draw_fill (Cairo.Context ctx) {
        var color = new Granite.Drawing.Color.from_string (Warble.ColorPalette.SQUARE_BORDER.get_value ());
        ctx.set_source_rgb (color.R, color.G, color.B);

        ctx.set_line_width (1);
        ctx.set_tolerance (0.1);
        ctx.set_line_join (Cairo.LineJoin.ROUND);
        
        ctx.new_path ();
        ctx.move_to (0, 0);
        ctx.rel_line_to (WIDTH, 0);
        ctx.rel_line_to (0, HEIGHT);
        ctx.rel_line_to (-WIDTH, 0);
        ctx.close_path ();

        ctx.fill ();
    }

    private void draw_letter (Cairo.Context ctx) {
        var color = new Granite.Drawing.Color.from_string (Warble.ColorPalette.TEXT.get_value ());
        ctx.set_source_rgb (color.R, color.G, color.B);

        ctx.select_font_face ("Inter", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
	    ctx.set_font_size (15);

        Cairo.TextExtents extents;
        ctx.text_extents (letter.to_string (), out extents);
        ctx.move_to ((WIDTH / 2) - (extents.width / 2 + extents.x_bearing), (HEIGHT / 2) - (extents.height / 2 + extents.y_bearing));
        ctx.show_text (letter.to_string ());
    }

}
