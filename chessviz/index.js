var rootImageURL = "images";
var startPos = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
var moveString = "";
var moves = [];
var currMove = 0;

var eatenPieces = [];

var pos = {
	1 : 'a',
	2 : 'b',
	3 : 'c',
	4 : 'd',
	5 : 'e',
	6 : 'f',
	7 : 'g',
	8 : 'h',
}

var pieces = {};


//e2e4 d2d4 g8f6 g1f3 e7e6 e2e3 f8e7 b1c3 e8g8 f1e2 d7d5 e1g1 b8c6 c1d2 c8d7 f3e5 c6e5 d4e5 f6e4 c3e4 d5e4
colLabels = ["a","b","c","d","e","f","g","h"];
rowLabels = ["8", "7", "6", "5", "4", "3", "2", "1"];

function initPieces(){
	for(var row = 0; row < 8; row++){
		for(var col = 0; col < 8; col++){
			pieces[colLabels[col]+rowLabels[row]] = "0";
		}
	}
};

$( document ).ready(function() {
	initPieces();
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
			$("#board table tr:last").append("<td class='"+c+"' id='"+colLabels[col]+rowLabels[row]+"'></td>");
			black = !black;

			if(col == 7){
				black = !black;
			}
		}
	}

	displayPosition( startPos );
	initOnOffForm();



	function initOnOffForm(){
		var pieceTypes = {
			"white" : [
				{name: "King" ,selector:  "K"},
				{name: "Queen",selector: "Q"},
				{name: "Bishops",selector: "B"},
				{name: "Rooks",selector: "R"},
				{name: "Knights",selector: "N"},
				{name: "Pawns",selector: "P"}
				],
			"black" : [
				{name:"King" ,selector: "k"},
				{name:"Queen" ,selector: "q"},
				{name:"Bishops" ,selector: "b"},
				{name:"Rooks" ,selector: "r"},
				{name:"Knights" ,selector: "n"},
				{name:"Pawns" ,selector: "p"}
				]
		}

		for(var i = 0; i < pieceTypes["white"].length; i++){
			$("#whiteOnOff").append("<p><input type='checkbox' checked value='"+pieceTypes["white"][i].selector+"'></input>"+pieceTypes["white"][i].name+"</p>")
		}
		for(var i = 0; i < pieceTypes["black"].length; i++){
			$("#blackOnOff").append("<p><input type='checkbox' checked value='"+pieceTypes["black"][i].selector+"'></input>"+pieceTypes["black"][i].name+"</p>")
		}

		$("#showControl input").change(function(){
				event.preventDefault();
				var side = $(this).attr('value');
				// becoming checked
				if($(this).is(":checked")){
					if(side == "white"){
						highlightSquares(getControlledSquares(getWhitePieces()), "whiteControl")
					} else {
						highlightSquares(getControlledSquares(getBlackPieces()), "blackControl");
					}
					// $(".blackControl.whiteControl").css("background","green");

				} else{ // becoming unchecked
					if(side == "white"){
						$("td").removeClass("whiteControl");
					} else{
						$("td").removeClass("blackControl");
					}
				}
		});

		$("#onOff input").change(function(){
			c = $(this);
			pieceString = c.attr('value');

			if(c.is(":checked")){
				for(key in pieces){
					if(pieces[key] == pieceString ){
						$("#"+key + " img").show();
					}
				}
			} else {
					for(key in pieces){
						if(pieces[key] == pieceString ){
							$("#"+key + " img").hide();
						}
					}
			}
			event.preventDefault();
		});
	}

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
		from = move.charAt(0)+move.charAt(1);		
		to = move.charAt(2)+move.charAt(3);

		if ($("#"+to).html()!='')
			eatenPieces.push([currMove, $("#"+to).html()]);

		piece = $("#"+from).html();
		$("#"+from).html('').css("outline", "4px solid blue");
		$("#"+to).html(piece).css("outline", "4px solid red");
	}

	function moveBack(move){
		$("#board td").css("outline", "none");
		from = move.charAt(0)+move.charAt(1);
		to = move.charAt(2)+move.charAt(3);


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
		displayPosition(fenString);
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

	// letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
	for(var i = 0; i < 8; i++){
		$("#colSelect").append("<option value='"+colLabels[i]+"'>"+colLabels[i]+"</option>");
		$("#rowSelect").append("<option value='"+i+"'>"+(i+1)+"</option>");
	}

	$("#highlight").submit(function(){
		$("#board td").css("outline", "none");

		col = colLabels.indexOf($("#colSelect").val());
		row = rowLabels[$("#rowSelect").val()];
		//console.log(col+"_"+row);
		$("#"+col+row).css("outline", "4px solid red");
		$("#clear-highlight").show();
		return false;
	});

	$("#clear-highlight").click(function(){
		$("#board td").css("outline", "none");
		$(this).hide();
		return false;
	});
	
	
	var from;
	 $(".pieceImg").draggable({
            revert: true,
			revertDuration:0,
            appendTo: 'body',
            stack: '.pieceImg',
            start: function ( event, ui ) {
                from = ui.helper.parent().attr('id');
				ui.helper.css({'z-index': 100});
            },
            stop: function ( event, ui ) {
				var toRow = Math.round(ui.offset.top/65);
				var toCol = Math.round(ui.offset.left/65);
				var to = pos[toCol+1]+(10-toRow).toString();
				//var to = ui.helper.parent().attr('id');
				
				move = from+to;
				console.log(move);
				
				moveForward(move);
				
				ui.helper.css({'z-index': 10});
            }
     });
		
});




function displayPosition( fen_position ){
	console.log(fen_position);
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
					$("#" + cellId).html("<img class='pieceImg' src='" + imageURL + "'/>");

					pieces[cellId] = chars[c];
					colNum++;
				}
			}
		}
	}
}
