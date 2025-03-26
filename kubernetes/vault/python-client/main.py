import os 
import requests
import time
# Отримати змінну оточення
vault_addr = os.getenv("VAULT_ADDR", "default_value")  # Якщо змінна не знайдена, буде повернено "default_value"
jwt_path = os.getenv("JWT_PATH", "default_value") 
print(vault_addr)
print(jwt_path)
# Відкриваємо файл у режимі читання ('r')
with open(jwt_path, 'r') as file:
    jwt = file.read()  # Читаємо весь вміст файлу
    print("JWT TOKEN:\n")
    print(jwt)


data= {'role': 'webapp' , 'jwt' : jwt }
url = f"{vault_addr}/v1/auth/kubernetes/login"
response = requests.post(url, data=data)
if response.status_code == 200:
    print(response.json())  # Вивести отримані дані у форматі JSON
else:
    print(f"Error: {response.status_code}")
vault_token = response.json()["auth"]["client_token"]
print(vault_token)

headers = {
    'X-Vault-Token': vault_token
}

response = requests.get(f"{vault_addr}/v1/secret/data/webapp/config", headers=headers)
print(response.json())
