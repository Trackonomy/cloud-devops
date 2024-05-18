#!/bin/python3

from azure.keyvault.secrets import SecretClient
from azure.identity import ClientSecretCredential
from azure.core.exceptions import ResourceNotFoundError
import sys
import logging
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

    variables_env = open(file_name, "r")
    client = get_kv_client(kv_name, client_id, client_secret, tenant_id)

    content_type="text/plain"
    logger = logging.getLogger('azure')
    logger.setLevel(logging.DEBUG)
    env = str(env)
    kv_name = str(kv_name)
    application = str(application)
    client_id = str(client_id)
    client_secret = str(client_secret)
    tenant_id = str(tenant_id)
    secret_name_prefix = application.lower() + "-" +  env.lower() + '-'
    # Configure a console output
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)
    for line in variables_env.readlines():
        kv = line.split("=", 1)
        key = str(kv[0])
        value = str(kv[1])
        key_replaced = key.replace("_", "-")
        key_replaced = secret_name_prefix + key_replaced.lower()
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