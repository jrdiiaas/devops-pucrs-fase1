import logging
from flask import Flask, jsonify

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("devops-pucrs-api")

app = Flask(__name__)

METRICS = {
    "requests_total": 0,
    "health_checks_total": 0,
    "calculations_total": 0
}


@app.route("/health", methods=["GET"])
def health_check():
    METRICS["requests_total"] += 1
    METRICS["health_checks_total"] += 1
    logger.info("Health check solicitado - status UP")
    return jsonify({
        "status": "UP",
        "service": "devops-pucrs-api",
        "version": "1.1.0"
    }), 200


@app.route("/calcular/<int:a>/<int:b>", methods=["GET"])
def somar(a, b):
    METRICS["requests_total"] += 1
    METRICS["calculations_total"] += 1
    resultado = a + b
    logger.info("Calculo executado: %d + %d = %d", a, b, resultado)
    return jsonify({
        "operacao": "soma",
        "resultado": resultado
    }), 200


@app.route("/metrics", methods=["GET"])
def metrics():
    METRICS["requests_total"] += 1
    logger.info("Coleta de metricas de observabilidade solicitada")
    return jsonify({
        "service": "devops-pucrs-api",
        "version": "1.1.0",
        "metrics": METRICS
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosec B104
