var apiURL = "http://chess-archive-server.herokuapp.com"
function getNextPosition(){
	$.ajax({
		type:"GET",
		dataType:"jsonp",
		url: apiURL + "/next_position",

		success:function(data){
			var posID = data.position_id;
			$('#current').text(posID);
			// call to boomerang_server.py
			$.getJSON( "/boomerang?f=" + data.fen, function( data ) {
				var boomerangResult = detectBoomerang(data);
				var isBoomerang = false;
				var line;
				var cp;
				var depth;
				
				// check each move to see if it is listed in boomerangResults
				$.each(data, function( index, element ) {
					var firstMove = element.moves[0];
					// if boomerang found, populate line/cp arrays
					if(boomerangResult.boomerangMoves.indexOf(firstMove.move) != -1){
						isBoomerang = true;
						line = [];
						cp = [];
						depth = element.searchingDepth;
						
						$.each(element.moves, function( index, m ) {
							line.push(m.move);
							cp.push(m.cp);
						});
						console.log("Found boomerang");
						return false; // break
					}
				});
				
				// post results
				if(isBoomerang){
					updatePosition( posID, isBoomerang, line, cp, depth );
				} else {
					updatePosition( posID, isBoomerang );
				}
			});
		}
	});
}


function updatePosition(positionId, isBoomerang, moves, scores, depth){
	$.ajax({
		type:"POST",
		crossDomain: true,
		url: apiURL + "/positions/"+positionId+"",
		data: {"is_boomerang" : isBoomerang,
				"moves": moves,
				"scores": scores,
				"depth": depth},

		success:function(data){
			$('#checked').text(positionId);
			if (recurse) {
				getNextPosition();
			} else {
				$('#stopping').text("Stopped");
			}
		}
	});
}

$( document ).ready(function() {

	// start searching
	$('#boomerang').click(function(){
		recurse = true;
		getNextPosition();
		$('#stopping').text("");
	});
	
	// stop searching
	$('#stop').click(function(){
		recurse = false;
		$('#stopping').text("Stopping after current position completes.");
	});
});