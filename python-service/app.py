from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "Python OK"})

@app.route('/chain')
def chain():
    go_response = requests.get(f"{os.getenv('GO_SERVICE_URL')}/health")
    return jsonify({
        "service": "python",
        "status": "OK",
        "go_response": go_response.json()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    
    # return jsonify({
    #     "service": "python",
    #     "status": "OK",
    #     "message": "This is a test response before connecting to Go"
    # })
    # try:
    #     url = f"http://{GO_SERVICE_HOST}:{GO_SERVICE_PORT}/health"
    #     resp = requests.get(url, timeout=2)
    #     return f"Python → Go: {resp.text.strip()}", resp.status_code
    # except Exception as e:
    #     return f"Error calling Go service: {e}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
    # app.run(host="0.0.0.0", port=8080)