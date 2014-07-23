## Tracking down components used in evaluating positions

The main action takes place in Stockfish's evaluate.cpp file, which has a text-display of the board evaluation that includes these categories:

* "Material"
* "Imbalance"
* "Pawns"
* "Knights"
* "Bishops"
* "Rooks"
* "Queens"
* "Mobility"
* "King safety"
* "Threats"
* "Passed pawns"
* "Space"

[src/evaluate.cpp#L824](https://github.com/mcostalba/Stockfish/blob/master/src/evaluate.cpp#L824)

This seems like exactly what we'd like to capture for each position.

**Theory**

 The idea is to look at the places where players deviated from the best predicted move and what different board positions they chose relative to these categories. And then, on top of that, to group these categories into a 2-by-2: aggressive-defensive, positional-tactical.

Stockfish has a type called Score that is stored as a single number representing the effect of a situation on the midgame and endgame (represented as upper and lower bits of the number):

    inline Score make_score(int mg, int eg) { return Score((mg << 16) + eg); }

(see [src/types.h](https://github.com/mcostalba/Stockfish/blob/master/src/types.h))

### Piece Values

Some individual piece values from spelunking around in types.h:

    PawnValueMg   = 198,   PawnValueEg   = 258,
    KnightValueMg = 817,   KnightValueEg = 846,
    BishopValueMg = 836,   BishopValueEg = 857,
    RookValueMg   = 1270,  RookValueEg   = 1278,
    QueenValueMg  = 2521,  QueenValueEg  = 2558,

    MidgameLimit  = 15581, EndgameLimit  = 3998

evaluate.cpp includes [trace()](https://github.com/mcostalba/Stockfish/blob/master/src/evaluate.cpp#L862), a function that spits out the categories mentioned above.

    /// trace() is like evaluate(), but instead of returning a value, it returns
    /// a string (suitable for outputting to stdout) that contains the detailed
    /// descriptions and values of each evaluation term. It's mainly used for
    /// debugging.
    std::string trace(const Position& pos) {
      return Tracing::do_trace(pos);
    }

### Collaborations

Had an [interesting conversation](https://twitter.com/atduskgreg/status/490251216610684928) with a few people on Twitter that has lead to a couple of interesting collaoration possibilities. Thanks to [Randal Olson](http://twitter.com/randal_olson) I got hooked up with the people who run [chessgames.com](http://chessgames.com) (which I'd already joined to download Maurice's games) to get more convenient access to as much game data as I could possibly work with. I went ahead and downloaded the PGN for all of the games from [the list of Grandmasters participating in the Millionaire Open](http://millionairechess.com/news/registration-list/). I also spoke with Stanford AI researcher [Andrej Karpathy](http://twitter.com/karpathy) who coincidentally happened to be tweeting about spelunking in the Stockfish source code for a Neural Network-based learning project. I reached out to him to share my archive of Maurice's games as well as the Ruby code I used to parse the PGN files. I'm hoping we can collaborate on some NN training because I could really benefit from Andrej's ML expertise.

### From FEN string to Value list

First you have to initialize the position:

    Position::init();

[src/uci.cpp](https://github.com/mcostalba/Stockfish/blob/master/src/uci.cpp)
    pos.set(fen, Options["UCI_Chess960"], Threads.main());

"fen" is the fen string. Options comes from [src/ucioption.h](https://github.com/mcostalba/Stockfish/blob/master/src/ucioption.h)

