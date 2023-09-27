#!/bin/python3
import os
import logging
import sys
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import ResourceNotFoundError
def get_kv_client():
    keyVaultName = os.environ["KEY_VAULT_NAME"]
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
    client = SecretClient(vault_url=KVUri, credential=credential)
    return client

def main():
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
            f.write(f"{secret_transformed}={value}"  + "\n")
            print(f"Extracted {secret_transformed}")
        f.close()

if __name__=="__main__":
    main()