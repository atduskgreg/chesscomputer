// var net = require('net');
// var client = net.createConnection("/tmp/dgtnixBoard");



var DGT = require('dgtchess');
var board = new DGT.Board('/tmp/dgtnixBoard', {socket : true});

board.on('ready', function() {
  console.log('Serial No:', board.serialNo);
  console.log('Version:', board.versionNo);
  console.log('-----');
});

board.on('data', function(data) {
  console.log('Field:', data.field);
  console.log('Piece:', data.piece);
  console.log('-----');
});

board.on('move', function(move) {
  console.log('Move:', move);
  console.log('-----');
});