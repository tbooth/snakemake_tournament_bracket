# How can we use Snakemake to combine a bunch of files, when each
# job we launch can only combine one pair of files at as time?
#
# This is equivalent to running a tournament bracket, so I'll base my
# example on a "top trumps" tournament.
#
# To generate suitable inputs run:
# $ ./generate_cards.py 64

from glob import glob
from math import log2

# Each "player" is one top trumps card, represented as a JSON file.
ALL_PLAYERS = sorted(glob("all_cards/card_*.json"))
assert len(ALL_PLAYERS) > 1, "Run generate_cards.py to make some input files."

def match_maker(wc):
    """Given start and end indexes, work out the matches that must be played
       to resolve this part of the tournament bracket.
    """
    # Find the range from "matches/{start}-{end}.json"
    range_start = int(wc.start)
    range_end = int(wc.end)
    player_count = range_end - range_start

    # Sanity check. We should always have at least 2 players here.
    assert player_count >= 2

    if player_count == 2:
        # First round match between two input card files
        return ALL_PLAYERS[range_start:range_end]
    elif player_count == 3:
        # Only occurs if len(ALL_PLAYERS) is not a power of 2
        # Match the first two players and give the third a bye to the second round.
        return [ f"matches/{range_start}-{range_start+2}.json",
                 ALL_PLAYERS[range_start+2] ]
    else:
        # Given four or more players to match up, split the range to trigger recursion
        midpoint = range_start + (player_count // 2)
        return [ f"matches/{range_start}-{midpoint}.json",
                 f"matches/{midpoint}-{range_end}.json" ]

# Crown the final winner
rule champion:
    output: "champion.json"
    input:  "matches/0-{}.json".format(len(ALL_PLAYERS))
    shell:
        "cat {input} > {output}"

# Play a match
# We can work out which round this match is in by calculating int(log2(player_count-1)+1)
rule play_match:
    output: "matches/{start}-{end}.json"
    input:  match_maker
    run:
        round_num = int(log2(int(wildcards.end)-int(wildcards.start)-1)+1)
        print(f"Playing a round {round_num} match...")
        shell("python3 play_a_match.py {input[0]} {input[1]} > {output}")

onsuccess:
    print("And the winner is...")
    shell("cat champion.json")
