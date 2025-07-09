from web3 import Web3
from eth_account.messages import encode_defunct
import eth_account
import os

## Create the account
# w3 = Web3()
# bsc_acc = w3.eth.account.create() # Account for the BSC
# ava_acc = w3.eth.account.create() # Account for the BSC

# print(bsc_acc.address)
# print(ava_acc.address)

# with open("secret_key.txt", "a") as f:
#     f.write(w3.to_hex(bsc_acc.key))
#     f.write("\n")
#     f.write(w3.to_hex(ava_acc.key))

def sign_message(challenge, filename="secret_key.txt"):
    """
    challenge - byte string
    filename - filename of the file that contains your account secret key
    To pass the tests, your signature must verify, and the account you use
    must have testnet funds on both the bsc and avalanche test networks.
    """
    # This code will read your "sk.txt" file
    # If the file is empty, it will raise an exception
    with open(filename, "r") as f:
        key = f.readlines()
    assert(len(key) > 0), "Your account secret_key.txt is empty"

    w3 = Web3()
    message = encode_defunct(challenge)

    # TODO recover your account information for your private key and sign the given challenge
    # Use the code from the signatures assignment to sign the given challenge 
    private_key = key[0].strip()
    account_bsc = w3.eth.account.from_key(private_key)
    eth_addr = account_bsc.address
    signed_message = w3.eth.account.sign_message(message, private_key=private_key) # Sign the message
    
    assert eth_account.Account.recover_message(message,signature=signed_message.signature.hex()) == eth_addr, f"Failed to sign message properly"

    #return signed_message, account associated with the private key
    return signed_message, eth_addr


if __name__ == "__main__":
    for i in range(4):
        challenge = os.urandom(64)
        sig, addr= sign_message(challenge=challenge)
        print( addr )
