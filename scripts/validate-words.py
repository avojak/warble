#!/usr/bin/env python3

"""
Tool to validate that the list of possible answers (words.txt) is a
strict subset of the dictionary of acceptable words (dictionary.txt).

This script should be run any time a change is made to either file.
"""

with open('../data/words.txt') as words:
    possible_answers = words.readlines()
    possible_answers = [line.rstrip() for line in possible_answers]

with open('../data/dictionary.txt') as dictionary:
    dictionary_words = dictionary.readlines()
    dictionary_words = [line.rstrip() for line in dictionary_words]

for possible_answer in possible_answers:
    if possible_answer not in dictionary_words:
        print(possible_answer, end='\n')