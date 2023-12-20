#!/bin/python3
#SET 
#KEY_VAULT_NAME
#AZURE_CLIENT_ID
#AZURE_CLIENT_SECRET
#AZURE_TENANT_ID

import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import sys
import logging
import argparse

def get_kv_client():
    keyVaultName = os.environ["KEY_VAULT_NAME"]
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
    client = SecretClient(vault_url=KVUri, credential=credential,logging_enable=True)
    return client

def parse_args():
    parser = argparse.ArgumentParser(
        prog='Key Vault Secret Extractor',
        description='Extracts secrets from specified Key Vault'
        )
    parser.add_argument('-e', '--environment')
    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    secret_name_prefix = ''
    env = args.environment
    if env != None:
        env = str(env)
        secret_name_prefix = env.upper() + '-'
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
        print(secret_name_prefix + key_replaced, "-->>>", value)
        #print(type(key), "---->>>>", type(value))
        secret = client.set_secret(secret_name_prefix + key_replaced, value=value, content_type=content_type)
        print(secret.name)
        #except Exception:
            #print("ERROR ON KEY!!!!!!")
            #print(key_replaced)
            #print(value)
        #print(line)
        
    variables_env.close()


if __name__=="__main__":
    main()