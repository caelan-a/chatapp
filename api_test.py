import requests
import json


URL = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/api";
URL_REGISTER = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/register/auth";
URL_LOGIN = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/my/auth"

AUTH_HEADER = "9rvO29TOiyd5p9CPEj_56GRIz3FIvbrz0iJhT5jJKC8";

URL = "https://waspdev.mtr.co.uk/mobapi/1.0/mob-device/get-models"; 


payload = {
    "site_id": "18",
    "device_info":{"make":"Samsung", "model": "S7", "storage": ""}
}

headers = {'API-KEY': API_KEY,
 'TOKEN': TOKEN}

print("Getting price..\n")
r = requests.post(URL,
 json=payload,
 headers=headers)
print(r.json())
