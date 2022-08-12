/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Widgets.Row : GLib.Object {

    private Gee.List<Warble.Widgets.Square> squares = new Gee.ArrayList<Warble.Widgets.Square> ();

    public void add_square (Warble.Widgets.Square square) {
        squares.add (square);
    }

}
