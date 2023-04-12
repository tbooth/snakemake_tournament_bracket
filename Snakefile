# How can we use Snakemake to combine a bunch of files, when each
# job we launch can only combine one pair of files at as time?
#
# This is equivalent to running a tournament bracket, so I'll base my
# example on a "top trumps" tournament.
#
# To generate suitable inputs run:
# $ ./generate_cards.py 64

from glob import glob

# Each "player" is one top trumps card, represented as a JSON file.
ALL_PLAYERS = sorted(glob("all_cards/card_*.json"))
assert len(ALL_PLAYERS) > 1, "Run generate_cards.py to make some input files."

def i_play_match(wildcards):
    """Given start and end indexes, work out the matches that must be played
       to resolve this part of the tournament bracket.
    """
    # Find the range from "matches/{start}-{end}.json"
    range_start = int(wildcards.start)
    range_end = int(wildcards.end)
    player_count = range_end - range_start

    # Sanity check. We should always have at least 2 players here.
    assert player_count >= 2

    if player_count == 2:
        # First round match between two input card files
        return [ ALL_PLAYERS[range_start],
                 ALL_PLAYERS[range_start+1] ]
    elif player_count == 3:
        # Only occurs if len(ALL_PLAYERS) is not a power of 2
        # Match the second and third players and give the first a bye to the second round.
        return [ f"matches/{range_start+1}-{range_end}.json",
                 ALL_PLAYERS[range_start] ]
    else:
        # Given four or more players to match up, split the range to trigger recursion
        midpoint = range_start + (player_count // 2)
        return [ f"matches/{range_start}-{midpoint}.json",
                 f"matches/{midpoint}-{range_end}.json" ]

# Default rule to crown the final winner and print that card
rule champion:
    input:  "matches/0-{}.json".format(len(ALL_PLAYERS))
    shell:
        "echo 'And the winner is...' ; cat {input}"

rule play_match:
    output: "matches/{start}-{end}.json"
    input:  i_play_match
    shell:
        "python3 play_a_match.py {input[0]} {input[1]} > {output}"

