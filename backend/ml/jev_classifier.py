import os
import requests
from concurrent.futures import ThreadPoolExecutor

ZEN_API_KEY = os.environ.get("OPENCODE_API_KEY")
JEV_ENDPOINT = "https://opencode.ai/zen/v1/systemone"

def triage_email_with_jev(email_body):
    if not ZEN_API_KEY:
        print("[CRITICAL] Configuration Error: OPENCODE_API_KEY is not defined.")
        return {"category": "Updates", "is_urgent": False}

    headers = {
        "Authorization": f"Bearer {ZEN_API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": "jev-1.13-free",
        "state": email_body,
        "questions": {
            "category": {
                "type": "choice",
                "instructions": "Determine the clean workspace bucket categorization for this email structure.",
                "options": ["Work", "Personal", "Finance", "Updates", "Spam"]
            },
            "urgency": {
                "type": "noul",
                "instructions": "Does this text context demand an active, immediate response inside 2 hours?"
            }
        }
    }

    try:
        response = requests.post(JEV_ENDPOINT, json=payload, headers=headers, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            answers = data.get("answers", {})
            
            choice_index = answers.get("category", {}).get("value", 3)
            options = payload["questions"]["category"]["options"]
            category = options[choice_index] if 0 <= choice_index < len(options) else "Updates"
            
            is_urgent = answers.get("urgency", {}).get("noul", 0.0) >= 0.75
            
            return {"category": category, "is_urgent": is_urgent}
            
        print(f"[API WARN] Failed ({response.status_code}): {response.text}")
    except Exception as error:
        print(f"[API ERROR] Connection pipeline failed: {error}")

    return {"category": "Updates", "is_urgent": False}

def triage_batch(emails):
    with ThreadPoolExecutor(max_workers=5) as executor:
        return list(executor.map(triage_email_with_jev, emails))
