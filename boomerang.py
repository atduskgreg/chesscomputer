import subprocess, time, threading, Queue, re, sys, os, signal
from fysom import Fysom

path = 'C:/Users/Shannon/Documents/School/UROP/Playful Systems/Chesscomputer/'
enginePath = path + sys.argv[1]

gameStatus = {"gameName" : "test",
              "gameString" : "",
              "centipawns" : 0,
              "whiteCP" : [],
              "blackCP" : [],
              "currentMove" : 1,
              "white" : True}

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
        self.uci = uci
        self.queue=queue
    def run(self):
        while True:
            out = self.uci.engine.stdout.readline().strip()
            if out != '':
                self.queue.put(out)
            time.sleep(0.25)

class StockfishManager:
    def __init__(self):
        self.uci = Uci()
        self.q = Queue.Queue()
        self.t = Listener(self.uci, self.q)
        self.t.start()

    def send(self, command):
        self.uci.send(command)
        with open("options/commands.txt", 'a') as f:
            f.write(command + "\r\n")
    
    def get(self):
        line = self.q.get()
        print('     '+line)
        return line

manager = StockfishManager()



def scoreString(scores):
    string = ""
    for i in range(0, len(scores)):
        string += ' ' + str(scores[i])
    return string

def onstockfish(e):
    gameStatus = e.args[0]
    
    open(gameStatus["gameName"]+'_info.txt', 'w').close()
    with open(gameStatus["gameName"]+"_moves.txt", 'w') as f:
        f.write("[Event: " + "" + "]\r\n" +
                "[Site: " + "" + "]\r\n" +
                "[Date: " + "" + "]\r\n" +
                "[Round: " + "" + "]\r\n" +
                "[White: " + "" + "]\r\n" +
                "[Black: " + "" + "]\r\n" +
                "[Result: " + "" + "]\r\n")
        
    manager.send("uci")

def onuciok(e):
    manager.send("isready")
    
def onucinewgame(e):
    currentMove = e.args[2]
    gameStatus = e.args[3]
    name = gameStatus["gameName"]

    currentPosition = e.args[1]
    #moves = "startpos"
    #if (e.args[1]):
    #    moves = " moves " + e.args[1]
        
    manager.send("ucinewgame")
    manager.send("position " + currentPosition)
    manager.send("go " + e.args[0])
    
    with open("options/"+name+"_"+currentMove+"_info.txt", 'w') as f:
        f.write("\r\n" + currentMove + ": ")
    with open("options/"+name+"_"+currentMove+"_moves.txt", 'w') as f:
        f.write("move,cp,player\r\n")
    
def onsearch(e, gameStatus, depth):
    with open("options/"+gameStatus["gameName"]+"_info.txt", 'a') as f:
        f.write(e + '\r\n')
    if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e)
        gameStatus["centipawns"] = int(info.group('cp'))
        if int(info.group('depth')) > depth: # depth 5  
            manager.send("stop")
    if re.search('depth (?P<depth>\d+) seldepth \d+ score mate (?P<mate>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score mate (?P<mate>-?\w+)', e)
        if int(info.group('depth')) > depth: # depth 5
            gameStatus["centipawns"] = int(info.group('mate'))
            manager.send("quit")

def onbestmove(e):
    gameStatus = e.args[1]
    totaMoves = e.args[3]
    name = gameStatus["gameName"]
    currentMove = e.args[4]

    if gameStatus["white"]:
        gameStatus["whiteCP"].append(gameStatus["centipawns"])
        gameStatus["currentMove"]+=1
        turn = "w"
    else:
        gameStatus["blackCP"].append(gameStatus["centipawns"])
        turn = "b"
        
    with open("options/"+name+"_"+currentMove+"_moves.txt", 'a') as f:
            f.write(e.args[0]+","+str(gameStatus["centipawns"])+","+turn+"\r\n")
    gameStatus["white"] = not gameStatus["white"]
    gameStatus["gameString"] += " " + (e.args[0])

    if (gameStatus["currentMove"]<totalMoves):
        manager.send("position " + gameStatus["gameString"])
        manager.send("go " + e.args[2])

def onend(e):
    print "Checkmate"


def onnewgame(e):
    currentPosition = e.args[0]
    
    manager.send("ucinewgame")
    manager.send("position " + currentPosition)
    manager.send("go depth 1")

def onmove(e):
    bestMove = e.args[0]
    movesList = e.args[1]
    currentDepth = e.args[2]
    totalDepth = e.args[3]

    if bestMove not in movesList:
        movesList.append(bestMove)

    if currentDepth <= totalDepth:
        manager.send("go depth " + str(currentDepth))

initialize = Fysom({'initial': 'init',
             'events': [{'name': 'uci','src':'init','dst':'stockfish'},
                        {'name': 'isready','src':'stockfish','dst':'uciok'}],
              'callbacks': {
                  'onstockfish': onstockfish,
                  'onuciok': onuciok } })

search = Fysom({'initial': 'init',
             'events': [{'name': 'newgame','src':'init','dst':'godepth'},
                        {'name': 'searching','src':'godepth','dst':'godepth'},
                        {'name': 'makemove','src':'godepth','dst':'move'},
                        {'name': 'searching','src':'move','dst':'godepth'},
                        {'name': 'newgame','src':'move','dst':'godepth'}],
              'callbacks': {
                  'onnewgame': onnewgame,
                  'onmove': onmove} })

