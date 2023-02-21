#!/usr/bin/env bash

# if [ -f .env ]
# then
#   export $(cat .env | xargs) 
# else
#     echo "Please set your .env file"
#     exit 1
# fi

# echo "Please enter the token contract address..."
# read token
# echo "Deploying faucet for the token $token..."

# forge create ./src/Counter.sol:Counter -i --rpc-url 'https://eth-goerli.g.alchemy.com/v2/'${INFURA_API_KEY} --private-key ${PRIVATE_KEY}
forge create ./src/Counter.sol:Counter -i --rpc-url 'https://eth-goerli.g.alchemy.com/v2/'${GOERLI_API_KEY} --private-key ${PRIVATE_KEY} 