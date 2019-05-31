import requests
import json

# URL = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/api";
URL_REGISTER = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/register/auth";
URL_LOGIN = "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/my/auth"

login_payload = {
    "Username" : "caelan",
    "Password" : "password",
}

print("Logging in..\n")
r = requests.post(URL_LOGIN,
 json=login_payload
 )
print(r.text);

# register_payload = {
#     "Username" : "caelana",
#     "Name" : "Caelan",
#     "Password" : "password",
# }

# print("Registering..\n")
# r = requests.post(URL_REGISTER,
#  data=register_payload
#  )
# print(r.text);
