import subprocess, time, threading, Queue, re, sys, os, signal, json
from fysom import Fysom
import sys
#180 game fen: r2q2k1/2p1brpp/p1n2n2/1P2p3/4p1b1/1BP5/1P1PQPPP/RNB1K2R w K - 1 2
  
class Uci:
	enginePath = "stockfish"
 	if sys.platform == "win32":
 		enginePath += ".exe"
		
  	path = 'C:/Users/Shannon/Documents/School/UROP/Playful Systems/Chesscomputer/webapp/'
 	enginePath = path+"stockfish.exe"
	
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
		
	def clear(self):
		self._q.queue.clear()

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
		
class Boomerang:
	def __init__(self, gameName):
		self.gameStatus = {"gameName" : gameName,
					  "startpos" : 'startpos',
					  "moves" : [],
					  "moveDepths" : {},
					  "fen" : True,
					  "centipawns" : 0,
					  "initialCentipawns": {},
					  "currentMove" : 1,
					  "startPlayer" : 'w',
					  "player" : 'w',
					  "JSONlines" : [],
					  "JSONcurrentLine": {},
					  "JSONmoves": [],
					  "JSONcurrentMove":{},
					  }

		self.movesList = []
		self.movesListCP = {}
		self.cp = 0
		self.totalMoves = 5
		self.searchingDepth = 15          # total depth for 'searching' state
		self.exploreDepth = "depth 15"   # depth for 'exploring state. "infinite" or "depth #"
		
		self.initialize = Fysom({'initial': 'start'})
		self.search = Fysom({'initial': 'start'})
		self.explore = Fysom({'initial': 'start'})
		self.boomerang = Fysom({'initial': 'start'})
	
		self.manager = StockfishManager()

		"""
		INITIALIZE
		State machine for starting Stockfish
		"""
		def onstockfish(e):
			gameStatus = e.args[0]
			self.manager.uci()

		def onuciok(e):
			self.manager.isready()

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
			
			self.manager.ucinewgame()
			self.manager.position(startpos, fen, moves)
			self.manager.go("depth 1")

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
			gameStatus = e.args[6]
			moveDepths = gameStatus["moveDepths"]
			#cp = e.args[5]

			moveDepths[bestMove] = (currentDepth-1)
			movesListCP[bestMove] = cp
			if bestMove not in movesList:
				movesList.append(bestMove)
				
			

			if currentDepth <= searchingDepth:
				self.manager.go("depth " + str(currentDepth))
		
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
			moveCP = str(self.movesListCP[currentMove])

			startpos = e.args[1]

			self.manager.ucinewgame()
			self.manager.position(startpos, fen, moves)
			self.manager.go(e.args[0])
			
			del gameStatus["JSONmoves"][:]
			JSONmove = {}
			JSONmove["move"] = currentMove
			JSONmove["cp"] = moveCP
			JSONmove["player"] = player
			gameStatus["JSONmoves"].append(JSONmove)
			
		def onsearch(e, gameStatus):
			if re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e):
				info = re.search('depth (?P<depth>\d+) seldepth \d+ score cp (?P<cp>-?\w+)', e)
				gameStatus["centipawns"] = int(info.group('cp'))
				
				move = re.search(' pv (?P<move>\w+)', e)
				if move.group('move') not in gameStatus["initialCentipawns"].keys():
					gameStatus["initialCentipawns"][move.group('move')] = info.group('cp')

		def onbestmove(e):
			gameStatus = e.args[1]
			totalMoves = e.args[3]
			name = gameStatus["gameName"]
			currentMove = e.args[4]
			startpos = gameStatus["startpos"]
			fen = gameStatus["fen"]
			moves = gameStatus["moves"]
			bestMove = e.args[0]
			
			cp = gameStatus["initialCentipawns"][bestMove]

			if gameStatus["player"] == gameStatus["startPlayer"]:
				gameStatus["currentMove"]+=1
						
			if gameStatus["player"] == 'w':
				gameStatus["player"] = 'b'
				cp *= -1
			else:
				gameStatus["player"] = 'w'
				
				
			JSONmove = {}
			JSONmove["move"] = bestMove
			JSONmove["cp"] = str(cp)
			JSONmove["player"] = gameStatus["player"]
			gameStatus["JSONmoves"].append(JSONmove)
			
			gameStatus["moves"].append(e.args[0])

			if (gameStatus["currentMove"]<totalMoves):
				self.manager.position(startpos, fen, moves)
				self.manager.go(e.args[2])

		def ongodeeper(e):
			movesList = e.args[0]
			movesListCP = e.args[1]
			totaDepth = e.args[2]
			gameStatus = e.args[3]
			cp = e.args[4]
			
			currentDepth = 1
			self.search.newgame(gameStatus)
			while currentDepth <= self.searchingDepth:
				currentDepth += 1
				while True:
					res = self.manager.get()
					if re.search('^info', res):
						self.search.searching()
						ongodepth(res, cp)
					if re.search('^bestmove (?P<move>\w+) ', res):
						bestmove = re.search('^bestmove (?P<move>\w+) ', res)
						self.search.makemove(bestmove.group('move'), movesList, movesListCP, currentDepth, self.searchingDepth, cp, gameStatus)
						break
				
		def onexplore(e):
			gameStatus = e.args[4]
			
			movesList = e.args[0]
			movesListCP = e.args[1]
			totalMoves = e.args[2]
			exploreDepth = e.args[3]

			startpos = gameStatus["startpos"]

			for key in gameStatus["moveDepths"].keys():
				move = key
				gameStatus["moves"] = [move]
				gameStatus["currentMove"] = 1
				gameStatus["player"] = gameStatus["startPlayer"]

				self.explore.ucinewgame(exploreDepth, startpos, move, gameStatus)
				while True:
					res = self.manager.get()
					if re.search('^info', res):
						self.explore.infinite()
						onsearch(res, gameStatus)
					if re.search('^bestmove (?P<move>\w+) ', res):
						bestmove = re.search('^bestmove (?P<move>\w+) ', res)
						self.explore.move(bestmove.group('move'), gameStatus, exploreDepth, totalMoves, move)

					if (gameStatus["currentMove"]>=totalMoves):
						break
						
				currentLine = {}
				currentLine["searchingDepth"] = gameStatus["moveDepths"][move]
				currentLine["moves"] = gameStatus["JSONmoves"][:]
				gameStatus["JSONlines"].append(currentLine)
				
			self.boomerang.noMoves()
			
		def onwait(e):
			self.initialize.reset()
			self.search.reset()
			self.explore.reset()
			

		self.initialize = Fysom({'initial': 'init',
				 'events': [{'name': 'uci','src':'init','dst':'stockfish'},
							{'name': 'isready','src':'stockfish','dst':'uciok'},
							{'name': 'reset','src':'uciok','dst':'init'}],
				  'callbacks': {
					  'onstockfish': onstockfish,
					  'onuciok': onuciok } })
		self.search = Fysom({'initial': 'init',
					 'events': [{'name': 'newgame','src':'init','dst':'godepth'},
								{'name': 'searching','src':'godepth','dst':'godepth'},
								{'name': 'makemove','src':'godepth','dst':'move'},
								{'name': 'searching','src':'move','dst':'godepth'},
								{'name': 'newgame','src':'move','dst':'godepth'},
								{'name': 'reset','src':'move','dst':'init'}],
					  'callbacks': {
						  'onnewgame': onnewgame,
						  'onmove': onmove} })

		self.explore = Fysom({'initial': 'init',
					 'events': [{'name': 'ucinewgame','src':'init','dst':'goinfinite'},
								{'name': 'infinite','src':'goinfinite','dst':'goinfinite'},
								{'name': 'move','src':'goinfinite','dst':'bestmove'},
								{'name': 'infinite','src':'bestmove','dst':'goinfinite'},
								{'name': 'ucinewgame','src':'bestmove','dst':'goinfinite'},
								{'name': 'mate','src':'bestmove','dst':'end'},
								{'name': 'reset','src':'bestmove','dst':'init'}],
					  'callbacks': {
						  'onucinewgame': onucinewgame,
						  'onbestmove': onbestmove } })
		self.boomerang = Fysom({'initial': 'start',
					 'events': [{'name': 'startsearch','src':'start','dst':'godeeper'},
								{'name': 'restart','src':'wait','dst':'start'},
								{'name': 'exploremove','src':'godeeper','dst':'explore'},
								{'name': 'exploremove','src':'explore','dst':'explore'},
								{'name': 'noMoves','src':'explore','dst':'analyze'},
								{'name': 'pause', 'src':'analyze','dst':'wait'}],
					  'callbacks': {
						  'ongodeeper': ongodeeper,
						  'onexplore': onexplore,
						  'onwait': onwait
						  } })
	
	def resetGame(self):
		self.gameStatus["startpos"] = 'startpos'
		self.gameStatus["moves"] = []
		self.gameStatus["moveDepths"] = {}
		self.gameStatus["fen"] = True,
		self.gameStatus["centipawns"] = 0
		self.gameStatus["currentMove"] = 1
		self.gameStatus["startPlayer"] = 'w'
		self.gameStatus["player"] = 'w'
		self.gameStatus["JSONlines"] = []
		self.gameStatus["JSONcurrentLine"] = {}
		self.gameStatus["JSONmoves"] = []
		self.gameStatus["JSONcurrentMove"] = {}
	
	def findBoomerang(self, startpos):
		self.resetGame()
		self.gameStatus["startpos"] = startpos
		while True:   
			if self.boomerang.isstate("start"):
				res = self.manager.get()
				if re.search('^Stockfish', res):
					self.initialize.uci(self.gameStatus)
				if re.search('^uciok', res):
					self.initialize.isready()
				if re.search('^readyok', res):
					self.boomerang.startsearch(self.movesList, self.movesListCP, self.searchingDepth, self.gameStatus, self.cp)
			elif self.boomerang.isstate("wait"):
				self.initialize.uci(self.gameStatus)
				self.manager.clear()
				self.boomerang.restart()
			elif self.boomerang.isstate("godeeper"):
				self.boomerang.exploremove(self.movesList, self.movesListCP, self.totalMoves, self.exploreDepth, self.gameStatus)
			elif self.boomerang.isstate("analyze"):
				break
				
		self.boomerang.pause()
		return json.dumps(self.gameStatus["JSONlines"])
