import os
from flask import Flask, request, jsonify
# from classification import classifier  # Currently broken in original codebase
from summarizer import summarize
from jev_classifier import triage_email_with_jev
# from smartsugg import Response # missing file

app = Flask(__name__)

summary = summarize()
# aireply = Response()
# classification = classifier()

@app.route('/api/process-email', methods=['POST'])
def process_email():
    payload_data = request.get_json() or {}
    email_text = payload_data.get("body", "")
    if not email_text:
        return jsonify({"status": "error", "message": "Missing email text"}), 400
    classification = triage_email_with_jev(email_text)
    return jsonify({"status": "success", "data": classification}), 200

@app.route('/classifier')
def classify():
    # classification.update_db()
    return "classifier endpoint disabled"

@app.route('/summarize',methods=['GET'])
def summ():
    thread_id = request.args.get('thread_id')
    print(thread_id)
    return str(summary.generate(person_email="unknown", email=thread_id))

@app.route('/reply',methods=['POST'])
def replies():
    return "reply disabled"

if __name__ =="__main__":
    app.run(host='0.0.0.0', port=3001, debug=True)
    
