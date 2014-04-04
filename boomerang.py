import subprocess, time, threading, Queue, re, sys, os, signal
from fysom import Fysom

path = 'C:/Users/Shannon/Documents/School/UROP/Playful Systems/Chesscomputer/'
enginePath = path + sys.argv[1]

# REMEMBER TO CHANGE: gameName, startpos, startPlayer
gameStatus = {"gameName" : "180",
              "startpos" : "2r3k1/1q1r1pbp/p4np1/Bp1bp3/8/P1N2P1P/1PP2QP1/3RRBK1 b - - 0 1",
              "moves" : [],
              "fen" : True,
              "centipawns" : 0,
              "currentMove" : 1,
              "startPlayer" : 'w',
              "player" : 'w'}

movesList = []
movesListCP = []
cp = 0
totalMoves = 5
searchingDepth = 8          # total depth for 'searching' state
exploreDepth = "depth 15"   # depth for 'exploring state. "infinite" or "depth #"



class Uci:
    engine = subprocess.Popen(
        enginePath,
        universal_newlines=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE
    )
    
    def send(self, command):
        print(command)
        self.engine.stdin.write(command+'\n')

    def nextMove():
        return 0
    
class Listener(threading.Thread):
    def __init__(self, uci, queue):
        threading.Thread.__init__(self)
        self._uci = uci
        self._queue=queue
    def run(self):
        while True:
            out = self._uci.engine.stdout.readline().strip()
            if out != '':
                self._queue.put(out)
            #time.sleep(0.25)

class StockfishManager:
    def __init__(self):
        self._uci = Uci()
        self._q = Queue.Queue()
        self._t = Listener(self._uci, self._q)
        self._t.start()

    def send(self, command):
        self._uci.send(command)
    
    def get(self):
        line = self._q.get()
        print('     '+line)
        return line

    def position(self, startpos, isFen, moves):
        fen = ""
        if isFen:
            fen = "fen " 
        position = "position " + fen + startpos
        
        if len(moves)>0:
            position += " moves"
            for i in moves:
                position += (" " + i)
        self.send(position)

    def go(self, depth):
        self.send("go " + depth)
    def uci(self):
        self.send("uci")
    def isready(self):
        self.send("isready")
    def ucinewgame(self):
        self.send("ucinewgame")
    def end(self):
        self.send("quit")
        
manager = StockfishManager()

"""
INITIALIZE
State machine for starting Stockfish
"""
def onstockfish(e):
    gameStatus = e.args[0]
    with open(gameStatus["gameName"]+"_info.txt", 'w') as f:
        f.write("Event,Site,Date,Round,White,Black,Result\r\n")
    manager.uci()

def onuciok(e):
    manager.isready()

initialize = Fysom({'initial': 'init',
             'events': [{'name': 'uci','src':'init','dst':'stockfish'},
                        {'name': 'isready','src':'stockfish','dst':'uciok'}],
              'callbacks': {
                  'onstockfish': onstockfish,
                  'onuciok': onuciok } })

"""
SEARCH
State machine, takes in one position, searches at increasing depth for next move
Returns list of possible moves
"""
def onnewgame(e):
    gameStatus = e.args[0]

    

    startpos = gameStatus["startpos"]
    gameStatus["startPlayer"] = gameStatus["startpos"].split(' ')[1]    #set starting player from fen string
    fen = gameStatus["fen"]
    moves = gameStatus["moves"]
    
    manager.ucinewgame()
    manager.position(startpos, fen, moves)
    manager.go("depth 1")

def ongodepth(e, c):
    global cp
    if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e)
        cp = int(info.group('cp'))

def onmove(e):
    global cp
    bestMove = e.args[0]
    movesList = e.args[1]
    movesListCP = e.args[2]
    currentDepth = e.args[3]
    searchingDepth = e.args[4]
    #cp = e.args[5]

    if bestMove not in movesList:
        movesList.append(bestMove)
        movesListCP.append(cp)

    if currentDepth <= searchingDepth:
        manager.go("depth " + str(currentDepth))

search = Fysom({'initial': 'init',
             'events': [{'name': 'newgame','src':'init','dst':'godepth'},
                        {'name': 'searching','src':'godepth','dst':'godepth'},
                        {'name': 'makemove','src':'godepth','dst':'move'},
                        {'name': 'searching','src':'move','dst':'godepth'},
                        {'name': 'newgame','src':'move','dst':'godepth'}],
              'callbacks': {
                  'onnewgame': onnewgame,
                  'onmove': onmove} })

"""
EXPLORE
State machine, takes list of possible moves, plays out game
"""
def onucinewgame(e):
    currentMove = e.args[2]
    gameStatus = e.args[3]
    player = gameStatus["player"]
    name = gameStatus["gameName"]
    moves = gameStatus["moves"]
    fen = gameStatus["fen"]
    moveCP = str(movesListCP.pop())

    startpos = e.args[1]

    manager.ucinewgame()
    manager.position(startpos, fen, moves)
    manager.go(e.args[0])
    
    with open("options/"+name+"_"+currentMove+"_info.txt", 'w') as f:
        f.write(currentMove + ": "+"\r\n")
    with open("options/"+name+"_"+currentMove+"_moves.csv", 'w') as f:
        f.write("move,cp,player\r\n")
        f.write(currentMove+","+moveCP+","+player+"\r\n")
    
