function detectBoomerang(lines){
	var result = {"isBoomerang" :false, "boomerangMoves" : []};
	// the ideal line is the line with the highest
	// search depth
	var sortedLines = lines.sort(compareSearchDepth);
	var idealLine = sortedLines[sortedLines.length-1].moves;
	for(var i = 0; i < sortedLines.length-1; i++){
		isBoomerang = analyzeLine(sortedLines[i].moves, idealLine);
		if(isBoomerang){
			result.isBoomerang = true;
			result.boomerangMoves.push(sortedLines[i].moves[0].move);
		}
	}

	return result;
}

function analyzeLine(moves, idealLine){
	var isBoomerang = false;
	for(var i = 1; i < moves.length; i++){
		// look for crossing between the two lines
		var prevDir = ((idealLine[i-1].cp - moves[i-1].cp) > 0);
		var currDir = ((idealLine[i].cp - moves[i].cp) > 0);


		if(prevDir != currDir){
			isBoomerang = true;
		}
	}

	return isBoomerang;
}

function compareSearchDepth(a,b) {
  if (a.searchingDepth < b.searchingDepth)
     return -1;
  if (a.searchingDepth > b.searchingDepth)
    return 1;
  return 0;
}