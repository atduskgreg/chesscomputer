from flask import Flask, request
from boomerang_server import Boomerang
app = Flask(__name__)

@app.route("/boomerang")
def boomerang():
	if (request.args.get('f')):
		fen_string = request.args.get('f')
		print fen_string
		b = Boomerang("Game")
		out = b.findBoomerang(fen_string)
	else:
		out = "No fen string found."
	return out

if __name__ == "__main__":
	app.run(debug=True)
