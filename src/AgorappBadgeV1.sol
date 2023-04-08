// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "solmate/utils/LibString.sol";

error NonExistentTokenURI();

contract AgorappBadgeV1 is ERC721("Agorapp Badge", "AGORA"), ERC721TokenReceiver, Owned(msg.sender) {
    using LibString for uint256;

    uint256 public currentTokenId;
    string public baseURI = "base_uri";
    
    mapping(uint256 => bytes32) public nftToOauthAccount;
    mapping(bytes32 => uint256) public oauthVaultBalance;

    function mintBadgeTo(bytes32 oauthCredentialHash) external onlyOwner returns (uint256) {
        uint256 newItemId = ++currentTokenId;
        require(nftToOauthAccount[newItemId] == bytes32(0), "OAUTH_HAS_ID");
        nftToOauthAccount[newItemId] = oauthCredentialHash;
        oauthVaultBalance[oauthCredentialHash]++;
        _safeMint(address(this), newItemId);
        return newItemId;
    }

    function vaultToOauthWallet(
        address to,
        uint256 id,
        bytes32 oauthCredentialHash
    ) external onlyOwner {
        require(address(this) == _ownerOf[id], "NOT_VAULT_ID");
        require(to != address(0), "INVALID_RECIPIENT");
        // the id must be associated with the oauth credentials
        require(nftToOauthAccount[id] == oauthCredentialHash, "WRONG_OAUTH");

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[address(this)]--;

            _balanceOf[to]++;

            oauthVaultBalance[oauthCredentialHash]--;
        }

        _ownerOf[id] = to;
        nftToOauthAccount[id] = bytes32(0);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }
}