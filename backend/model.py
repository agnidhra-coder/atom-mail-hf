from langchain_ollama import OllamaLLM
from langchain_google_genai import GoogleGenerativeAI
from langchain_openai import ChatOpenAI


model = OllamaLLM(model="gemma:7b")


print(model.invoke("hello"))
# model = ChatOpenAI(
#     model="gpt-4o",
#     temperature=0,
#     max_tokens=None,
#     timeout=None,
#     max_retries=2
# )

# model = GoogleGenerativeAI(model = "gemini-1.5-flash")