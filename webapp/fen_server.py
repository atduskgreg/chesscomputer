from flask import Flask, request
from boomerang_server import Boomerang
app = Flask(__name__)
b = Boomerang("Game")

@app.route("/boomerang")
def boomerang():
	if (request.args.get('f')):
		fen_string = request.args.get('f')
		print fen_string
		out = b.findBoomerang(fen_string)
	else:
		out = "No fen string found."
	return out

@app.route('/')
def root():
	return app.send_static_file('index.html')

@app.route('/archive')
def archive():
	return app.send_static_file('archive.html')

	
if __name__ == "__main__":
	app.run(debug=True)
