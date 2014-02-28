var rootImageURL = "images";
var startPos = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
var moveString = "";
var moves = [];
var currMove = 0;

var eatenPieces = [];

var pos = {
	"a" : 0,
	"b" : 1,
	"c" : 2,
	"d" : 3,
	"e" : 4,
	"f" : 5,
	"g" : 6,
	"h" : 7,
}
//e2e4 d2d4 g8f6 g1f3 e7e6 e2e3 f8e7 b1c3 e8g8 f1e2 d7d5 e1g1 b8c6 c1d2 c8d7 f3e5 c6e5 d4e5 f6e4 c3e4 d5e4

$( document ).ready(function() {
	black = false;

	for(var row = 0; row < 8; row++){
		$("#board table").append("<tr></tr>");
		for(var col = 0; col < 8; col++){
			var c;
			if(black){
				c = "black";
			} else {
				c = "white";
			}
			$("#board table tr:last").append("<td class='"+c+"' id='"+col+"_"+row+"'></td>");
			black = !black;

			if(col == 7){
				black = !black;
			}
		}
	}

	displayPosition( startPos );
	
	function switchPlayer() {
		if (black) {
			$('#turn').html("BLACK");
		} else {
			$('#turn').html("WHITE");
		}
		black = !black;
	}
	function moveForward(move){
		$("#board td").css("outline", "none");
		from = pos[move.charAt(0)]+"_"+(8-parseInt(move.charAt(1)));
		to = pos[move.charAt(2)]+"_"+(8-parseInt(move.charAt(3)));
		console.log(from + " " + to);
		
		if ($("#"+to).html()!='') 
			eatenPieces.push([currMove, $("#"+to).html()]);
		
		piece = $("#"+from).html();
		$("#"+from).html('').css("outline", "4px solid blue");
		$("#"+to).html(piece).css("outline", "4px solid red");
	}
	
	function moveBack(move){
		$("#board td").css("outline", "none");
		from = pos[move.charAt(0)]+"_"+(8-parseInt(move.charAt(1)));
		to = pos[move.charAt(2)]+"_"+(8-parseInt(move.charAt(3)));
		console.log(to + " " + from);

		
		piece = $("#"+to).html();
		if (eatenPieces.length>0 && currMove == eatenPieces[eatenPieces.length-1][0])
			$("#"+to).html(eatenPieces.pop()[1]);
		else
			$("#"+to).html('');
		$("#"+from).html(piece);
		
		prevMove = moves[currMove-1];
		prevFrom = pos[prevMove.charAt(0)]+"_"+(8-parseInt(prevMove.charAt(1)));
		prevTo = pos[prevMove.charAt(2)]+"_"+(8-parseInt(prevMove.charAt(3)));
		$("#"+prevTo).css("outline", "4px solid red");
		$("#"+prevFrom).css("outline", "4px solid blue");
	}
	
	$("#display").click(function() {
		var fenString = $('#f').val();
		display.Position(fenString);
	});
	
	$("#start").click(function() {
		displayPosition( startPos );
		$('#turn').html("WHITE");
		moveString = $('#g').val();
		moves = moveString.split(" ");
		$('#moves').html(moveString);
		currMove = 0;
		$('#currMove').html(moves[currMove]);
		moveForward(moves[currMove]);
	});
	
	$("#prev").click(function() {
		if (currMove>0){
			moveBack(moves[currMove]);
			currMove -= 1;
			$('#currMove').html(moves[currMove]);
			switchPlayer();
		}
	});
	
	$("#next").click(function() {
		if (currMove<moves.length-1){
			currMove += 1;
			$('#currMove').html(moves[currMove]);
			moveForward(moves[currMove]);
			switchPlayer();
		}
	});
	
	letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
	for(var i = 0; i < 8; i++){
		$("#colSelect").append("<option value='"+letters[i]+"'>"+letters[i]+"</option>");
		$("#rowSelect").append("<option value='"+i+"'>"+(i+1)+"</option>");
	}
	
	$("#highlight").submit(function(){
		$("#board td").css("outline", "none");

		col = letters.indexOf($("#colSelect").val());
		row = $("#rowSelect").val();
		console.log(col+"_"+row);
		$("#"+col+"_"+row).css("outline", "4px solid red");
		$("#clear-highlight").show();
		return false;
	});

	$("#clear-highlight").click(function(){
		$("#board td").css("outline", "none");
		$(this).hide();
		return false;
	});
});






function displayPosition( fen_position ){
	console.log(fen_position);
	$(".pieceImg").hide();
	parts = fen_position.split(" ");
	//updateTurn(parts[1]);

	rows = parts[0].split("/");

	for(var row = 0; row < rows.length; row++){
		if(rows[row] == "8"){ // empty row
			continue;
		} else {
			chars = rows[row].split("");
			// if(cols.length != 8){
			// 	logError("row " + (row+1) + " is the wrong length: " + cols.length);
			// }

			var colNum = 0;
			for(var c = 0; c < chars.length; c++){
				if(chars[c].match(/\d/)){
					numSkips = parseInt(chars[c]);
					colNum += numSkips;
				} else {
					cellId = colNum + "_" + row;

					var pieceColor = "black";
					if(chars[c] == chars[c].toUpperCase()){
						pieceColor = "white";
					}

					imageURL = rootImageURL + "/" + pieceColor + "/" + chars[c] + ".png";
					$("#" + cellId).html("<img class='pieceImg' src='" + imageURL + "'/>");
					colNum++;
				}
			}
		}
	}

	//$("#fen-input textarea").val(fen_position);
	//logMsg("board loaded from fen:\n" + fen_position);

}
