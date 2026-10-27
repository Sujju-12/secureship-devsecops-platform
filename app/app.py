from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def index():
    return jsonify(name="SecureShip Demo API", purpose="DevSecOps security lab", status="ok")

@app.get("/healthz")
def healthz():
    return jsonify(status="healthy"), 200

@app.get("/readyz")
def readyz():
    return jsonify(status="ready"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
