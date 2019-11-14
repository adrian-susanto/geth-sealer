# **<network-name> Sealer/ signer - Go Ethereum**
Official external sealer/ signer base image of PoA <network-name>  We use docker, you can read more docker command [here](https://docs.docker.com/engine/reference/run/)


## **Executables**
| Command |Description |
|---|---|
| sealer/signer | (default entrypoint) As a default configuration, it will generate new account, passphrase and keystore, initialize genesis.json and run geth that connect to our bootnode. Working directory on docker container is `/hart`.
| vote | Propose new sealer/signer account to be an authorized sealer/signer on <network-name>  We use web3 command `clique.propose` .
| unvote | Remove sealer/signer account as an authorized sealer/signer on <network-name> 
| join | Automatically put sealer/ signer enode to our database, and update your local static-nodes.json.


## **1. Running <network-name> sealer/ signer**
We highly recommend to use volume `-v` to persist chain data, so if your container broken/ destroy, chain data will be available on your host. Run this to synchronize to <network-name> :

```
docker run -d --restart=always -v <local-path>:/hart <image> <organization-name> <email>

example :
docker run -d --restart=always -v /hartsealer:/hart <network-name>token/sealer:0.1 xyz-company admin@xyz-company.com
```


## **2. Find your Generated Account**
Run this command
```
docker exec <containerID> account

example:
docker exec 5e5cddff753d account

result will be like:
["0x3856afffa6579254dde5dfe2551b13856b1d1485"]
```
then let other authorized sealer/ signer know your account, so they can propose your account to be an authorized sealer/ signer.


## **3. Watch your sealer/ signer's logs**
You can watch your logs through this command
```
docker logs -f <containerID>

example:
docker logs -f 5e5cddff753d
```

if your logs say
```
INFO [09-16|09:03:28.382] Imported new block receipts              count=2048 elapsed=172.688ms number=268480 hash=da70fd…e21f27 age=10mo2w3d   size=1.26MiB
INFO [09-16|09:03:28.791] Imported new block headers               count=1856 elapsed=691.900ms number=270336 hash=7ddd97…8eb688 age=10mo2w3d
INFO [09-16|09:03:28.896] Imported new block headers               count=192  elapsed=91.226ms  number=270528 hash=599a91…112277 age=10mo2w2d
INFO [09-16|09:03:28.993] Imported new block receipts              count=1856 elapsed=141.832ms number=270336 hash=7ddd97…8eb688 age=10mo2w3d   size=1.15MiB
INFO [09-16|09:03:29.018] Imported new block receipts              count=192  elapsed=23.211ms  number=270528 hash=599a91…112277 age=10mo2w2d   size=121.31KiB
INFO [09-16|09:03:29.678] Imported new block headers               count=2048 elapsed=752.928ms number=272576 hash=b7a556…aeb14c age=10mo2w2d
```
that's mean your sealer/ signer is synchronizing.

When your sealer/ signer has been fully synchronized with <network-name> (but not authorize yet), your logs will say the as this
```
INFO [09-16|05:43:05.014] Imported new chain segment               blocks=1   txs=0 mgas=0.000 elapsed=306.588µs mgasps=0.000 number=5687969 hash=ed29ee…5fc669 dirty=0.00B
INFO [09-16|05:43:05.015] Commit new mining work                   number=5687970 sealhash=535047…677457 uncles=0 txs=0 gas=0 fees=0 elapsed=169.556µs
WARN [09-16|05:43:05.015] Block sealing failed                     err="unauthorized signer"
INFO [09-16|05:43:09.211] Deep froze chain segment                 blocks=12  elapsed=29.495ms  number=5597968 hash=c15eee…850820
INFO [09-16|05:43:10.015] Imported new chain segment               blocks=1   txs=0 mgas=0.000 elapsed=652.125µs mgasps=0.000 number=5687970 hash=463ea3…d39d71 dirty=0.00B
INFO [09-16|05:43:10.015] Commit new mining work                   number=5687971 sealhash=f883e7…dfcd7c uncles=0 txs=0 gas=0 fees=0 elapsed=135.994µs
WARN [09-16|05:43:10.015] Block sealing failed                     err="unauthorized signer"
```

## **4. Update static-nodes.json**
After 50%+1 of authorized sealer/ signer propose your account **AND** your sealer/ signer fully synchronized with <network-name> run this command :
```
docker exec <containerID> join

example:
docker exec 5e5cddff753d join

If your account is an authorized sealer/ signer, response will be "date = account authorized"
```

## **Other Informations**
#### **Vote new sealer/ signer account**
In PoA, sealer/ signer will be nothing if they can't sign block. So new account should be propose by 50% + 1 of the current authorized sealer/ signer. You should remote/ SSH to your host and run :
```
docker exec <containerID> vote <new-sealer-account>

example :
docker exec 5e5cddff753d vote 0x27d7f06f2065bf6fac5f08d0a7375fc0a1190f2a
```
***NOTE*** : *We did not recommend you to expose RPC port to the world*


#### **Unvote sealer/ signer account**
```
docker exec <containerID> unvote <sealer-account>

example :
docker exec 5e5cddff753d unvote 0x27d7f06f2065bf6fac5f08d0a7375fc0a1190f2a
```


#### **Backup Your Account**
1. Keystore can be found in `<working-dir>/keystore/`
    
    keystore file name also contain your account, `UTC--<created_date_time>--<this-is-your-account>`

     ```
    example :
    /hart/keystore/UTC--2019-04-26T08-03-08.300037801Z--3856afffa6579254dde5dfe2551b13856b1d1485
    ```

2. Account passphrase saved in `/hart-file/cred/pswd`. Store your passphrase in secure place outside container.


#### **Log File**
Geth logs will be store inside the container at ***/hart/sealer.log***. You can also find it on your local folder that mounted to ***/hart***.


#### **Troubleshoot**
1. Docker restarting, and logs says "*NO pswd found everywhere, please set  on environment variable when run the container*". 

    It is because there is a keystore file on your local-path (came from from last container that use same local-path), but no stored password on /hart-file/cred/pswd

    **Solution :**
    
    stop/ remove the restarting container
    ```
    docker rm -f <containerID>
    ```
    delete keystore file on local-path
    ```
    rm -rfv <local-path>/keystore/*
    ```
    then re-run container