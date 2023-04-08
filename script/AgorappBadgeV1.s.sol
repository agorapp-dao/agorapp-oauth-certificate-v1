// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AgorappBadgeV1.sol";

contract AgorappBadgeV1Script is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AgorappBadgeV1 agorappBadgeV1 = new AgorappBadgeV1();

        vm.stopBroadcast();
    }
}
