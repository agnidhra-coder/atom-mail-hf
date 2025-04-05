from langchain_google_genai import GoogleGenerativeAI
from langchain_chroma import Chroma
from langchain_google_genai import GoogleGenerativeAIEmbeddings
import google.generativeai as genai
from dotenv import load_dotenv,dotenv_values,set_key
import requests
import re
import psycopg2
import time

conn = psycopg2.connect(
    dbname="postgres",
    user="postgres",
    password="root",
    host="192.168.125.42",
    port="5432"
)


cur = conn.cursor()

env_path = ".\.env"
env_vars = dotenv_values(env_path)  
load_dotenv()
# Set your API key
api_key = env_vars["GOOGLE_API_KEY"]
# Initialize the model
llm=GoogleGenerativeAI(model="gemini-2.0-flash", google_api_key=api_key)
import random
fina_tags=[]

def callApi():
    baseUrl = "https://weak-planes-brake.loca.lt/email/download"
    res = requests.get(url=baseUrl)
    # print(res.text)
    try:
        if(res != None):
            return res.json()
    except Exception as e:
        print("Something went wrong:", e)


def sendTagsToDb(tag_from_model):
    result = callApi()
    for i in range(len(result)):

        query = """
            UPDATE metadata SET tags = %s
            WHERE thread_id = %s
        """
        cur.execute(query, (tag_from_model[i], result[i]['metadata']['thread_id']))
        conn.commit()

def generate_few_shot_examples(user_emails):
    
    user_tags = env_vars["USER_TAGS"]
    #print("user tags are: ",user_tags)
    if user_tags:  
        return user_tags  
    
    few_shot_examples = []
    sampled_emails = random.sample(user_emails, min(10, len(user_emails)))
    for email in sampled_emails: 
        tags = llm.invoke(f"Generate 3-4 generalized tags for this email: {email}").strip()
        few_shot_examples.append(f"Email: \"{email}\"\nTags: {tags}\n")
    
    final_tags = llm.invoke(f"Generate 10-15 generalized tags from this collection of tags: {few_shot_examples}").strip()
    
    
    set_key(env_path, "USER_TAGS", final_tags)  
    
    return final_tags

def extract_tags(emails, user_emails):
    few_shot_examples = generate_few_shot_examples(user_emails)
    #print("generated tags for the user: ",few_shot_examples)
    prompt = f"""
    This is user context on the type of emails they receive:
    {few_shot_examples}

    Below are 12 or less than 12 emails the user has received. For each email, extract exactly 3 relevant tags.

    {emails}

    Format your response as follows:
    Email 1: [tag1, tag2, tag3]
    Email 2: [tag1, tag2, tag3]
    Email 3: [tag1, tag2, tag3]
    Email 4: [tag1, tag2, tag3]
    Email 5: [tag1, tag2, tag3]
    
    depending on number of emails given
    """

    response = llm.invoke(prompt).strip()
    matches = re.findall(r'\[(.*?)\]', response)

    # Convert each comma-separated string to a list, stripping extra whitespace
    tag_lists = [ [tag.strip() for tag in match.split(',')] for match in matches ]
    return tag_lists
if __name__ == "__main__":
    a=time.time()
    res = callApi()
    # print(res)
    content=[]
    final_tags=[]
    p=env_vars["USER_TAGS"]
    i=0
    # print("len is: ",len(res))
    for j in range(len(res)):
        doc=res[i]['content']
        # print("doc is like ",doc)
        content.append(doc)
        # print(doc)
        i+=1
        if(i==6 or j==len(res)-1):
            tags = extract_tags(content, p)
            i=0
            final_tags.extend(tags)
            
            content=[]
    # print(final_tags)
    sendTagsToDb(final_tags)
    
    # embeddings = GoogleGenerativeAIEmbeddings(
    #             model="models/text-embedding-004"
    #         )
    # vector_store = Chroma(
    #             collection_name="gmail",
    #             embedding_function=embeddings,
    #             persist_directory="./chroma_langchain_db",
    #         )
    # p=vector_store.get()['documents']
    # #print(p)
    # # user_email_dataset = ["Meeting scheduled for 3 PM today.", "Your flight is confirmed for next Monday.", "Big sale on electronics!"]  
    # new_email = ["hey dillan. you ready for out trip tommorow?",
    #              "you have a meeting tommorow",
    #              "hey! how are you, its been a long time"
                 
    #              ]
    # tags = extract_tags(new_email, p)
    # print(type(tags))
    # print("Extracted Tags:",tags)
