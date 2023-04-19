// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "solmate/utils/LibString.sol";

error NonExistentTokenURI();

contract AgorappBadgeV1 is ERC721("Agorapp Badge", "AGORA"), Owned(msg.sender), ERC721TokenReceiver {
    using LibString for uint256;

    uint256 public currentTokenId;
    
    mapping(uint256 => bytes32) private _nftToOauthAccount;
    mapping(bytes32 => uint256) private _oauthVaultBalance;
    mapping(uint256 => string) private _tokenURIs;

    event OauthNFTMinted(uint256 indexed tokenId, bytes32 indexed oauthCredentialHash, string indexed tokenURI);
    event OauthNFTClaimed(address indexed to, uint256 indexed tokenId);



    function mintBadgeTo(bytes32 oauthCredentialHash, string calldata tokenURI) external onlyOwner returns (uint256) {
        uint256 newItemId = ++currentTokenId;
        require(_nftToOauthAccount[newItemId] == bytes32(0), "OAUTH_HAS_ID");
        _nftToOauthAccount[newItemId] = oauthCredentialHash;
        _oauthVaultBalance[oauthCredentialHash]++;
        // sets tokenURI
        _tokenURIs[newItemId] = tokenURI;
        _safeMint(address(this), newItemId);
        emit OauthNFTMinted(newItemId, oauthCredentialHash, tokenURI);
        return newItemId;
    }

    function migrateVaultToOauthWallet(
        address to,
        uint256 id,
        bytes32 oauthCredentialHash
    ) external onlyOwner {
        require(address(this) == _ownerOf[id], "NOT_VAULT_ID");
        require(to != address(0), "INVALID_RECIPIENT");
        // the id must be associated with the oauth credentials
        require(_nftToOauthAccount[id] == oauthCredentialHash, "WRONG_OAUTH");

        unchecked {
            _balanceOf[address(this)]--;

            _balanceOf[to]++;

            _oauthVaultBalance[oauthCredentialHash]--;
        }

        _ownerOf[id] = to;
        _nftToOauthAccount[id] = bytes32(0);
        emit OauthNFTClaimed(to, id);
    }

    function oauthOwnerOf(uint256 id) external view returns (bytes32 oauthOwner) {
        return _nftToOauthAccount[id];
    }

    function oauthBalanceOf(bytes32 oauthOwner) external view returns (uint256) {
        return _oauthVaultBalance[oauthOwner];
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "WRONG_ID");
        return _tokenURIs[tokenId];
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return _nftToOauthAccount[tokenId] != bytes32(0);
    }
}