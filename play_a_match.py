#!/usr/bin/env python3
import sys, os
import random
import json

""" Play a match beteen two "top trumps" cards saved as JSON
    files. Indicate the winner by printing the result to
    STDOUT.
"""

try:
    card1 = sys.argv[1]
    card2 = sys.argv[2]
except Exception:
    exit("usage: play_a_match.py <card1.json> <card2.json>")

def match(json1, json2):
    """Decide if player 1 or player 2 wins
    """
    player1 = json.loads(json1)
    player2 = json.loads(json2)
    print(f"Matching {player1['Name']} vs {player2['Name']}.", file=sys.stderr)

    compare_on = random.choice([x for x in player1 if x != "Name"])
    print(f"The criterion is: Highest {compare_on}.", file=sys.stderr)

    if player1[compare_on] > player2[compare_on]:
        print(f"Winner is {player1['Name']} with {player1[compare_on]} vs {player2[compare_on]}.", file=sys.stderr)
        sys.stdout.write(json1)
    elif player2[compare_on] > player1[compare_on]:
        print(f"Winner is {player2['Name']} with {player2[compare_on]} vs {player1[compare_on]}.", file=sys.stderr)
        sys.stdout.write(json2)
    else:
        print(f"It's a tie, with {player2[compare_on]} vs {player1[compare_on]}.", file=sys.stderr)
        # Allocate a random winner.
        sys.stdout.write(random.choice([json1, json2]))


with open(card1) as c1fh:
    with open(card2) as c2fh:
        match(c1fh.read(), c2fh.read())