def onsearch(e, gameStatus):
    with open("options/"+gameStatus["gameName"]+"_info.txt", 'a') as f:
        f.write(e + '\r\n')
    if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e)
        gameStatus["centipawns"] = int(info.group('cp'))

def onbestmove(e):
    gameStatus = e.args[1]
    totalMoves = e.args[3]
    name = gameStatus["gameName"]
    currentMove = e.args[4]
    startpos = gameStatus["startpos"]
    fen = gameStatus["fen"]
    moves = gameStatus["moves"]

    if gameStatus["player"] == gameStatus["startPlayer"]:
        gameStatus["currentMove"]+=1
                
    if gameStatus["player"] == 'w':
        gameStatus["player"] = 'b'
        gameStatus["centipawns"] *= -1
    else:
        gameStatus["player"] = 'w'
        
        
    with open("options/"+name+"_"+currentMove+"_moves.csv", 'a') as f:
            f.write(e.args[0]+","+ str(gameStatus["centipawns"]) +","+gameStatus["player"]+"\r\n")
    gameStatus["moves"].append(e.args[0])

    if (gameStatus["currentMove"]<totalMoves):
        manager.position(startpos, fen, moves)
        manager.go(e.args[2])

explore = Fysom({'initial': 'init',
             'events': [{'name': 'ucinewgame','src':'init','dst':'goinfinite'},
                        {'name': 'infinite','src':'goinfinite','dst':'goinfinite'},
                        {'name': 'move','src':'goinfinite','dst':'bestmove'},
                        {'name': 'infinite','src':'bestmove','dst':'goinfinite'},
                        {'name': 'ucinewgame','src':'bestmove','dst':'goinfinite'},
                        {'name': 'mate','src':'bestmove','dst':'end'}],
              'callbacks': {
                  'onucinewgame': onucinewgame,
                  'onbestmove': onbestmove } })


def ongodeeper(e):
    movesList = e.args[0]
    movesListCP = e.args[1]
    totaDepth = e.args[2]
    gameStatus = e.args[3]
    cp = e.args[4]
    
    currentDepth = 1
    search.newgame(gameStatus)
    while currentDepth <= searchingDepth:
        currentDepth += 1
        while True:
            res = manager.get()
            if re.search('^info', res):
                search.searching()
                ongodepth(res, cp)
            if re.search('^bestmove (?P<move>\w+) ', res):
                bestmove = re.search('^bestmove (?P<move>\w+) ', res)
                search.makemove(bestmove.group('move'), movesList, movesListCP, currentDepth, searchingDepth, cp)
                break
            
def onexplore(e):
    gameStatus = e.args[4]
    
    movesList = e.args[0]
    movesListCP = e.args[1]
    totalMoves = e.args[2]
    exploreDepth = e.args[3]

    startpos = gameStatus["startpos"]

    for i in range(len(movesList)):
        move = movesList.pop()
        gameStatus["moves"] = [move]
        gameStatus["currentMove"] = 1
        gameStatus["player"] = gameStatus["startPlayer"]

        explore.ucinewgame(exploreDepth, startpos, move, gameStatus)
        while True:
            res = manager.get()
            if re.search('^info', res):
                explore.infinite()
                onsearch(res, gameStatus)
            if re.search('^bestmove (?P<move>\w+) ', res):
                bestmove = re.search('^bestmove (?P<move>\w+) ', res)
                explore.move(bestmove.group('move'), gameStatus, exploreDepth, totalMoves, move)

            if (gameStatus["currentMove"]>=totalMoves):
                break

    boomerang.noMoves()
    
def onanalyze(e):
    manager.end()
    
    
boomerang = Fysom({'initial': 'start',
             'events': [{'name': 'startsearch','src':'start','dst':'godeeper'},
                        {'name': 'exploremove','src':'godeeper','dst':'explore'},
                        {'name': 'exploremove','src':'explore','dst':'explore'},
                        {'name': 'noMoves','src':'explore','dst':'analyze'}],
              'callbacks': {
                  'ongodeeper': ongodeeper,
                  'onexplore': onexplore
                  } })

while True:                      
    if boomerang.isstate("start"):
        res = manager.get()
        if re.search('^Stockfish', res):
            initialize.uci(gameStatus)
        if re.search('^uciok', res):
            initialize.isready()
        if re.search('^readyok', res):
            boomerang.startsearch(movesList, movesListCP, searchingDepth, gameStatus, cp)
    elif boomerang.isstate("godeeper"):
        boomerang.exploremove(movesList, movesListCP, totalMoves, exploreDepth, gameStatus)

