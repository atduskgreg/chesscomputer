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
	
	var smThreshold = 0;
	var lrgThreshold = 50;
	var maxDiff = 0;
	var minDiff = 1000;
	var currentBetter = false;
	var idealBetter = false;
	var largeGap = false;
	for(var i = 1; i < moves.length; i++){
		// look for gap of 100 centipawns (and reverse of that gap)
		var diff = idealLine[i].cp - moves[i].cp;
		if (diff > smThreshold)
			idealBetter = true;
		else if (-diff > smThreshold)
			currentBetter = true;
		
		if (diff>lrgThreshold || (-diff)>lrgThreshold)
			largeGap = true;

		if (diff>maxDiff)
			maxDiff = diff;
		if (diff<minDiff)
			minDiff = diff;
			
		if(idealBetter && currentBetter && largeGap){
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