import subprocess, time, threading, Queue, re, sys, os, signal
from fysom import Fysom

path = 'C:/Users/Shannon/Documents/School/UROP/Playful Systems/Chesscomputer/'
enginePath = path + sys.argv[1]

gameStatus = {"gameString" : "",
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
    
    def get(self):
        return self.q.get()

manager = StockfishManager()



def scoreString(scores):
    string = ""
    for i in range(0, len(scores)):
        string += ' ' + str(scores[i])
    return string

def onuciok(e):
    manager.send("uci")

def onreadyok(e):
    manager.send("isready")
    
def onucinewgame(e):
    manager.send("ucinewgame")
    manager.send("position startpos")
    manager.send("go infinite")
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
            manager.send("stop")
    if re.search('depth (?P<depth>\d+) seldepth \d+ score mate (?P<mate>-?\w+)', e):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score mate (?P<mate>-?\w+)', e)
        if int(info.group('depth')) > 5: # depth 5
            gameStatus["centipawns"] = int(info.group('mate'))
            manager.send("quit")

def onbestmove(e):
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
    manager.send("position startpos moves" + gameStatus["gameString"])
    manager.send("go infinte")

def onend(e):
    print game.current

game = Fysom({'initial': 'init',
             'events': [{'name': 'uci','src':'init','dst':'uciok'},
                        {'name': 'isready','src':'uciok','dst':'readyok'},
                        {'name': 'ucinewgame','src':'readyok','dst':'goinfinite'},
                        {'name': 'infinite','src':'goinfinite','dst':'goinfinite'},
                        {'name': 'move','src':'goinfinite','dst':'bestmove'},
                        {'name': 'infinite','src':'bestmove','dst':'goinfinite'},
                        {'name': 'mate','src':'bestmove','dst':'end'}],
              'callbacks': {
                  'onuciok': onuciok,
                  'onreadyok': onreadyok,
                  'onucinewgame': onucinewgame,
                  'onbestmove': onbestmove,
                  'onend': onend } })

print game.current

while True:
    res = manager.get()
    print('     '+res)
    if re.search('^Stockfish', res):
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
