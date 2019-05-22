import requests
import json

URL = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/api";
URL_REGISTER = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/register/auth";
URL_LOGIN = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/my/auth"

register_payload = {
    "Username" : "caelan",
    "Password" : "password",
    "Email" : "caelan.andsn@gmail.com"
}

print("Registering..\n")
r = requests.post(URL_REGISTER,
 json=register_payload
 )
print(r.json())
