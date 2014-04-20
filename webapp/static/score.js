function calculateScore(pieces){
	
	var pieceValues = {"p" : 1, "b" : 3, "n" : 3, "r" : 5, "q" : 9, "k" : 0};

	var blackValues = 0;
	var whiteValues = 0
	for(var square in pieces){
		var piece = pieces[square];
		if(piece != "0"){ // skip empty squares
			// black
			if(piece.toLowerCase() == piece){
				blackValues += pieceValues[piece.toLowerCase()];
			} else { // white
				whiteValues += pieceValues[piece.toLowerCase()];
			}

		}
	}

	return {"white" : (39 - blackValues), "black": (39 - whiteValues)};;
}