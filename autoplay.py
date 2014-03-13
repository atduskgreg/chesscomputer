import subprocess, time, threading, Queue, re, sys, os, signal
from fysom import Fysom

path = 'C:/Users/Shannon/Documents/School/UROP/Playful Systems/Chesscomputer/'
enginePath = path + sys.argv[1]

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

        

uci = Uci()
gameStatus = {"gameString" : "",
              "centipawns" : 0,
              "whiteCP" : [],
              "blackCP" : [],
              "currentMove" : 1,
              "white" : True}

q = Queue.Queue()
class Listener(threading.Thread):
    def run(self):
        while True:
            out = uci.engine.stdout.readline().strip()
            if out != '':
                q.put(out)
            time.sleep(0.25)
            
t = Listener()
t.start()

def scoreString(scores):
    string = ""
    for i in range(0, len(scores)):
        string += ' ' + str(scores[i])
    return string

def onuci(e):
    print 'Prep'
    uci.send("uci")

def onisready(e):
    uci.send("isready")
    
def onucinewgame(e):
    uci.send("ucinewgame")
    uci.send("position startpos")
    uci.send("go infinite")
    open('_info.txt', 'w').close()
    with open("_moves.txt", 'w') as f:
        f.write("[Event: " + "" + "]\r\n" +
                "[Site: " + "" + "]\r\n" +
                "[Date: " + "" + "]\r\n" +
                "[Round: " + "" + "]\r\n" +
                "[White: " + "" + "]\r\n" +
                "[Black: " + "" + "]\r\n" +
                "[Result: " + "" + "]\r\n")
    
def onsearch(e, gameStatus):
    with open("_info.txt", 'a') as f:
        f.write(e + '\r\n')
    if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e)
        if int(info.group('depth')) > 5: # depth 5
            gameStatus["centipawns"] = int(info.group('cp'))
            uci.send("stop")
    if re.search('depth (?P<depth>\d+) seldepth \d+ score mate (?P<mate>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score mate (?P<mate>-?\w+)', e)
        if int(info.group('depth')) > 5: # depth 5
            gameStatus["centipawns"] = int(info.group('mate'))
            uci.send("quit")

def onmove(e):
    gameStatus = e.args[1]

    if gameStatus["white"]:
        gameStatus["whiteCP"].append(gameStatus["centipawns"])
        with open("_moves.txt", 'a') as f:
            f.write(str(gameStatus["currentMove"]) + ". " + e.args[0])
        gameStatus["currentMove"]+=1
    else:
        gameStatus["blackCP"].append(gameStatus["centipawns"])
        with open("_moves.txt", 'a') as f:
            f.write(" " + e.args[0] + " ")
    gameStatus["white"] = not gameStatus["white"]
   
    gameStatus["gameString"] += " " + (e.args[0])
    uci.send("position startpos moves" + gameStatus["gameString"])
    uci.send("go infinte")

def onmate(e):
    print game.current

game = Fysom({'initial': 'init',
             'events': [{'name': 'uci','src':'init','dst':'ready'},
                        {'name': 'isready','src':'ready','dst':'newgame'},
                        {'name': 'ucinewgame','src':'newgame','dst':'goinfinite'},
                        {'name': 'infinite','src':'goinfinite','dst':'goinfinite'},
                        {'name': 'move','src':'goinfinite','dst':'bestmove'},
                        {'name': 'infinite','src':'bestmove','dst':'goinfinite'},
                        {'name': 'mate','src':'bestmove','dst':'end'}],
              'callbacks': {
                  'onuci': onuci,
                  'onisready': onisready,
                  'onucinewgame': onucinewgame,
                  'onmove': onmove,
                  'onmate': onmate } })

print game.current

while True:
    res = q.get()
    print('     '+res)
    if re.search('^Stockfish', res):
        print('got sf')
        game.uci()
    if re.search('^uciok', res):
        game.isready()
    if re.search('^readyok', res):
        game.ucinewgame()
    if re.search('^info', res):
        game.infinite()
        onsearch(res, gameStatus)
    if re.search('^bestmove (?P<move>\w+) ', res):
        bestmove = re.search('^bestmove (?P<move>\w+) ', res)
        game.move(bestmove.group('move'), gameStatus)

##while True:
##    res = q.get()
##    print('     '+res)
##    if len(gameString) > 10*2: # 2 moves
##        print('\nMoves: ' + gameString)
##        print('White: ' + scoreString(whiteCP))
##        print('Black: ' + scoreString(blackCP))
##        os.kill(uci.engine.pid, signal.SIGTERM)
##        uci.engine.kill()
##        break
##    if re.search('^Stockfish', res):
##        uci.send("uci")
##    if re.search('^uciok', res):
##        uci.send("isready")
##    if re.search('^readyok', res):
##        uci.send("ucinewgame")
##        uci.send("position startpos")
##        uci.send("go infinite")
##        open('_info.txt', 'w').close()
##        with open("_moves.txt", 'w') as f:
##            f.write("[Event: " + "" + "]\n" +
##                    "[Site: " + "" + "]\n" +
##                    "[Date: " + "" + "]\n" +
##                    "[Round: " + "" + "]\n" +
##                    "[White: " + "" + "]\n" +
##                    "[Black: " + "" + "]\n" +
##                    "[Result: " + "" + "]\n")
##        
##    if re.search('^info', res):
##        with open("_info.txt", 'a') as f:
##            f.write(res + '\n')
##        if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', res):
##            info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', res)
##            if int(info.group('depth')) > 5: # depth 5
##                centipawns = int(info.group('cp'))
##                uci.send("stop")
##    if re.search('^bestmove (?P<move>\w+) ', res):
##        bestmove = re.search('^bestmove (?P<move>\w+) ', res)
##        move = bestmove.group('move')
##        if white:
##            whiteCP.append(centipawns)
##            with open("_moves.txt", 'a') as f:
##                f.write(str(currentMove) + ". " + move[2:])
##            currentMove+=1
##        else:
##            blackCP.append(centipawns)
##            with open("_moves.txt", 'a') as f:
##                f.write(" " + move[2:] + " ")
##        white = not white
##       
##        gameString += " " + (move)
##        uci.send("position startpos moves" + gameString)
##        uci.send("go infinte")
