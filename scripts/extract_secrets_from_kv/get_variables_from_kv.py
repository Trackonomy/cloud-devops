#!/bin/python3
import os
import logging
import sys
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from secrets_names import get_secret_names
def get_kv_client():
    keyVaultName = os.environ["KEY_VAULT_NAME"]
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
    client = SecretClient(vault_url=KVUri, credential=credential,logging_enable=True)
    return client

def main():
    client = get_kv_client()
    logger = logging.getLogger('azure')
    logger.setLevel(logging.ERROR)
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)
    env = sys.argv[1]
    if env == "" or env is None:
        print("no env provided")
        sys.exit(1)
    with open("variables.env", "w") as f:
        secret_names = get_secret_names(env)
        for secret in secret_names:
            value = client.get_secret(secret).value
            secret_transformed = secret.replace("-", "_")
            f.write(f"{secret_transformed}={value}")
            print(f"Extracted {secret_transformed}")
        f.close()

if __name__=="__main__":
    main()