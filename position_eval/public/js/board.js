var numToChar = {
	1 : 'a',
	2 : 'b',
	3 : 'c',
	4 : 'd',
	5 : 'e',
	6 : 'f',
	7 : 'g',
	8 : 'h'
}
var charToNum = {
	'a' : 1,
	'b' : 2,
	'c' : 3,
	'd' : 4,
	'e' : 5,
	'f' : 6,
	'g' : 7,
	'h' : 8
}

var startPos = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
var rootImageURL = "/images";

var newPositionCallback;

var pieces = {};


//e2e4 d2d4 g8f6 g1f3 e7e6 e2e3 f8e7 b1c3 e8g8 f1e2 d7d5 e1g1 b8c6 c1d2 c8d7 f3e5 c6e5 d4e5 f6e4 c3e4 d5e4
colLabels = ["a","b","c","d","e","f","g","h"];
rowLabels = ["8", "7", "6", "5", "4", "3", "2", "1"];

function initBoard(boardSelector, callback){
	newPositionCallback = callback;
	var black = false;
	$(boardSelector).append("<table id='cells'></table>")

	for(var row = 0; row < 8; row++){
		$(boardSelector + " table").append("<tr></tr>");
		for(var col = 0; col < 8; col++){
			var c;
			if(black){
				c = "black";
			} else {
				c = "white";
			}
			$("#board table tr:last").append("<td class='"+c+"' id='"+colLabels[col]+rowLabels[row]+"'></td>");
			black = !black;

			if(col == 7){
				black = !black;
			}
		}
	}
}

function newGame(){
	displayPosition(startPos);
}

function initPieces(){
	for(var row = 0; row < 8; row++){
		for(var col = 0; col < 8; col++){
			pieces[colLabels[col]+rowLabels[row]] = "0";
		}
	}
};




function displayPosition( fen_position ){
	initPieces();
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
					cellId = colLabels[colNum] + rowLabels[row];
					var pieceColor = "black";
					if(chars[c] == chars[c].toUpperCase()){
						pieceColor = "white";
					}

					imageURL = rootImageURL + "/" + pieceColor + "/" + chars[c] + ".png";
					$("#" + cellId).html("<img id='"+chars[c]+"' class='pieceImg' src='" + imageURL + "'/>");

					pieces[cellId] = chars[c];
					colNum++;
				}
			}
		}
	}
	makePiecesDraggable();
}

function getFen( boardArray ) {
	var fen = "";
	for(var j=8; j>0; j--){ // cols
		var empty = 0;
		for(var i=1; i<9; i++){ // rows
			var cell = numToChar[i]+j.toString();
			if(boardArray[cell]!="0"){
				if (empty!=0) {
					fen+=empty;
					empty = 0;
				}
				fen+=boardArray[cell];
			} else {
				empty++;
			}
		}
		if (empty!=0) {
			fen+=empty;
			empty = 0;
		}
		if (j>0)
			fen += "/"
	}
	return fen;
}

function makePiecesDraggable(){
	$(".pieceImg").draggable({
		revert: true,
		revertDuration:0,
		appendTo: 'body',
		stack: '.pieceImg',
		start: dragStart,
		start: dragStart,
		stop: dragStop
	});
}

function dragStart( event, ui ) {
	from = ui.helper.parent().attr('id');
	ui.helper.css({'z-index': 100});
}
		
function dragStop( event, ui ) {
	var cInc = Math.round(ui.position.left/65);
	var rInc = Math.round(ui.position.top/65);
	var toCol = charToNum[from[0]] + cInc;
	var toRow = parseInt(from[1]) - rInc;
	
	var to = numToChar[toCol]+toRow.toString();
	
	if ( $("#"+to).length <= 0 ) {
		eatenPieces.push($("#"+from).children(0).attr('id'));
		$("#"+from).html('');
		pieces[from] = "0";
		updateScore();
	} else if (from != to) {
		var piece = ui.helper.attr('id');
		// if ((piece == piece.toUpperCase() && turn=='w')||(piece != piece.toUpperCase() && turn=='b')) {	
		// 	switchPlayer();
		// }
		
		move = from+to;
		moveForward(move);
		
		// $("#currMove").html(move);
		
		// recalculateControl();
	}
	
	ui.helper.css({'z-index': 2});
}

function moveForward(move){
	$("#board td").css("outline", "none");
	from = move.charAt(0)+move.charAt(1);		
	to = move.charAt(2)+move.charAt(3);

	if ($("#"+to).html()!='')
		eatenPieces.push($("#"+to).children(0).attr('id'));

	piece = $("#"+from).html();
	$("#"+from).html('').css("outline", "4px solid blue");
	$("#"+to).html(piece).css("outline", "4px solid red");
	
	var pcId = $("#"+to).children(0).attr('id');
	pieces[from] = "0";
	pieces[to] = pcId;

	// updateScore();

	
	makePiecesDraggable();
	newPositionCallback(getFen(pieces));	
}

function eatenDragStop( event, ui ) {
	var cellSize = $("#board td").height();
	var row = Math.round( (ui.offset.top-$("#board").position().top)/cellSize - 0.5 );
	var col = Math.round( (ui.offset.left-$("#board").position().left)/cellSize - 0.5 );
	if ( row<8 && col<8) {
		var cell = numToChar[col+1]+(8-row);
		ui.helper.removeClass('eaten').addClass('pieceImg');
		$("#"+cell).append(ui.helper);
		
		pieces[cell] = ui.helper.attr('id');
		eatenPieces.splice(eatenPieces.indexOf(ui.helper.attr('id')), 1);
		
		recalculateControl();
		
		$(".pieceImg").draggable({
			revert: true,
			revertDuration:0,
			appendTo: 'body',
			stack: '.pieceImg',
			start: dragStart,
			start: dragStart,
			stop: dragStop
		});
    }
}