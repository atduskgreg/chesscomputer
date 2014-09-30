## Spec for Millionaire Chess Data Anaylsis

### Player Stats

* **Threats** A number from -100-100.
* **Threats significant** "yes" or "no", indicating whether or not this value deviates significantly from the average
* **King safety** A number from -100-100.
* **King safety significant** "yes" or "no", indicating whether or not this value deviates significantly from the average
* **Space** A number from -100-100.
* **Space significant** "yes" or "no", indicating whether or not this value deviates significantly from the average
* **Passed pawns** A number from -100-100.
* **Passed pawns significant** "yes" or "no", indicating whether or not this value deviates significantly from the average
* **Mobility** A number from -100-100.
* **Mobility significant** "yes" or "no", indicating whether or not this value deviates significantly from the average
* **Queen Trade Frequency** A percentage from 0-100 representing how often queen trades occur in their games (0-100). (only present if statistically significant, otherwise it will say "typical")
* **Queen Trade Win Rate** A percentage from 0-100 representing the player's win rate after a queen trade. This could also be considered a stand-in for how good their end-game is (only present if statistically significant, otherwise it will say "typical").
* **Non-Queen Trade Win Rate** A percentage from 0-100 representing the player's win rate in games without a queen trade. (Only present if the Queen Trade Win Rate is significant)
* **Average Win Length** A number indicating average length of their winning games in moves. (only present if statistically significant, otherwise it will say "typical")
* * **Average Win Diff** The difference between their average win and their average game (only present if average win length is statistically significant)
* **Average Loss Length** A number indicating average length of their losing games in moves. (only present if statistically significant, otherwise it will say "typical")
* **Average Loss Diff** The difference between their average loss and their average game (only present if average loss length is statistically significant)
* **Average Game Length** A number indicating length of their average. (only present if either of the previous two stats are statistically significant, otherwise it will say "typical")
 
### Player Matchup

* **Elo Odds** Given the Elo scores of two players facing each other, my [Elo Calculator](http://gregborenstein.com/assets/chess/elo_calculator.html) can tell you the odds of the player with the higher Elo score winning. This takes the form of a percentage or a fractional odds.

* **Relative Characteristics** Given two players we compare their player characteristics (Threats, King safety, Passed Pawns, and Space) to indicate who's stronger in each area. This will be a relative number from -1 to 1 with negative values indicating an advantage for player 2 and positive values indicating an advantage for player 1.

**Example**

<a href="https://www.flickr.com/photos/unavoidablegrain/15300637806" title="Maurice Ashley v. Eugene Perelshteyn by Greg Borenstein, on Flickr"><img src="https://farm6.staticflickr.com/5569/15300637806_5af26c04be_o.png" width="800" height="600" alt="Maurice Ashley v. Eugene Perelshteyn"></a>

**Example** 

    Player 1: 2710
    Player 2: 2680
    => "57% chance of victory for player 1 (about a 3/5 chance of winning)"

* **Average Elo Bracket Game Length** The average game length for players of this Elo bracket. Given in number of moves. Again, given the Elo scores for two players, I'll provide a calculator that will tell you the average game length for their Elo rating.

### Daily Amateur Game Summary

* **Average Length of Games** in the whole tournament. This will be in number of moves.
* **Average Length of Games broken down by Elo** For each Elo bracket in the tournament we'll provide one average game length 
* **Detected Sacrifices (Brilliances)** This will be a list of any games where we detected that someone won the game by making a sacrifice (this is considered a brilliant move, a highlight to be talked about). For each game detected we'll provide: the names of the players, the result (i.e. white won or black won), a list of the pieces that the winning player sacrificed, and a log of the final four moves for each side.
* **Biggest Blunders** This will be the 5 biggest blunders found in the previous day's games. Each blunder will have the name of the player who made the move, the name of the player they were against, elo scores for both players, the move, the score in centipawns for the bad move, and the outcome of the game. (Note: we score blunders on a sliding scale so that for an amateur it has to be a really horrendous move whereas for the pro it just has to be missing a big opportunity).
* **Games with Identical Beginnings** If there are multiple games in the tournament that were identical for a significant number of moves (above a threshold we set), we'll report those. Each entry will include: the names of the players in each game, the number of moves for which the games were identical, the list of identical moves, and the outcomes for each game

### Realtime Position Analysis

* A single number from -100 to 100 where -100 is 100% likelihood that black will win, 0 is 50/50% statistical tie, and 100 is 100% likelihood that white will win. This will be available for each game currently underway for which we have DGT data.

### Opening Descriptions

This is the one that's most up-in-the-air at the moment. We're working with Maurice to elicit from him some explanations of what the various types of openings mean. In other words, when they say "White played a King-side Indian", you should be able to put up a graphic that says something like "King's Indian is an **open** opening. It will likely lead to a **fast** game with a **king-side** attack."

So far, I know that openings are categorized into open, semi-open, and closed as well as king-side v. queen-side. I'm trying to get more explanatory detail of these out of Maurice.