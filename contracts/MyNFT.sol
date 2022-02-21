// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {Base64} from "./library/Base64.sol";
import "hardhat/console.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    event NewPunchNFTMinted(address sender, uint256 tokenId);

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];
    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!
    string[] firstWords = ["Forget", "God", "Fear", "My", "Forever", "Before"];
    string[] secondWords = [
        "Box",
        "Word",
        "Motivated",
        "Girl",
        "Pussy",
        "Money"
    ];
    string[] thirdWords = ["Wanted", "Buzy", "Lazy", "Laugh", "Baby", "Google"];

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    constructor() ERC721("Punchs words", "punchs") {
        console.log("This is my NFT contract. Whoa!");
    }

    function mint() public {
        //current token id
        uint256 newTokenId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newTokenId);
        string memory second = pickRandomSecondWord(newTokenId);
        string memory third = pickRandomThirdWord(newTokenId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        // I concatenate it all together, and then close the <text> and <svg> tags.
        // Add the random color in.
        string memory randomColor = pickRandomColor(newTokenId);
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo,
                combinedWord,
                "</text></svg>"
            )
        );
        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        //mint
        _safeMint(msg.sender, newTokenId);

        //data
        _setTokenURI(newTokenId, finalTokenUri);

        //increment counter
        _tokenIds.increment();

        //event
        emit NewPunchNFTMinted(msg.sender, newTokenId);

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newTokenId,
            msg.sender
        );
    }
}
