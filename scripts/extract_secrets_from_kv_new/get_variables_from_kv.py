#!/bin/python3
import os
import logging
import sys
from azure.keyvault.secrets import SecretClient
from azure.identity import ClientSecretCredential
from azure.core.exceptions import ResourceNotFoundError
import argparse

def parse_args():
    parser = argparse.ArgumentParser(
        prog='Key Vault Secret Extractor',
        description='Extracts secrets from specified Key Vault'
        )
    parser.add_argument('-k', '--key-vault', help='Key Vault name', type=str)
    parser.add_argument('-e', '--environment', help='Environment name in Key Vault', type=str)
    parser.add_argument('-a', '--application', help='Application name of extracted secrets.', type=str)
    parser.add_argument('-f', '--file', help='File name of where to save secrets', type=str)
    parser.add_argument('--client-id', help="Azure Client Id", type=str)
    parser.add_argument('--client-secret', help="Azure Client Secret", type=str)
    parser.add_argument('--tenant-id', help="Azure Tenant Id. If no value specified, default is used.", default="a92ebf37-cae1-460d-8a16-ce7d28d0ff9c", type=str)
    args = parser.parse_args()
    return args

def get_kv_client(kv_name, client_id, client_secret, tenant_id):
    keyVaultName = kv_name
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = ClientSecretCredential(tenant_id=tenant_id,
                                         client_id=client_id,
                                         client_secret=client_secret
                                         )
    client = SecretClient(vault_url=KVUri, credential=credential)
    return client

def validate_secrets(env, application, client_id, client_secret, kv_name):
    help_dict = {
        "env": [False, '--environment|-e'],
        "app": [False, '--application|-a'],
        "cid": [False, '--client-id'],
        "cs": [False, '--client-secret'],
        'kv': [False, '--key-vault']
    }
    something_is_missing = False
    if env is None:
        help_dict['env'][0] = True
        something_is_missing = True
    if application is None:
        help_dict['app'][0] = True
        something_is_missing = True
    if client_id is None:
        help_dict['cid'][0] = True
        something_is_missing = True
    if client_secret is None:
        help_dict['cs'][0] = True
        something_is_missing = True
    if kv_name is None:
        help_dict['kv'][0] = True
        something_is_missing = True
    
    if something_is_missing:
        print(f'''Please provide one of the missing arguments!!! 
                Missing arguments: {[x[1] for x in help_dict.values() if x[0] == True ]}''')
        sys.exit(1)

def prefix_flow(secret_name_prefix, kv_name, client_id, client_secret, tenant_id, file_name):
    client = get_kv_client(kv_name, client_id, client_secret, tenant_id)
    logger = logging.getLogger('azure')
    logger.setLevel(logging.ERROR)
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)
    with open(file_name, "a") as f:
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
            secret_transformed = secret_transformed.upper()
            value = value.rstrip("\n")
            f.write(f"{secret_transformed}={value}" + "\n")
            print(f"Extracted {secret_transformed}")
        f.close()

def main():
    args = parse_args()
    secret_name_prefix = ''
    env = args.environment
    application = args.application
    file_name = args.file
    client_id = args.client_id
    client_secret = args.client_secret
    tenant_id = args.tenant_id
    kv_name = args.key_vault
    validate_secrets(env, application, client_id, client_secret, kv_name)

    if file_name == None:
        file_name = "variables.env"

    env = str(env)
    kv_name = str(kv_name)
    application = str(application)
    client_id = str(client_id)
    client_secret = str(client_secret)
    tenant_id = str(tenant_id)
    secret_name_prefix = application.lower() + "-" +  env.lower() + '-'
    print(secret_name_prefix)
    prefix_flow(secret_name_prefix, kv_name, client_id, client_secret, tenant_id, file_name)

if __name__=="__main__":
    main()