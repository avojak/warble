/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Square : Gtk.DrawingArea {

    private const int SIZE = 64;

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

    //  public Gtk.Image image;

    public Square () {
        Object (
            hexpand: false,
            vexpand: false,
            width_request: 64,
            height_request: 64
        );
    }

    construct {
        get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        get_style_context ().add_class (Granite.STYLE_CLASS_ROUNDED);
        //  image = new Gtk.Image () {
        //      gicon = new ThemedIcon (Constants.APP_ID + ".square-blank"),
        //      pixel_size = SIZE
        //  };
        //  append (image);

        set_draw_func (draw_func);

        Warble.Application.settings.changed.connect ((key) => {
            if (key == "high-contrast-mode") {
                update_style ();
            }
        });
    }

    private void draw_func (Gtk.DrawingArea drawing_area, Cairo.Context ctx, int width, int height) {
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

    //  public override void snapshot (Gtk.Snapshot snapshot) {
    //      Graphene.Rect bounds;
    //      this.compute_bounds (this, out bounds);
    //      Cairo.Context ctx = snapshot.append_cairo (bounds);
    //      draw (ctx);
    //  }

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

    public void update_style () {
        clear_style_classes ();
        //  bool high_contrast_mode = Warble.Application.settings.get_boolean ("high-contrast-mode");
        switch (state) {
            case BLANK:
                //  image.gicon = new ThemedIcon (Constants.APP_ID + ".square-blank");
                break;
            case INCORRECT:
                get_style_context ().add_class ("guess-incorrect");
                //  image.gicon = new ThemedIcon (Constants.APP_ID + ".square-incorrect");
                break;
            case CLOSE:
                get_style_context ().add_class ("guess-close");
                //  image.gicon = new ThemedIcon (Constants.APP_ID + ".square-close" + (high_contrast_mode ? "-high-contrast" : ""));
                break;
            case CORRECT:
                get_style_context ().add_class ("guess-correct");
                //  image.gicon = new ThemedIcon (Constants.APP_ID + ".square-correct" + (high_contrast_mode ? "-high-contrast" : ""));
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
