#!/bin/python3
import os
import logging
import sys
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import ResourceNotFoundError
import argparse

def get_kv_client():
    keyVaultName = os.environ["KEY_VAULT_NAME"]
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
    client = SecretClient(vault_url=KVUri, credential=credential)
    return client


def parse_args():
    parser = argparse.ArgumentParser(
        prog='Key Vault Secret Extractor',
        description='Extracts secrets from specified Key Vault'
        )
    parser.add_argument('-e', '--environment')
    args = parser.parse_args()
    return args

def prefix_flow(secret_name_prefix):
    client = get_kv_client()
    logger = logging.getLogger('azure')
    logger.setLevel(logging.ERROR)
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)
    with open("variables.env", "w") as f:
        secrets = client.list_properties_of_secrets()
        
        for secret_property in secrets:
            value = ''
            secret = secret_property.name
            if secret is None:
                print('SKIPPED EMPTY NAME SECRET')
                continue
            if not secret.startswith(secret_name_prefix):
                print(f"Skipping secret: {secret}")
                continue
            try:
                extracted_secret = client.get_secret(secret)
                value = extracted_secret.value
            except ResourceNotFoundError:
                print(f"CANNOT EXTRACT SECRET {secret}")
                sys.exit(1)
        
            if secret_name_prefix != '':
                secret = secret.removeprefix(secret_name_prefix)
            secret_transformed = secret.replace("-", "_")
            value = value.rstrip("\n")
            f.write(f"{secret_transformed}={value}" + "\n")
            print(f"Extracted {secret_transformed}")
        f.close()

def no_prefix_flow():
    client = get_kv_client()
    logger = logging.getLogger('azure')
    logger.setLevel(logging.ERROR)
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)
    with open("variables.env", "w") as f:
        secrets = client.list_properties_of_secrets()
        
        for secret_property in secrets:
            value = ''
            secret = secret_property.name
            if secret is None:
                print('SKIPPED EMPTY NAME SECRET')
                continue
            try:
                extracted_secret = client.get_secret(secret)
                value = extracted_secret.value
            except ResourceNotFoundError:
                print(f"CANNOT EXTRACT SECRET {secret}")
                sys.exit(1)

            secret_transformed = secret.replace("-", "_")
            value = value.rstrip("\n")
            f.write(f"{secret_transformed}={value}" + "\n")
            print(f"Extracted {secret_transformed}")
        f.close()

def main():
    args = parse_args()
    secret_name_prefix = ''
    env = args.environment
    if env != None:
        env = str(env)
        secret_name_prefix = env.upper() + '-'
        prefix_flow(secret_name_prefix)
    else:
        no_prefix_flow()

if __name__=="__main__":
    main()