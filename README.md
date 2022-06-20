# Shen's Kaleido Project

This project is based on kaleido-go project (https://github.com/kaleido-io/kaleido-go). 

The signing method is set to external signing with provided key file or generated a new one. 

An instance of ERC721 contract is provided with mint, burn, and transfer function. 



## Running
```sh
Usage:
  kaleido-go-sz [flags]

Flags:
  -a, --accounts stringArray       Account addresses - 1 per worker needed for geth signing
  -x, --args stringArray           String arguments to pass to contract method (auto-converted to type)
  -C, --call                       Call the contract and return a value, rather than sending a txn
  -i, --chainid int                Chain ID for EIP155 signing (networkid queried if omitted)
  -c, --contract string            Pre-deployed contract address. Will be deployed if not specified
  -n, --contractname string        The name of the contract to call, for Solidity files with multiple contracts
  -d, --debug int                  0=error, 1=info, 2=debug (default 1)
  -E, --estimategas                Estimate the gas for the contract call, rather than sending a txn
  -e, --extsign                    Sign externally with generated private keys + accounts
  -f, --file string                Solidity smart contract source. Deployed if --contract not supplied
  -F, --flush-period int           Flush period for statsd metrics (ms) (default 1000)
  -g, --gas int                    Gas limit on the transaction (default 1000000)
  -G, --gasprice int               Gas price
  -h, --help                       help for kaleido-go
  -k, --keys string                JSON file to create/update with an array of private keys for extsign
  -l, --loops int                  Loops to perform in each worker before exiting (0=infinite) (default 1)
  -m, --method string              Method name in the contract to invoke
  -M, --metrics string             statsd server to submit metrics to
  -q, --metrics-qualifier string   Additional metrics qualifier
  -N, --nonce int                  Nonce (transaction number) for the next transaction (default -1)
  -P, --privateFor stringArray     Private for (see EEA Client Spec V1)
  -p, --privateFrom string         Private from (see EEA Client Spec V1)
  -R, --rpc-timeout int            Timeout in seconds for an individual RCP call (default 30)
  -S, --seconds-max int            Time in seconds before timing out waiting for a txn receipt (default 20)
  -s, --seconds-min int            Time in seconds to wait before checking for a txn receipt (default 11)
  -T, --telegraf                   Telegraf/InfluxDB stats naming (default is Graphite)
  -t, --transactions int           Count of transactions submit on each worker loop (default 1)
  -u, --url string                 JSON/RPC URL for Ethereum node: https://user:pass@xyz-rpc.kaleido.io
  -w, --workers int                Number of workers to run (default 1)

Required flags:
  -u url for node
  -f file for solidity
  -m method for calling

Changes:
  compare to kaleido go:
  privateFrom -p is removed as it is not compatible with external signed
  exterSign   -e is removed as it is set to be True 
  key         -k is set to ./contract-keys/nodekey-$NODEACCOUNT.json if not specified and if only one node is input
```

## Build

```sh
make
```

## Examples

Example commands below expect you to have set the following parameters:

```sh
# The full Node URL including any application credentials
NODE_URL="http://localhost:22001"
# Account existing on the node
ACCOUNT=0x69a54fec0630ff6959ab3acf254579c4b7a67b64
```

# Deploy a ERC721 contract and call a mint

Shell Command (linux/mac):

```sh
# mint one token for account
# without -k line, key file is defaulted as ./contract-keys/nodekey-0x69a54fec0630ff6959ab3acf254579c4b7a67b64.json
# the address of contrast, together with a time stamp, is stored in ./contract-address/address.json
./kaleido-go \
  -f ./contract/sz.sol \
  -m mintMulti \
  -x $ACCOUNT -x 1 \
  -u "$NODE_URL" \
  -a "$ACCOUNT" \
  -n contract/sz.sol:sz \
  -k ./contract-keys/example.json \ 
```

> You can enable DEBUG output with `-d 2`

Example output:

```
INFO[2022-06-20T12:12:34-04:00] File ./contract-keys/example.json does not exist, it will be created (open ./contract-keys/example.json: no such file or directory)
INFO[2022-06-20T12:12:34-04:00] Exercising method 'mintMulti' in solidity contract ./contract/sz.sol
INFO[2022-06-20T12:12:34-04:00] Deploying contract using worker W0000
INFO[2022-06-20T12:12:34-04:00] W0000/L0000/N000000: TX:0x86e6f39ced21680a80f6014f7916c2c569848bc70611853248b44589b6daf374 Sent. OK=true [0.00s]
INFO[2022-06-20T12:12:45-04:00] W0000/L0000/N000000: TX:0x86e6f39ced21680a80f6014f7916c2c569848bc70611853248b44589b6daf374 Mined=true after 11.01s [0.00s]
INFO[2022-06-20T12:12:45-04:00] test receipt: &{0x4d824e471735289e1ce5847367d134e9d02b753b82b80a0a9b3e08d754b6f9a3 0x11 0x2d1B97e4426E6CCe4821C391a70C20085764e0BA 0x1efcd 0x86e6f39ced21680a80f6014f7916c2c569848bc70611853248b44589b6daf374 0x367C771918e303A9593fFc2Eb2710130077CCd08 0x1efcd 0x1 <nil> 0x0}
INFO[2022-06-20T12:12:45-04:00] Contract address=0x2d1B97e4426E6CCe4821C391a70C20085764e0BA
INFO[2022-06-20T12:12:45-04:00] W0000/L0000/N000001: TX:0x17dacf3033b299ac90e37532f91283d3a84202768b11d4e242579ca5909cdf02 Sent. OK=true [0.01s]
INFO[2022-06-20T12:12:56-04:00] W0000/L0000/N000002: TX:0x17dacf3033b299ac90e37532f91283d3a84202768b11d4e242579ca5909cdf02 Mined=true after 11.00s [0.00s]
INFO[2022-06-20T12:12:56-04:00] All workers complete. Success=1 Failure=0

```

# Call the deployed contract to get the value


Shell Command (linux/mac):

```sh
# in -c line, example is for last called contract; also could input contract address directly
./kaleido-go \
  -f ./contract/sz.sol \
  -m ownerOf \
  -x 1 \
  -u "$NODE_URL" \
  -a "$ACCOUNT" \
  -n contract/sz.sol:sz \
  -k ./contract-keys/example.json \
  -c ./contract-address/address.json \
  -C True
```

> TODO: Perform data-type sensitive parsing of return values

Example output:
```
INFO[2022-06-20T12:25:27-04:00] Externally signing using private keys in ./contract-keys/nodekey-0x69a54fec0630ff6959ab3acf254579c4b7a67b64.json
INFO[2022-06-20T12:25:27-04:00] Exercising method 'ownerOf' in solidity contract ./contract/sz.sol
INFO[2022-06-20T12:25:27-04:00] Using last called contract: 0x2d1B97e4426E6CCe4821C391a70C20085764e0BA
INFO[2022-06-20T12:25:27-04:00] Contract address=0x2d1B97e4426E6CCe4821C391a70C20085764e0BA
INFO[2022-06-20T12:25:27-04:00] W0000/L0000/N000003: call result: '0x69a54fec0630ff6959ab3acf254579c4b7a67b64' [0.00s]
INFO[2022-06-20T12:25:38-04:00] All workers complete. Success=0 Failure=0

