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
	
	// small and large thresholds--subject to tweaking
	var smThreshold = 0;
	var lrgThreshold = 100;
	
	var currentBetter = false;
	var idealBetter = false;
	var largeGap = false;
	
	// max and min diff, testing purposes
	var maxDiff = 0;
	var minDiff = 1000;
	for(var i = 1; i < moves.length; i++){
		var diff = idealLine[i].cp - moves[i].cp;
		
		// check that both directions have small gaps
		if (diff > smThreshold)
			idealBetter = true;
		else if (-diff > smThreshold)
			currentBetter = true;
		
		// check if either direction has a large gap
		if (diff>lrgThreshold || (-diff)>lrgThreshold)
			largeGap = true;

		// get max and min (testing purposes)
		if (diff>maxDiff)
			maxDiff = diff;
		if (diff<minDiff)
			minDiff = diff;
			
		if(idealBetter && currentBetter && largeGap){
			isBoomerang = true;
		}
	}
	//for testing thresholds
	//console.log("min: " +minDiff + " max: " +maxDiff);
	//console.log(idealBetter + " " +currentBetter + " " +largeGap);

	return isBoomerang;
}

function compareSearchDepth(a,b) {
  if (a.searchingDepth < b.searchingDepth)
     return -1;
  if (a.searchingDepth > b.searchingDepth)
    return 1;
  return 0;
}