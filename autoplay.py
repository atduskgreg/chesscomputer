import subprocess, time, threading, Queue, re, sys

enginePath = sys.argv[1]

class Uci:
    engine = subprocess.Popen(
        enginePath,
        universal_newlines=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )

    def send(self, command):
        print(command)
        self.engine.stdin.write(command+'\n')

    def nextMove():
        return 0


uci = Uci()
gameString = ""
centipawns = 0
whiteCP = []
blackCP = []

white = True

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

while True:
    res = q.get()
    print('     '+res)
    if len(gameString) > 5*20: # 20 moves
        print('\nMoves: ' + gameString)
        print('White: ' + scoreString(whiteCP))
        print('Black: ' + scoreString(blackCP))
        break
    if re.search('^Stockfish', res):
        uci.send("uci")
    if re.search('^uciok', res):
        uci.send("isready")
    if re.search('^readyok', res):
        uci.send("ucinewgame")
        uci.send("position startpos")
        uci.send("go infinite")
    if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', res):
        info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', res)
        if int(info.group('depth')) > 5: # depth 5
            centipawns = int(info.group('cp'))
            uci.send("stop")
    if re.search('^bestmove (?P<move>\w+) ', res):
        if white:
            whiteCP.append(centipawns)
        else:
            blackCP.append(centipawns)
        white = not white
        bestmove = re.search('^bestmove (?P<move>\w+) ', res)
        gameString += " " + (bestmove.group('move'))
        uci.send("position startpos moves" + gameString)
        uci.send("go infinte")
