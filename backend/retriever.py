from langchain_chroma import Chroma
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from dotenv import load_dotenv

load_dotenv()

class ChromaRetrieve:
    def __init__(self):
        self.embeddings = GoogleGenerativeAIEmbeddings(model="models/text-embedding-004")
        self.vector_store = Chroma(
            collection_name="gmail",
            embedding_function=self.embeddings,
            persist_directory="chroma_langchain_db",
        )
    
    def get_latest_email_by_thread_id(self, thread_id):
        results = self.vector_store.get(where={"thread_id": thread_id})
        emails = results.get("documents", [])
        metadatas = results.get("metadatas", [])
        if not emails:
            print(f"No emails found for thread ID: {thread_id}")
            return None
        emails_with_time = [
            {"email": email, "timestamp": metadata.get("timestamp", 0)}
            for email, metadata in zip(emails, metadatas)
        ]
        emails_with_time.sort(key=lambda x: x["timestamp"], reverse=True)
        latest_email = emails_with_time[0]["email"]
        return latest_email
    
    def get_latest_email_by_mailid(self, sender_email):
        results = self.vector_store.get(where={"sender_email": sender_email})
        emails = results.get("documents", [])
        metadatas = results.get("metadatas", [])
        if not emails:
            print(f"No emails found for email: {sender_email}")
            return None
        emails_with_mailid = [
            {"email": email, "timestamp": metadata.get("timestamp", 0)}
            for email, metadata in zip(emails, metadatas)
        ]
        emails_with_mailid.sort(key=lambda x: x["timestamp"], reverse=True)
        latest_email = emails_with_mailid[0]["email"]
        return latest_email

    def get_latest_thread_id_by_mailid(self, sender_email):
        results = self.vector_store.get(where={"sender_email": sender_email})
        emails = results.get("documents", [])
        metadatas = results.get("metadatas", [])
        if not emails:
            print(f"No emails found for email: {sender_email}")
            return None
        emails_with_metadata = [
            {
                "email": email,
                "timestamp": metadata.get("timestamp", 0),
                "thread_id": metadata.get("thread_id")
            }
            for email, metadata in zip(emails, metadatas)
        ]
        emails_with_metadata.sort(key=lambda x: x["timestamp"], reverse=True)
        latest_thread_id = emails_with_metadata[0]["thread_id"]
        return latest_thread_id

    def full_thread(self,emailid):
        thread_id = self.get_latest_thread_id_by_mailid(emailid)
        if thread_id is not None:
            return self.get_latest_email_by_thread_id(thread_id)
        else:
            return "no mail found"




if __name__ == "__main__":
    
    retriever = ChromaRetrieve()
    print(retriever.full_thread("vaibhav940845@gmail.com"))
    
