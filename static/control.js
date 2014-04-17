// given a direction and a starting position,
// return an array of squares to search
// moving out from the starting position
function squareRay(direction, col, row){
  var result = [];
  var p = {x: col + direction.x, y:row+direction.y};
  while(onBoard(p.x,p.y)){
    result.push({x: p.x, y: p.y});

    p.x += direction.x;
    p.y += direction.y;
  }

  return result;
}

// given a starting position,
// return a list of squares to
// which a knight can move from there
function knightMoves(col, row){
  var possibleMoves = [
    {x:col-1, y:row-2},
    {x:col+1, y:row-2},
    {x:col-2, y:row-1},
    {x:col+2, y:row-1},
    {x:col-2, y:row+1},
    {x:col+2, y:row+1},
    {x:col-1, y:row+2},
    {x:col+1, y:row+2}
  ];

  var result = [];
  for(var i = 0; i < possibleMoves.length;i++){
    if(onBoard(possibleMoves[i].x,possibleMoves[i].y) ){
      result.push(possibleMoves[i]);
    }
  }

  return result;
}

function getPiecePositions(piece){
  var result = [];
  for(p in pieces){
    if(pieces[p] == piece){
      result.push(positionStringToVector(p));
    }
  }
  return result;
}

function getControlledSquares(piecesArray){
  var result = [];
  for(var p = 0; p < piecesArray.length; p++){
    var positions = getPiecePositions(piecesArray[p]);
    for(var i = 0; i < positions.length; i++){

      upLeft = {x:1, y:1};
      up = {x:0, y: 1};
      upRight = {x:-1, y: 1};
      right = {x:1, y:0};
      downRight = {x:1, y:-1};
      down = {x:0, y:-1};
      downLeft = {x:-1, y:-1};
      left = {x:-1, y:0};
      switch(piecesArray[p].toLowerCase()){
      case 'p':
        var move;
        // console.log("here");
        //white and black move in opposite directions
        if(piecesArray[p] == "P"){
          move = up;
        } else {
          move = down;
        }
        
        result.push.apply(result, getUnoccupied([getNeighbor(positions[i], move)]));
        break;
      case 'n':
          result.push.apply(result,getUnoccupied(knightMoves(positions[i].x, positions[i].y)));
          break;
      case 'b':
        result.push.apply(result,getUntilOccupied(squareRay(upRight,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(downRight,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(upLeft,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(downLeft,positions[i].x, positions[i].y)));
        break;
      case 'r':
        result.push.apply(result,getUntilOccupied(squareRay(left,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(right,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(up,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(down,positions[i].x, positions[i].y)));
        break;
      case 'q':
        result.push.apply(result,getUntilOccupied(squareRay(upRight,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(downRight,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(upLeft,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(downLeft,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(left,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(right,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(up,positions[i].x, positions[i].y)));
        result.push.apply(result,getUntilOccupied(squareRay(down,positions[i].x, positions[i].y)));
        break;
      case 'k':
        result.push.apply(result,getUnoccupied(getNeighbors(positions[i], [up,upRight,right,downRight,down,downLeft,left,upLeft])));
        break;

      }
    }
  }
  return result;
}

function getWhitePieces(){
  return(["K", "Q","R","B","N", "P"]);
}

function getBlackPieces(){
  return(["k", "q","r","b","n", "p"]);
}

function getNeighbors(p, dArray){
  var result = [];
  for(var i = 0; i < dArray.length; i++){
    result.push(getNeighbor(p, dArray[i]));
  }
  return result;
}

function getNeighbor(p, d){
  return {x: p.x + d.x, y: p.y + d.y};
}

function getUnoccupied(squares){
  var result = [];
  for(var i = 0; i < squares.length; i++){
    if(!squareIsOccupied(squares[i].x, squares[i].y)){
      result.push(squares[i]);
    }
  }
  return result;
}

function getUntilOccupied(squares){
  var result = [];
  for(var i = 0; i < squares.length; i++){
    if(squareIsOccupied(squares[i].x, squares[i].y)){
      break;
    }

    result.push(squares[i]);

  }
  return result;
}


function squareIsOccupied(col, row){
  return (pieces[stringForSquare(col,row)] != "0");
}

function selectSquare(col, row){
  return $("#" + stringForSquare(col, row));
}

function stringForSquare(col, row){
  return (colLabels[col] + rowLabels[7-row]);
}

function clearHighlights(){
  $("td").removeClass("blackControl");
  $("td").removeClass("whiteControl");
}

function highlightSquares(arrayP, className){
  for(i = 0; i < arrayP.length; i++){
    highlightSquare(arrayP[i], className);
  }
}

function highlightSquare(p, className){
  selectSquare(p.x,p.y).addClass(className);
}

// parse a position string like "a5", "d6", etc
// into an object with corresponding x,y keys:
// "a5" => {x: 1, y: 5}
function positionStringToVector(pieceString){
  parts = pieceString.split('');
  col = colLabels.indexOf(parts[0]);
  row = parseInt(parts[1]-1);
  return {x: col, y: row};
}

// Helpers
function onBoard(col, row){
  return (col < 8 && row < 8 && col >= 0 && row >=0);
}
