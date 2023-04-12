#!/usr/bin/env python3
import sys, os
import random
import json

""" Generate a bunch of "top trumps" style cards
    for the specified number of players, with random
    stats.
"""

try:
    number_of_cards = int( sys.argv[1] )
except Exception:
    exit("usage: generate_cards.py <num_cards>")

def main(n):
    print(f"Generating {n} cards in ./all_cards/")

    os.makedirs("all_cards", exist_ok=True)

    for c in range(n):
        with open(f"all_cards/card_{c+1}.json", "w") as cfh:
            json.dump(make_card(), cfh, indent=2)
            cfh.write("\n")

    print("DONE")

def make_card():
    """Generate a top trumps card like:
        Name: Alice Bobbs
        Speed: 120
        Endurance: 8.2
        Power: 87
        Skill: 56
    """
    return dict( Name = make_name(),
                 Speed = random.randint(70, 200),
                 Endurance = round(random.uniform(3.0, 9.9),1),
                 Power = random.randint(15, 100),
                 Skill = random.randint(15, 100), )

def make_name():
    """Make up a random name for a player.
    """
    n_bits = [ "Al Bob Con Sam Ann Ed Gil Mum Liz San Glen Tim Rob Ken Jas Lee Don Prem",
               "der del nel win ack gal son bel beck bock or bon moth",
               "bert wick son beth do wit den reth than thew rine ee ice",
               "H. J. Q. L. D. R.R. X. G. C.",
               "von van don del"]

    combos = ["0 012", "01 012", "02 012", "01 01", "01 02", "0 01", "0 02",
              "01 01-02", "0 02-012", "01 3 02", "3 3 02", "3 4 012", "01 4 02"]

    name = ""
    for i in random.choice(combos):
        try:
            name += random.choice(n_bits[int(i)].split())
        except ValueError:
            name += i

    return name

main(number_of_cards)
