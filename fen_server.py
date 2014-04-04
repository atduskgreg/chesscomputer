from flask import Flask, request
app = Flask(__name__)

@app.route("/boomerang")
def boomerang():
  fen_string = request.args.get('f')
  return fen_string

if __name__ == "__main__":
    app.run(debug=True)