explore = Fysom({'initial': 'init',
             'events': [{'name': 'ucinewgame','src':'init','dst':'goinfinite'},
                        {'name': 'infinite','src':'goinfinite','dst':'goinfinite'},
                        {'name': 'move','src':'goinfinite','dst':'bestmove'},
                        {'name': 'infinite','src':'bestmove','dst':'goinfinite'},
                        {'name': 'ucinewgame','src':'bestmove','dst':'goinfinite'},
                        {'name': 'mate','src':'bestmove','dst':'end'}],
              'callbacks': {
                  'onucinewgame': onucinewgame,
                  'onbestmove': onbestmove,
                  'onend': onend } })
def ongodeeper(e):
    movesList = e.args[0]
    totaDepth = e.args[1]
    currentPosition = e.args[2]
    
    currentDepth = 1
    search.newgame(currentPosition)
    while currentDepth <= totalDepth:
        currentDepth += 1
        while True:
            res = manager.get()
            if re.search('^info', res):
                search.searching()
            if re.search('^bestmove (?P<move>\w+) ', res):
                bestmove = re.search('^bestmove (?P<move>\w+) ', res)
                search.makemove(bestmove.group('move'), movesList, currentDepth, totalDepth)
                break
            
def onexplore(e):
    currentPosition = e.args[0]
    movesList = e.args[1]
    totalMoves = e.args[2]
    depth = e.args[3]                   # depth to stop at while "go infinite"
    searchDepth = e.args[4]
    gameStatus = e.args[5]

    for i in range(len(movesList)):
        move = movesList.pop()
        position = currentPosition + " " + move
        gameStatus["gameString"] = position
        gameStatus["currentMove"] = 1

        explore.ucinewgame(searchDepth, position, move, gameStatus)
        while True:
            res = manager.get()
            if re.search('^info', res):
                explore.infinite()
                onsearch(res, gameStatus, depth)
            if re.search('^bestmove (?P<move>\w+) ', res):
                bestmove = re.search('^bestmove (?P<move>\w+) ', res)
                explore.move(bestmove.group('move'), gameStatus, searchDepth, totalMoves, move)

            if (gameStatus["currentMove"]>=totalMoves):
                break

    boomerang.noMoves()

boomerang = Fysom({'initial': 'start',
             'events': [{'name': 'startsearch','src':'start','dst':'godeeper'},
                        {'name': 'exploremove','src':'godeeper','dst':'explore'},
                        {'name': 'exploremove','src':'explore','dst':'explore'},
                        {'name': 'noMoves','src':'explore','dst':'analyze'}],
              'callbacks': {
                  'ongodeeper': ongodeeper,
                  'onexplore': onexplore
                  } })

movesList = []
currentPosition = "fen r2q2k1/2p1brpp/p1n2n2/1P2p3/4p1b1/1BP5/1P1PQPPP/RNB1K2R w K - 1 2 moves"
totalMoves = 5
depth = 25                  # depth to stop at while "go infinite"
searchDepth = "depth 15"    # "infinite" or "depth #"
totalDepth = 8              # total depth for 'searching' state

while True:                      
    if boomerang.isstate("start"):
        res = manager.get()
        if re.search('^Stockfish', res):
            initialize.uci(gameStatus)
        if re.search('^uciok', res):
            initialize.isready()
        if re.search('^readyok', res):
            boomerang.startsearch(movesList, totalDepth, currentPosition)
    elif boomerang.isstate("godeeper"):
        boomerang.exploremove(currentPosition, movesList, totalMoves, depth, searchDepth, gameStatus)


# Old state machine (for autoplay)       
while False:
    res = manager.get()
    depth = 5                   # depth to stop at while "go infinite"
    searchDepth = "depth 4"     # "infinite" or "depth #"
    totalMoves = 10
    currentPosition = None
    print('     '+res)
    if re.search('^Stockfish', res):
        initialize.uci()
    if re.search('^uciok', res):
        initialize.isready()
    if re.search('^readyok', res):
        explore.ucinewgame(searchDepth, currentPosition)
    if re.search('^info', res):
        explore.infinite()
        onsearch(res, gameStatus, depth)
    if re.search('^bestmove (?P<move>\w+) ', res):
        bestmove = re.search('^bestmove (?P<move>\w+) ', res)
        explore.move(bestmove.group('move'), gameStatus, searchDepth, totalMoves)





##game = Fysom({'initial': 'init',
##             'events': [{'name': 'uci','src':'init','dst':'stockfish'},
##                        {'name': 'isready','src':'stockfish','dst':'uciok'},
##                        {'name': 'ucinewgame','src':'uciok','dst':'goinfinite'},
##                        {'name': 'infinite','src':'goinfinite','dst':'goinfinite'},
##                        {'name': 'move','src':'goinfinite','dst':'bestmove'},
##                        {'name': 'infinite','src':'bestmove','dst':'goinfinite'},
##                        {'name': 'mate','src':'bestmove','dst':'end'}],
##              'callbacks': {
##                  'onstockfish': onstockfish,
##                  'onuciok': onuciok,
##                  'onucinewgame': onucinewgame,
##                  'onbestmove': onbestmove,
##                  'onend': onend } })
