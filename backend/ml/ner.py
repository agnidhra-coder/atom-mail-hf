from transformers import pipeline
import time

pipe = pipeline("token-classification", model="iiiorg/piiranha-v1-detect-personal-information")

labels = ['I-ACCOUNTNUM', 'I-CREDITCARDNUMBER', 'I-DRIVERLICENSENUM', 'I-IDCARDNUM', 'I-PASSWORD', 'I-TAXNUM']

email = """Subject: Required: Verification of Personal Details

From: alex.jordan@dummyemail.com  
To: support@secureverify.com

Dear Support Team,

As per your request, I'm sharing the necessary details for identity verification:

- Account : 5567 8910 2345  
- Credit Card Number: 41111111 1111 1111  
- Driver's License Number: D12345678  
- ID Card Number: ID9988776655  
- Tax Identification Number: TX-4455-7788  
- Password: My$ecureP@ss2025

Please ensure this information is treated with strict confidentiality. Let me know once the verification is complete.

Sincerely,  
Alex Jordan
"""



results = pipe(email)
sensitive_results = [r for r in results if r['entity'] in labels and (r['end'] - r['start']) > 1]
sensitive_results = sorted(sensitive_results, key=lambda x: x['start'], reverse=True)
for i in sensitive_results:
    start = i['start']
    end = i['end']
    email = email[:start] + "*" * (end - start) + email[end:]
