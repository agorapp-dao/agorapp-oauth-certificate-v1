// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/AgorappBadgeV1.sol";

bytes32 constant oauthCredentialHash_one = keccak256(abi.encode("github_username_one"));
bytes32 constant oauthCredentialHash_two = keccak256(abi.encode("username@gmail.com"));
bytes32 constant oauthCredentialHash_three = keccak256(abi.encode("oauthCredentialHash_two"));

contract AgorappBadgeV1Test is Test {
    using stdStorage for StdStorage;

    AgorappBadgeV1 private agorappBadgeV1;

    function setUp() public {
        agorappBadgeV1 = new AgorappBadgeV1();
        emit log_named_address("agorappBadgeV1 address ====>", address(agorappBadgeV1));
    }

    function testBadgeERC721Data() public {
        assertEq(agorappBadgeV1.name(), "Agorapp Badge");
        assertEq(agorappBadgeV1.symbol(), "AGORA");
    }

    function testAgorappBadgeData() public {
        assertEq(agorappBadgeV1.currentTokenId(), 0);
        assertEq(agorappBadgeV1.baseURI(), "base_uri");
        assertEq(agorappBadgeV1.balanceOf(address(agorappBadgeV1)), 0);
    }

    function testOwnerAddress() public {
        assertEq(agorappBadgeV1.owner(), address(this));
    }

    function testMintBadge() public {
        emit log_named_address("owner", agorappBadgeV1.owner());
        assertEq(agorappBadgeV1.nftToOauthAccount(0), bytes32(0));
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 0);

        uint256 id = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);

        assertEq(id, 1);
        assertEq(agorappBadgeV1.nftToOauthAccount(1), oauthCredentialHash_one);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 1);
    }


    function testMintManyBadges() public {
        assertEq(agorappBadgeV1.nftToOauthAccount(0), bytes32(0));
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 0);

        uint256 id_one = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);
        uint256 id_two = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);

        assertEq(id_one, 1);
        assertEq(id_two, 2);
        assertEq(agorappBadgeV1.nftToOauthAccount(1), oauthCredentialHash_one);
        assertEq(agorappBadgeV1.nftToOauthAccount(2), oauthCredentialHash_one);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 2);
    }

    function testMintManyBadgesToManyOauth() public {
        assertEq(agorappBadgeV1.nftToOauthAccount(0), bytes32(0));
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 0);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_two), 0);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_three), 0);

        // oauthCredentialHash_two = balance 1
        uint256 id_one = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        // oauthCredentialHash_one = balance 1
        uint256 id_two = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);
        // oauthCredentialHash_one = balance 2
        uint256 id_three = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);
        // oauthCredentialHash_three = balance 1
        uint256 id_four = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_three);
        // oauthCredentialHash_two = balance 2
        uint256 id_five = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        // oauthCredentialHash_three = balance 2
        uint256 id_six = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_three);
        // oauthCredentialHash_two = balance 3
        uint256 id_seven = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        // oauthCredentialHash_three = balance 3
        uint256 id_eight = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_three);
        // oauthCredentialHash_three = balance 4
        uint256 id_nine = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_three);

        assertEq(id_one, 1);
        assertEq(id_two, 2);
        assertEq(id_three, 3);
        assertEq(id_four, 4);
        assertEq(id_five, 5);
        assertEq(id_six, 6);
        assertEq(id_seven, 7);
        assertEq(id_eight, 8);
        assertEq(id_nine, 9);

        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 2);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_two), 3);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_three), 4);


        assertEq(agorappBadgeV1.nftToOauthAccount(id_one), oauthCredentialHash_two);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_two), oauthCredentialHash_one);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_three), oauthCredentialHash_one);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_four), oauthCredentialHash_three);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_five), oauthCredentialHash_two);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_six), oauthCredentialHash_three);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_seven), oauthCredentialHash_two);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_eight), oauthCredentialHash_three);
        assertEq(agorappBadgeV1.nftToOauthAccount(id_nine), oauthCredentialHash_three);

        assertEq(agorappBadgeV1.balanceOf(address(agorappBadgeV1)), 9);
    }

    function testFailUnauthorizedMintBadge() public {
        vm.startPrank(address(2));
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);
        vm.stopPrank();
    }

    function testBadgeVaultOwnership() public {
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);
        address idOneOwner = agorappBadgeV1.ownerOf(1);
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        address idTwoOwner = agorappBadgeV1.ownerOf(2);
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_three);
        address idThreeOwner = agorappBadgeV1.ownerOf(3);

        assertEq(idOneOwner, address(agorappBadgeV1));
        assertEq(idTwoOwner, address(agorappBadgeV1));
        assertEq(idThreeOwner, address(agorappBadgeV1));
    }

    function testVaultToOauthWallet() public {
        uint256 id_one = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        uint256 id_two = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);
        uint256 id_three = agorappBadgeV1.mintBadgeTo(oauthCredentialHash_one);

        assertEq(agorappBadgeV1.balanceOf(address(agorappBadgeV1)), 3);
        assertEq(agorappBadgeV1.nftToOauthAccount(2), oauthCredentialHash_one);

        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 2);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_two), 1);

        agorappBadgeV1.vaultToOauthWallet(address(10), id_two, oauthCredentialHash_one);

        assertEq(agorappBadgeV1.balanceOf(address(agorappBadgeV1)), 2);
        assertEq(agorappBadgeV1.balanceOf(address(10)), 1);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 1);
        assertEq(agorappBadgeV1.nftToOauthAccount(2), bytes32(0));

        agorappBadgeV1.vaultToOauthWallet(address(99), id_one, oauthCredentialHash_two);

        assertEq(agorappBadgeV1.balanceOf(address(agorappBadgeV1)), 1);
        assertEq(agorappBadgeV1.balanceOf(address(99)), 1);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_two), 0);
        assertEq(agorappBadgeV1.nftToOauthAccount(1), bytes32(0));

        agorappBadgeV1.vaultToOauthWallet(address(10), id_three, oauthCredentialHash_one);
        
        assertEq(agorappBadgeV1.balanceOf(address(agorappBadgeV1)), 0);
        assertEq(agorappBadgeV1.balanceOf(address(10)), 2);
        assertEq(agorappBadgeV1.oauthVaultBalance(oauthCredentialHash_one), 0);
        assertEq(agorappBadgeV1.nftToOauthAccount(3), bytes32(0));
    }

    function testFailUnauthorizedVaultToOauthWallet() public {
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        vm.startPrank(address(999));
        agorappBadgeV1.vaultToOauthWallet(address(7), 1, oauthCredentialHash_two);
        vm.stopPrank();
    }

    function testFailVaultToOauthWalletWithWrongCred() public {
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        agorappBadgeV1.vaultToOauthWallet(address(7), 1, oauthCredentialHash_one);
    }

    function testFailVaultToOauthWalletWithWrongId() public {
        agorappBadgeV1.mintBadgeTo(oauthCredentialHash_two);
        agorappBadgeV1.vaultToOauthWallet(address(7), 1, oauthCredentialHash_one);

        // we call it again after having transferred the nft
        agorappBadgeV1.vaultToOauthWallet(address(7), 1, oauthCredentialHash_one);
    }

}
