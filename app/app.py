from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return 'Hello World From K8s test'

app.run(host='0.0.0.0', port=80)