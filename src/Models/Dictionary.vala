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

public class Warble.Models.Dictionary : GLib.Object {

    private const string DICTIONARY_FILE_NAME = "dictionary.txt";

    public Gee.Map<int, Gee.List<string>> words_by_length { get; construct; }

    construct {
        var dictionary_file = GLib.File.new_for_path (Constants.PKG_DATA_DIR + "/" + DICTIONARY_FILE_NAME);
        if (!dictionary_file.query_exists ()) {
            critical ("Dictionary file (%s) not found", dictionary_file.get_path ());
        }
        words_by_length = new Gee.HashMap<int, Gee.List<string>> ();
        try {
            var input_stream = new GLib.DataInputStream (dictionary_file.read ());
            string line;
            while ((line = input_stream.read_line ()) != null) {
                var length = line.length;
                if (!words_by_length.has_key (length)) {
                    words_by_length.set (length, new Gee.ArrayList<string> ());
                }
                words_by_length.get (length).add (line.up ());
            }
        } catch (GLib.Error e) {
            critical ("Error while reading dictionary file: %s", e.message);
        }
        for (int i = 0; i < 10; i++) {
            debug (words_by_length.get (5).get (i));
        }
    }

    // Word of the day requires computing a consistent integer value for all users
    // on a daily basis. To do this, we determine the number of days since epoch in
    // the local timezone. Next, we take that number mod the total available words
    // of the given length, and we have an index to fetch the word from the
    // pre-shuffled dictionary.
    public string get_word_of_the_day (GLib.DateTime date, int length) {
        if (!words_by_length.has_key (length)) {
            critical ("No words in dictionary with length %d", length);
        }
        GLib.DateTime epoch = new GLib.DateTime.local (1970, 1, 1, 0, 0, 0);
        int days_since_epoch = (int) (date.difference (epoch) / GLib.TimeSpan.DAY);
        debug ("%d days since Unix epoch", days_since_epoch);
        int num_eligible_words = words_by_length.get (length).size;
        return words_by_length.get (length).get (days_since_epoch % num_eligible_words);
    }

}
