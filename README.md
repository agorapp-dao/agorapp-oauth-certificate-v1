## Install
In order to run this project, it's necessary to install Foundry on your host machine. Follow the instructions [here](https://book.getfoundry.sh/getting-started/installation) to set it up.

After successful installation you can install the project's dependencies:
```
forge install
```
## Compile
```
forge build
```

## Test
```
forge test -vvvv
```

## Deploy
```
forge script script/AgorappBadgeV1.s.sol:AgorappBadgeV1Script --rpc-url $POLYGON_TESTNET --broadcast -vvvv --verify
```