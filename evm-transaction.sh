#!/bin/bash
# evm-transaction.sh
# This script sends multiple transactions on any Ethereum-based blockchain.
# It asks for your private key, network type, RPC URL, a range for the transfer amount (in ETH),
# and the number of transactions to send.
# If no recipient address is provided, a random one will be generated.
#
# Made With Love By SIRTOOLZ
# 📢 Join my Telegram: https://t.me/sirtoolzalpha
# 🐦 Follow me on Twitter: https://twitter.com/sirtoolz

# Check if python3 is installed
if ! command -v python3 &>/dev/null; then
    echo "python3 is required but not installed. Please install python3 and try again."
    exit 1
fi

# Check if Web3.py is installed; if not, attempt to install it.
if ! python3 -c "import web3" &>/dev/null; then
    echo "Web3.py not found. Installing it now..."
    pip3 install web3 || { echo "Failed to install Web3.py. Please install it manually."; exit 1; }
fi

# Create a temporary Python script file
TMP_PY=$(mktemp /tmp/evm_tx_script.XXXXXX.py)

cat << 'EOF' > "$TMP_PY"
import secrets
import sys
import random
from web3 import Web3

# ANSI color codes
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
GREEN = "\033[1;32m"
BLUE = "\033[1;34m"
CYAN = "\033[1;36m"
MAGENTA = "\033[1;35m"
RESET = "\033[0m"

def print_banner():
    print(YELLOW + "══════════════════════════════════════════════" + RESET)
    print(RED + "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥" + RESET)
    print(YELLOW + "█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█" + RESET)
    print(GREEN + "█  ❤️ Made With Love By SIRTOOLZ ❤️  █" + RESET)
    print(BLUE + "█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█" + RESET)
    print(RED + "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥" + RESET)
    print(YELLOW + "══════════════════════════════════════════════" + RESET)
    print(GREEN + "🚀 WELCOME TO THE ETHEREUM-BASED TX SENDER!" + RESET)
    print(BLUE + "📢 Join my Telegram: https://t.me/sirtoolzalpha" + RESET)
    print(CYAN + "🐦 Follow me on Twitter: https://twitter.com/sirtoolz" + RESET)
    print(YELLOW + "══════════════════════════════════════════════\n" + RESET)

def generate_random_address():
    # Generate a random 20-byte hex string and format as an Ethereum address.
    return "0x" + secrets.token_hex(20)

# Print banner
print_banner()

# Ask for the user's private key first.
private_key = input(GREEN + "Enter your wallet private key: " + RESET).strip()
if not private_key:
    print(RED + "❌ No private key provided. Exiting." + RESET)
    sys.exit(1)

# Ask user to select network type (for informational purposes)
network_type = input(CYAN + "Choose network type (1: Mainnet, 2: Testnet): " + RESET).strip()

# Ask for the RPC URL of the blockchain
rpc_url = input(MAGENTA + "Enter the RPC URL of the blockchain: " + RESET).strip()
if not rpc_url:
    print(RED + "❌ No RPC URL provided. Exiting." + RESET)
    sys.exit(1)

# Ask for minimum and maximum amount to transfer (in ETH)
min_amount_str = input(BLUE + "Enter the minimum amount to transfer (in ETH): " + RESET).strip()
max_amount_str = input(BLUE + "Enter the maximum amount to transfer (in ETH): " + RESET).strip()
try:
    min_amount = float(min_amount_str)
    max_amount = float(max_amount_str)
    if min_amount < 0 or max_amount < 0 or max_amount < min_amount:
        raise ValueError
except ValueError:
    print(RED + "❌ Invalid amount range provided. Exiting." + RESET)
    sys.exit(1)

# Ask for the number of transactions to send
num_tx_str = input(CYAN + "Enter the number of transactions to send: " + RESET).strip()
try:
    num_tx = int(num_tx_str)
    if num_tx < 1:
        raise ValueError
except ValueError:
    print(RED + "❌ Invalid number of transactions. Exiting." + RESET)
    sys.exit(1)

# Ask for the recipient address
recipient = input(CYAN + "Enter the recipient address (or leave blank to generate one): " + RESET).strip()
if not recipient:
    recipient = generate_random_address()
    print(GREEN + f"⚡ No recipient provided. Generated random address: {recipient}" + RESET)

# Connect to the blockchain
web3 = Web3(Web3.HTTPProvider(rpc_url))
if not web3.is_connected():
    print(RED + "❌ Error: Unable to connect to the blockchain. Check your RPC URL." + RESET)
    sys.exit(1)

# Load account details
try:
    account = web3.eth.account.from_key(private_key)
except Exception as e:
    print(RED + "❌ Invalid private key. Exiting." + RESET)
    sys.exit(1)

sender_address = account.address
print(GREEN + f"✅ Loaded sender address: {sender_address}" + RESET)

# Get gas price and starting nonce
try:
    gas_price = web3.eth.gas_price
except Exception as e:
    print(RED + "❌ Unable to retrieve gas price. Exiting." + RESET)
    sys.exit(1)

nonce = web3.eth.get_transaction_count(sender_address)

# Send the specified number of transactions
for i in range(num_tx):
    # Randomly choose an amount between the minimum and maximum provided
    random_amount = random.uniform(min_amount, max_amount)
    amount_wei = web3.to_wei(random_amount, 'ether')
    
    tx = {
        'to': recipient,
        'value': amount_wei,
        'gas': 21000,
        'gasPrice': gas_price,
        'nonce': nonce,
        'chainId': web3.eth.chain_id
    }
    
    # Sign the transaction
    signed_tx = web3.eth.account.sign_transaction(tx, private_key)
    
    # Retrieve raw transaction data (handle attribute fallback)
    try:
        raw_tx = signed_tx.rawTransaction
    except AttributeError:
        try:
            raw_tx = signed_tx['rawTransaction']
        except Exception as e:
            try:
                raw_tx = signed_tx['raw_transaction']
            except Exception as e2:
                print(RED + f"❌ Failed to retrieve raw transaction data for transaction {i+1}" + RESET)
                sys.exit(1)
    
    # Send the transaction
    try:
        tx_hash = web3.eth.send_raw_transaction(raw_tx)
        print(GREEN + f"✅ Transaction {i+1}/{num_tx} sent! Tx Hash: {web3.to_hex(tx_hash)}" + RESET)
        print(GREEN + f"   Amount sent: {random_amount:.4f} ETH" + RESET)
    except Exception as e:
        print(RED + f"❌ Failed to send transaction {i+1}/{num_tx}: {e}" + RESET)
    
    # Increment the nonce for the next transaction
    nonce += 1
EOF

# Run the embedded Python script
python3 "$TMP_PY"

# Clean up the temporary file
rm "$TMP_PY"
