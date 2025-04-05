from dotenv import load_dotenv,dotenv_values,set_key
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_chroma import Chroma
from uuid import uuid4
from langchain_core.documents import Document
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import os
import pickle
import base64
import email
from datetime import datetime
import time
import re
from transformers import pipeline


    
TOKEN_PATH = "token.pickle"
CRED_PATH = "Api/client_secret_471719377791-ajhn80o8ijbtm6d9n778sadr2mq1415i.apps.googleusercontent.com.json"

class ChromaManage():
    def __init__(self, credential_path=CRED_PATH,token_path=TOKEN_PATH):
        load_dotenv()
        self.credential_path = credential_path
        self.token_path = token_path
        self.embeddings  = GoogleGenerativeAIEmbeddings(model="models/text-embedding-004")
        self.vector_store =  Chroma(
        collection_name="gmail",
        embedding_function=self.embeddings,
        persist_directory="chroma_langchain_db",  
        )
        self.pipe = pipeline("token-classification", model="iiiorg/piiranha-v1-detect-personal-information")
        self.labels = ['I-ACCOUNTNUM', 'I-CREDITCARDNUMBER', 'I-DRIVERLICENSENUM','I-IDCARDNUM','I-PASSWORD','I-TAXNUM']

        
        self.service = self.authenticate_gmail()

    def authenticate_gmail(self):
        SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']
        creds = None
        if os.path.exists('token.pickle'):
            with open('token.pickle', 'rb') as token:
                creds = pickle.load(token)
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
                creds = flow.run_local_server(port=0)
            with open('token.pickle', 'wb') as token:
                pickle.dump(creds, token)
        service = build('gmail', 'v1', credentials=creds)
        return service

    def add_to_database(self,max_results=5):
        results = self.service.users().messages().list(userId='me',maxResults=max_results).execute()
        messages = results.get('messages', [])
        documents = []
        latest_time = os.getenv("LAST_MAIL_TIME")
        for idx,msg in enumerate(messages):
            metadata,email = self.get_full_email(self.service, msg['id'])
            msg_id = msg['id']
            if(float(metadata['timestamp']) > float(os.getenv("LAST_MAIL_TIME"))):
                msg_data = self.service.users().messages().get(userId="me", id=msg_id, format="full").execute()
                thread_id = msg_data["threadId"]
                metadata['thread_id']  = thread_id
                if idx == 0 :
                    latest_time = str(metadata['timestamp']) 
                doc = Document(page_content = email,id = uuid4(),metadata=metadata,)
                documents.append(doc)
            else:
                 break
        if len(documents)>0:

            uuids = [str(uuid4()) for _ in range(len(documents))]
            ChromaManage.change_latest_time(latest_time)
            self.vector_store.add_documents(documents=documents, ids=uuids)
            print("database synced with new mails")
            print(f"mails synced:{idx}")
        else:
            print("chroma_db is uptodate")

    def get_full_email(self,service, email_id):
        message = service.users().messages().get(userId='me', id=email_id, format='full').execute()
        headers = message['payload']['headers']
        subject = next((h['value'] for h in headers if h['name'] == 'Subject'), 'No Subject')
        sender = next((h['value'] for h in headers if h['name'] == 'From'), 'Unknown Sender')
        date = next((h['value'] for h in headers if h['name'] == 'Date'), 'No data')
        To = next((h['value'] for h in headers if h['name'] == 'To'), 'Unknown Sender')
        time = ChromaManage.time_strp(date)
        sender_name,sender_email = ChromaManage.extract_name_email(sender)
        reciever_name,reciever_email = ChromaManage.extract_name_email(To)

        meta_data = {
                "sender": str(sender_name) if sender_name else "Unknown",
                "reciever": str(reciever_name) if reciever_name else "Unknown",    
                "sender_email": str(sender_email) if sender_email else "Unknown",
                "reciever_email": str(reciever_email) if reciever_email else "Unknown",
                "timestamp": str(time) if time else "0"
        }
        
        email_body = ""
        if 'parts' in message['payload']:
            for part in message['payload']['parts']:
                if part['mimeType'] == 'text/plain':
                    email_body = base64.urlsafe_b64decode(part['body']['data']).decode('utf-8')
        full_mail = f"From: {sender}\n"+ f"Subject: {subject}\n" + f"Body: {email_body}\n"
        full_mail = self.masksensitive(full_mail)
        return meta_data,full_mail

    def masksensitive(self,email):
        results = self.pipe(email)
        sensitive_results = [r for r in results if r['entity'] in self.labels and (r['end'] - r['start']) > 1]
        sensitive_results = sorted(sensitive_results, key=lambda x: x['start'], reverse=True)
        for i in sensitive_results:
            start = i['start']
            end = i['end']
            email = email[:start] + "*" * (end - start) + email[end:]
        return email

    @staticmethod
    def time_strp(Date):
        time_str = Date
        try:
            dt_obj =  datetime.strptime(time_str, "%a, %d %b %Y %H:%M:%S %Z")
        except:
            dt_obj = datetime.strptime(time_str, "%a, %d %b %Y %H:%M:%S %z")
        timestamp = dt_obj.timestamp()
        return timestamp

    @staticmethod
    def extract_name_email(string):
        match = re.match(r"(.+?)\s*<(.+?)>", string)
        if match:
            name, email = match.groups()
            return name.strip(), email.strip()
        return None, None
    

    @staticmethod
    def change_latest_time(time):
        env_path = ".env"
        env_vars = dotenv_values(env_path)
        env_vars["LAST_MAIL_TIME"] = time
        for key, value in env_vars.items():
            set_key(env_path, key, value)




if __name__ == "__main__":

    chroma_manage = ChromaManage(token_path=TOKEN_PATH,credential_path=CRED_PATH)
    chroma_manage.add_to_database(max_results=30)

