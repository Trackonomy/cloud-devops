#!/bin/python3
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import os
import logging
import sys
def get_kv_client():
    keyVaultName = os.environ["KEY_VAULT_NAME"]
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
    client = SecretClient(vault_url=KVUri, credential=credential,logging_enable=True)
    return client
def main():
    variables_env = open("variables.env", "r")
    client = get_kv_client()
    content_type="text/plain"
    logger = logging.getLogger('azure')
    logger.setLevel(logging.DEBUG)


    # Configure a console output
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)
    for line in variables_env.readlines():
        kv = line.split("=", 1)
        key = str(kv[0])
        value = str(kv[1])

        key_replaced = key.replace("_", "-")
        #try:
        print (key_replaced, "-->>>", value)
        #print(type(key), "---->>>>", type(value))
        secret = client.set_secret(key_replaced, value=value, content_type=content_type)
        print(secret.name)
        #except Exception:
            #print("ERROR ON KEY!!!!!!")
            #print(key_replaced)
            #print(value)
        #print(line)
        
    variables_env.close()


if __name__=="__main__":
    main()