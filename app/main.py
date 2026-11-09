from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({
        "status": "UP",
        "service": "devops-pucrs-api",
        "version": "1.0.0"
    }), 200


@app.route("/calcular/<int:a>/<int:b>", methods=["GET"])
def somar(a, b):
    return jsonify({
        "operacao": "soma",
        "resultado": a + b
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
