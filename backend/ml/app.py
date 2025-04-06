from flask import Flask,request
import requests
from classification import classifier
from summarizer import summarize
from smartsugg import Response
app = Flask(__name__)

summary = summarize()
aireply = Response()
classification = classifier()
@app.route('/classifier')
def classify():
    classification.update_db()
    return "updated"
@app.route('/summarize',methods=['GET'])
def summ():
    thread_id = request.args.get('thread_id')
    print(thread_id)
    return str(summary.generate(thread_id=thread_id))

@app.route('/reply',methods=['GET'])
def replies():
    thread_id = request.args.get('thread_id')
    prompt = request.args.get('prompt')
    
    return str(aireply.generate(prompt,thread_id))

if __name__ =="__main__":
    app.run(host='0.0.0.0', port=3000, debug=True)
    