/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Warble.Models.Dictionary : GLib.Object {

    /*
     * The strategy here is to use two sets of words:
     *  1. A dictionary of lots and lots of English words
     *  2. A subset of the dictionary containing the most common words
     *
     * Game answers are selected from the subset to ensure that the answer
     * is, more likely than not, a known word to the user. However, if a 
     * user guesses a word that's not in the subset, we still want to
     * accept the guess if it's a valid English word. Thus, the dictionary.
     * This should make for a better user experience.
     */
    private const string DICTIONARY_FILE_NAME = "dictionary.txt";
    private const string CANDIDATES_FILE_NAME = "words.txt";

    public Gee.Map<int, Gee.List<string>> dictionary_words { get; construct; }
    public Gee.Map<int, Gee.List<string>> candidate_words { get; construct; }

    construct {
        dictionary_words = load_words_file (DICTIONARY_FILE_NAME);
        candidate_words = load_words_file (CANDIDATES_FILE_NAME);
    }

    private Gee.HashMap<int, Gee.List<string>> load_words_file (string filename) {
        var file = GLib.File.new_for_path (Constants.PKG_DATA_DIR + "/" + filename);
        if (!file.query_exists ()) {
            critical ("File (%s) not found", file.get_path ());
        }
        var words = new Gee.HashMap<int, Gee.List<string>> ();
        try {
            var input_stream = new GLib.DataInputStream (file.read ());
            string line;
            while ((line = input_stream.read_line ()) != null) {
                var length = line.length;
                if (!words.has_key (length)) {
                    words.set (length, new Gee.ArrayList<string> ());
                }
                words.get (length).add (line.up ());
            }
        } catch (GLib.Error e) {
            critical ("Error while reading file: %s", e.message);
        }
        return words;
    }

    // Word of the day requires computing a consistent integer value for all users
    // on a daily basis. To do this, we determine the number of days since epoch in
    // the local timezone. Next, we take that number mod the total available words
    // of the given length, and we have an index to fetch the word from the
    // pre-shuffled dictionary.
    public string get_word_of_the_day (GLib.DateTime date, int length) {
        if (!candidate_words.has_key (length)) {
            critical ("No words in dictionary with length %d", length);
        }
        int num_eligible_words = candidate_words.get (length).size;
        debug ("%d candidate words of length %d", num_eligible_words, length);
        GLib.DateTime epoch = new GLib.DateTime.local (1970, 1, 1, 0, 0, 0);
        int days_since_epoch = (int) (date.difference (epoch) / GLib.TimeSpan.DAY);
        debug ("%d days since Unix epoch", days_since_epoch);
        return candidate_words.get (length).get (days_since_epoch % num_eligible_words);
    }

    // Retrieves a evenly distributed random word of the desired length from
    // the dictionary. This may be preferable to 'word of the day' which can only
    // be used, well, once per day.
    public string get_random_word (int length) {
        if (!candidate_words.has_key (length)) {
            critical ("No words in dictionary with length %d", length);
        }
        int num_eligible_words = candidate_words.get (length).size;
        debug ("%d candidate words of length %d", num_eligible_words, length);
        return candidate_words.get (length).get (GLib.Random.int_range (0, num_eligible_words));
    }

    public bool is_word_in_dictionary (string word) {
        return dictionary_words.get (word.length).contains (word);
    }

}
