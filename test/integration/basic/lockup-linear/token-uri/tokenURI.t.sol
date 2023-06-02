// SPDX-License-Identifier: UNLICENSED
// solhint-disable max-line-length,no-console,quotes
pragma solidity >=0.8.19 <0.9.0;

import { console2 } from "forge-std/console2.sol";
import { StdStyle } from "forge-std/StdStyle.sol";
import { Base64 } from "solady/utils/Base64.sol";

import { LockupLinear_Integration_Basic_Test } from "../LockupLinear.t.sol";

/// @dev Requirements for these tests to work:
/// - The stream id must be 1
/// - The stream's sender must be `0x6332e7b1deb1f1a0b77b2bb18b144330c7291bca`, i.e. `makeAddr("Sender")`
/// - The stream asset must have the DAI symbol
/// - The contract deployer, i.e. the `sender` config option in `foundry.toml`, must have the default value
/// 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 so that the deployed contracts have the same addresses as
/// the values hard coded in the tests below
contract TokenURI_LockupLinear_Integration_Basic_Test is LockupLinear_Integration_Basic_Test {
    address internal constant LOCKUP_LINEAR = 0x3381cD18e2Fb4dB236BF0525938AB6E43Db0440f;
    uint256 internal defaultStreamId;

    /// @dev To make these tests noninvasive, they are run only when the contract address matches the hard coded value.
    modifier skipOnMismatch() {
        if (address(lockupLinear) == LOCKUP_LINEAR) {
            _;
        } else {
            console2.log(StdStyle.yellow('Warning: "LockupLinear.tokenURI" tests skipped due to address mismatch'));
        }
    }

    function test_RevertWhen_NFTDoesNotExist() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert("ERC721: invalid token ID");
        lockupLinear.tokenURI({ tokenId: nullStreamId });
    }

    modifier whenNFTExists() {
        defaultStreamId = createDefaultStream();
        vm.warp({ timestamp: defaults.START_TIME() + defaults.TOTAL_DURATION() / 4 });
        _;
    }

    function test_TokenURI_Decoded() external skipOnMismatch whenNFTExists {
        string memory tokenURI = lockupLinear.tokenURI(defaultStreamId);
        string memory actualDecodedTokenURI = string(Base64.decode(tokenURI));
        string memory expectedDecodedTokenURI =
            unicode'data:application/json;base64,{"attributes":[{"trait_type":"Asset","value":"DAI"},{"trait_type":"Sender","value":"0x6332e7b1deb1f1a0b77b2bb18b144330c7291bca"},{"trait_type":"Status","value":"Streaming"}],"description":"This NFT represents a payment stream in a Sablier V2 Lockup Linear contract. The owner of this NFT can withdraw the streamed assets, which are denominated in DAI.\\n\\n- Stream ID: 1\\n- Lockup Linear Address: 0x3381cd18e2fb4db236bf0525938ab6e43db0440f\\n- DAI Address: 0x03a6a84cd762d9707a21605b548aaab891562aab\\n\\n⚠️ WARNING: Transferring the NFT makes the new owner the recipient of the stream. The funds are not automatically withdrawn for the previous recipient.","external_url":"https://sablier.com","name":"Sablier V2 Lockup Linear #1","image":"data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAwIiBoZWlnaHQ9IjEwMDAiIHZpZXdCb3g9IjAgMCAxMDAwIDEwMDAiPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbHRlcj0idXJsKCNOb2lzZSkiLz48cmVjdCB4PSI3MCIgeT0iNzAiIHdpZHRoPSI4NjAiIGhlaWdodD0iODYwIiBmaWxsPSIjZmZmIiBmaWxsLW9wYWNpdHk9Ii4wMyIgcng9IjQ1IiByeT0iNDUiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLW9wYWNpdHk9Ii4xIiBzdHJva2Utd2lkdGg9IjQiLz48ZGVmcz48Y2lyY2xlIGlkPSJHbG93IiByPSI1MDAiIGZpbGw9InVybCgjUmFkaWFsR2xvdykiLz48ZmlsdGVyIGlkPSJOb2lzZSI+PGZlRmxvb2QgeD0iMCIgeT0iMCIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmxvb2QtY29sb3I9ImhzbCgyMzAsMjElLDExJSkiIGZsb29kLW9wYWNpdHk9IjEiIHJlc3VsdD0iZmxvb2RGaWxsIi8+PGZlVHVyYnVsZW5jZSBiYXNlRnJlcXVlbmN5PSIuNCIgbnVtT2N0YXZlcz0iMyIgcmVzdWx0PSJOb2lzZSIgdHlwZT0iZnJhY3RhbE5vaXNlIi8+PGZlQmxlbmQgaW49Ik5vaXNlIiBpbjI9ImZsb29kRmlsbCIgbW9kZT0ic29mdC1saWdodCIvPjwvZmlsdGVyPjxwYXRoIGlkPSJMb2dvIiBmaWxsPSIjZmZmIiBmaWxsLW9wYWNpdHk9Ii4xIiBkPSJtMTMzLjU1OSwxMjQuMDM0Yy0uMDEzLDIuNDEyLTEuMDU5LDQuODQ4LTIuOTIzLDYuNDAyLTIuNTU4LDEuODE5LTUuMTY4LDMuNDM5LTcuODg4LDQuOTk2LTE0LjQ0LDguMjYyLTMxLjA0NywxMi41NjUtNDcuNjc0LDEyLjU2OS04Ljg1OC4wMzYtMTcuODM4LTEuMjcyLTI2LjMyOC0zLjY2My05LjgwNi0yLjc2Ni0xOS4wODctNy4xMTMtMjcuNTYyLTEyLjc3OC0xMy44NDItOC4wMjUsOS40NjgtMjguNjA2LDE2LjE1My0zNS4yNjVoMGMyLjAzNS0xLjgzOCw0LjI1Mi0zLjU0Niw2LjQ2My01LjIyNGgwYzYuNDI5LTUuNjU1LDE2LjIxOC0yLjgzNSwyMC4zNTgsNC4xNyw0LjE0Myw1LjA1Nyw4LjgxNiw5LjY0OSwxMy45MiwxMy43MzRoLjAzN2M1LjczNiw2LjQ2MSwxNS4zNTctMi4yNTMsOS4zOC04LjQ4LDAsMC0zLjUxNS0zLjUxNS0zLjUxNS0zLjUxNS0xMS40OS0xMS40NzgtNTIuNjU2LTUyLjY2NC02NC44MzctNjQuODM3bC4wNDktLjAzN2MtMS43MjUtMS42MDYtMi43MTktMy44NDctMi43NTEtNi4yMDRoMGMtLjA0Ni0yLjM3NSwxLjA2Mi00LjU4MiwyLjcyNi02LjIyOWgwbC4xODUtLjE0OGgwYy4wOTktLjA2MiwuMjIyLS4xNDgsLjM3LS4yNTloMGMyLjA2LTEuMzYyLDMuOTUxLTIuNjIxLDYuMDQ0LTMuODQyQzU3Ljc2My0zLjQ3Myw5Ny43Ni0yLjM0MSwxMjguNjM3LDE4LjMzMmMxNi42NzEsOS45NDYtMjYuMzQ0LDU0LjgxMy0zOC42NTEsNDAuMTk5LTYuMjk5LTYuMDk2LTE4LjA2My0xNy43NDMtMTkuNjY4LTE4LjgxMS02LjAxNi00LjA0Ny0xMy4wNjEsNC43NzYtNy43NTIsOS43NTFsNjguMjU0LDY4LjM3MWMxLjcyNCwxLjYwMSwyLjcxNCwzLjg0LDIuNzM4LDYuMTkyWiIvPjxwYXRoIGlkPSJGbG9hdGluZ1RleHQiIGZpbGw9Im5vbmUiIGQ9Ik0xMjUgNDVoNzUwczgwIDAgODAgODB2NzUwczAgODAgLTgwIDgwaC03NTBzLTgwIDAgLTgwIC04MHYtNzUwczAgLTgwIDgwIC04MCIvPjxyYWRpYWxHcmFkaWVudCBpZD0iUmFkaWFsR2xvdyI+PHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iaHNsKDE5LDIyJSw2MyUpIiBzdG9wLW9wYWNpdHk9Ii42Ii8+PHN0b3Agb2Zmc2V0PSIxMDAlIiBzdG9wLWNvbG9yPSJoc2woMjMwLDIxJSwxMSUpIiBzdG9wLW9wYWNpdHk9IjAiLz48L3JhZGlhbEdyYWRpZW50PjxsaW5lYXJHcmFkaWVudCBpZD0iU2FuZFRvcCIgeDE9IjAlIiB5MT0iMCUiPjxzdG9wIG9mZnNldD0iMCUiIHN0b3AtY29sb3I9ImhzbCgxOSwyMiUsNjMlKSIvPjxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iaHNsKDIzMCwyMSUsMTElKSIvPjwvbGluZWFyR3JhZGllbnQ+PGxpbmVhckdyYWRpZW50IGlkPSJTYW5kQm90dG9tIiB4MT0iMTAwJSIgeTE9IjEwMCUiPjxzdG9wIG9mZnNldD0iMTAlIiBzdG9wLWNvbG9yPSJoc2woMjMwLDIxJSwxMSUpIi8+PHN0b3Agb2Zmc2V0PSIxMDAlIiBzdG9wLWNvbG9yPSJoc2woMTksMjIlLDYzJSkiLz48YW5pbWF0ZSBhdHRyaWJ1dGVOYW1lPSJ4MSIgZHVyPSI2cyIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHZhbHVlcz0iMzAlOzYwJTsxMjAlOzYwJTszMCU7Ii8+PC9saW5lYXJHcmFkaWVudD48bGluZWFyR3JhZGllbnQgaWQ9IkhvdXJnbGFzc1N0cm9rZSIgZ3JhZGllbnRUcmFuc2Zvcm09InJvdGF0ZSg5MCkiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj48c3RvcCBvZmZzZXQ9IjUwJSIgc3RvcC1jb2xvcj0iaHNsKDE5LDIyJSw2MyUpIi8+PHN0b3Agb2Zmc2V0PSI4MCUiIHN0b3AtY29sb3I9ImhzbCgyMzAsMjElLDExJSkiLz48L2xpbmVhckdyYWRpZW50PjxnIGlkPSJIb3VyZ2xhc3MiPjxwYXRoIGQ9Ik0gNTAsMzYwIGEgMzAwLDMwMCAwIDEsMSA2MDAsMCBhIDMwMCwzMDAgMCAxLDEgLTYwMCwwIiBmaWxsPSIjZmZmIiBmaWxsLW9wYWNpdHk9Ii4wMiIgc3Ryb2tlPSJ1cmwoI0hvdXJnbGFzc1N0cm9rZSkiIHN0cm9rZS13aWR0aD0iNCIvPjxwYXRoIGQ9Im01NjYsMTYxLjIwMXYtNTMuOTI0YzAtMTkuMzgyLTIyLjUxMy0zNy41NjMtNjMuMzk4LTUxLjE5OC00MC43NTYtMTMuNTkyLTk0Ljk0Ni0yMS4wNzktMTUyLjU4Ny0yMS4wNzlzLTExMS44MzgsNy40ODctMTUyLjYwMiwyMS4wNzljLTQwLjg5MywxMy42MzYtNjMuNDEzLDMxLjgxNi02My40MTMsNTEuMTk4djUzLjkyNGMwLDE3LjE4MSwxNy43MDQsMzMuNDI3LDUwLjIyMyw0Ni4zOTR2Mjg0LjgwOWMtMzIuNTE5LDEyLjk2LTUwLjIyMywyOS4yMDYtNTAuMjIzLDQ2LjM5NHY1My45MjRjMCwxOS4zODIsMjIuNTIsMzcuNTYzLDYzLjQxMyw1MS4xOTgsNDAuNzYzLDEzLjU5Miw5NC45NTQsMjEuMDc5LDE1Mi42MDIsMjEuMDc5czExMS44MzEtNy40ODcsMTUyLjU4Ny0yMS4wNzljNDAuODg2LTEzLjYzNiw2My4zOTgtMzEuODE2LDYzLjM5OC01MS4xOTh2LTUzLjkyNGMwLTE3LjE5Ni0xNy43MDQtMzMuNDM1LTUwLjIyMy00Ni40MDFWMjA3LjYwM2MzMi41MTktMTIuOTY3LDUwLjIyMy0yOS4yMDYsNTAuMjIzLTQ2LjQwMVptLTM0Ny40NjIsNTcuNzkzbDEzMC45NTksMTMxLjAyNy0xMzAuOTU5LDEzMS4wMTNWMjE4Ljk5NFptMjYyLjkyNC4wMjJ2MjYyLjAxOGwtMTMwLjkzNy0xMzEuMDA2LDEzMC45MzctMTMxLjAxM1oiIGZpbGw9IiMxNjE4MjIiPjwvcGF0aD48cG9seWdvbiBwb2ludHM9IjM1MCAzNTAuMDI2IDQxNS4wMyAyODQuOTc4IDI4NSAyODQuOTc4IDM1MCAzNTAuMDI2IiBmaWxsPSJ1cmwoI1NhbmRCb3R0b20pIi8+PHBhdGggZD0ibTQxNi4zNDEsMjgxLjk3NWMwLC45MTQtLjM1NCwxLjgwOS0xLjAzNSwyLjY4LTUuNTQyLDcuMDc2LTMyLjY2MSwxMi40NS02NS4yOCwxMi40NS0zMi42MjQsMC01OS43MzgtNS4zNzQtNjUuMjgtMTIuNDUtLjY4MS0uODcyLTEuMDM1LTEuNzY3LTEuMDM1LTIuNjgsMC0uOTE0LjM1NC0xLjgwOCwxLjAzNS0yLjY3Niw1LjU0Mi03LjA3NiwzMi42NTYtMTIuNDUsNjUuMjgtMTIuNDUsMzIuNjE5LDAsNTkuNzM4LDUuMzc0LDY1LjI4LDEyLjQ1LjY4MS44NjcsMS4wMzUsMS43NjIsMS4wMzUsMi42NzZaIiBmaWxsPSJ1cmwoI1NhbmRUb3ApIi8+PHBhdGggZD0ibTQ4MS40Niw0ODEuNTR2ODEuMDFjLTIuMzUuNzctNC44MiwxLjUxLTcuMzksMi4yMy0zMC4zLDguNTQtNzQuNjUsMTMuOTItMTI0LjA2LDEzLjkyLTUzLjYsMC0xMDEuMjQtNi4zMy0xMzEuNDctMTYuMTZ2LTgxbDQ2LjMtNDYuMzFoMTcwLjMzbDQ2LjI5LDQ2LjMxWiIgZmlsbD0idXJsKCNTYW5kQm90dG9tKSIvPjxwYXRoIGQ9Im00MzUuMTcsNDM1LjIzYzAsMS4xNy0uNDYsMi4zMi0xLjMzLDMuNDQtNy4xMSw5LjA4LTQxLjkzLDE1Ljk4LTgzLjgxLDE1Ljk4cy03Ni43LTYuOS04My44Mi0xNS45OGMtLjg3LTEuMTItMS4zMy0yLjI3LTEuMzMtMy40NHYtLjA0bDguMzQtOC4zNS4wMS0uMDFjMTMuNzItNi41MSw0Mi45NS0xMS4wMiw3Ni44LTExLjAyczYyLjk3LDQuNDksNzYuNzIsMTFsOC40Miw4LjQyWiIgZmlsbD0idXJsKCNTYW5kVG9wKSIvPjxnIGZpbGw9Im5vbmUiIHN0cm9rZT0idXJsKCNIb3VyZ2xhc3NTdHJva2UpIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgc3Ryb2tlLXdpZHRoPSI0Ij48cGF0aCBkPSJtNTY1LjY0MSwxMDcuMjhjMCw5LjUzNy01LjU2LDE4LjYyOS0xNS42NzYsMjYuOTczaC0uMDIzYy05LjIwNCw3LjU5Ni0yMi4xOTQsMTQuNTYyLTM4LjE5NywyMC41OTItMzkuNTA0LDE0LjkzNi05Ny4zMjUsMjQuMzU1LTE2MS43MzMsMjQuMzU1LTkwLjQ4LDAtMTY3Ljk0OC0xOC41ODItMTk5Ljk1My00NC45NDhoLS4wMjNjLTEwLjExNS04LjM0NC0xNS42NzYtMTcuNDM3LTE1LjY3Ni0yNi45NzMsMC0zOS43MzUsOTYuNTU0LTcxLjkyMSwyMTUuNjUyLTcxLjkyMXMyMTUuNjI5LDMyLjE4NSwyMTUuNjI5LDcxLjkyMVoiLz48cGF0aCBkPSJtMTM0LjM2LDE2MS4yMDNjMCwzOS43MzUsOTYuNTU0LDcxLjkyMSwyMTUuNjUyLDcxLjkyMXMyMTUuNjI5LTMyLjE4NiwyMTUuNjI5LTcxLjkyMSIvPjxsaW5lIHgxPSIxMzQuMzYiIHkxPSIxNjEuMjAzIiB4Mj0iMTM0LjM2IiB5Mj0iMTA3LjI4Ii8+PGxpbmUgeDE9IjU2NS42NCIgeTE9IjE2MS4yMDMiIHgyPSI1NjUuNjQiIHkyPSIxMDcuMjgiLz48bGluZSB4MT0iMTg0LjU4NCIgeTE9IjIwNi44MjMiIHgyPSIxODQuNTg1IiB5Mj0iNTM3LjU3OSIvPjxsaW5lIHgxPSIyMTguMTgxIiB5MT0iMjE4LjExOCIgeDI9IjIxOC4xODEiIHkyPSI1NjIuNTM3Ii8+PGxpbmUgeDE9IjQ4MS44MTgiIHkxPSIyMTguMTQyIiB4Mj0iNDgxLjgxOSIgeTI9IjU2Mi40MjgiLz48bGluZSB4MT0iNTE1LjQxNSIgeTE9IjIwNy4zNTIiIHgyPSI1MTUuNDE2IiB5Mj0iNTM3LjU3OSIvPjxwYXRoIGQ9Im0xODQuNTgsNTM3LjU4YzAsNS40NSw0LjI3LDEwLjY1LDEyLjAzLDE1LjQyaC4wMmM1LjUxLDMuMzksMTIuNzksNi41NSwyMS41NSw5LjQyLDMwLjIxLDkuOSw3OC4wMiwxNi4yOCwxMzEuODMsMTYuMjgsNDkuNDEsMCw5My43Ni01LjM4LDEyNC4wNi0xMy45MiwyLjctLjc2LDUuMjktMS41NCw3Ljc1LTIuMzUsOC43Ny0yLjg3LDE2LjA1LTYuMDQsMjEuNTYtOS40M2gwYzcuNzYtNC43NywxMi4wNC05Ljk3LDEyLjA0LTE1LjQyIi8+PHBhdGggZD0ibTE4NC41ODIsNDkyLjY1NmMtMzEuMzU0LDEyLjQ4NS01MC4yMjMsMjguNTgtNTAuMjIzLDQ2LjE0MiwwLDkuNTM2LDUuNTY0LDE4LjYyNywxNS42NzcsMjYuOTY5aC4wMjJjOC41MDMsNy4wMDUsMjAuMjEzLDEzLjQ2MywzNC41MjQsMTkuMTU5LDkuOTk5LDMuOTkxLDIxLjI2OSw3LjYwOSwzMy41OTcsMTAuNzg4LDM2LjQ1LDkuNDA3LDgyLjE4MSwxNS4wMDIsMTMxLjgzNSwxNS4wMDJzOTUuMzYzLTUuNTk1LDEzMS44MDctMTUuMDAyYzEwLjg0Ny0yLjc5LDIwLjg2Ny01LjkyNiwyOS45MjQtOS4zNDksMS4yNDQtLjQ2NywyLjQ3My0uOTQyLDMuNjczLTEuNDI0LDE0LjMyNi01LjY5NiwyNi4wMzUtMTIuMTYxLDM0LjUyNC0xOS4xNzNoLjAyMmMxMC4xMTQtOC4zNDIsMTUuNjc3LTE3LjQzMywxNS42NzctMjYuOTY5LDAtMTcuNTYyLTE4Ljg2OS0zMy42NjUtNTAuMjIzLTQ2LjE1Ii8+PHBhdGggZD0ibTEzNC4zNiw1OTIuNzJjMCwzOS43MzUsOTYuNTU0LDcxLjkyMSwyMTUuNjUyLDcxLjkyMXMyMTUuNjI5LTMyLjE4NiwyMTUuNjI5LTcxLjkyMSIvPjxsaW5lIHgxPSIxMzQuMzYiIHkxPSI1OTIuNzIiIHgyPSIxMzQuMzYiIHkyPSI1MzguNzk3Ii8+PGxpbmUgeDE9IjU2NS42NCIgeTE9IjU5Mi43MiIgeDI9IjU2NS42NCIgeTI9IjUzOC43OTciLz48cG9seWxpbmUgcG9pbnRzPSI0ODEuODIyIDQ4MS45MDEgNDgxLjc5OCA0ODEuODc3IDQ4MS43NzUgNDgxLjg1NCAzNTAuMDE1IDM1MC4wMjYgMjE4LjE4NSAyMTguMTI5Ii8+PHBvbHlsaW5lIHBvaW50cz0iMjE4LjE4NSA0ODEuOTAxIDIxOC4yMzEgNDgxLjg1NCAzNTAuMDE1IDM1MC4wMjYgNDgxLjgyMiAyMTguMTUyIi8+PC9nPjwvZz48ZyBpZD0iUHJvZ3Jlc3MiIGZpbGw9IiNmZmYiPjxyZWN0IHdpZHRoPSIyMDgiIGhlaWdodD0iMTAwIiBmaWxsLW9wYWNpdHk9Ii4wMyIgcng9IjE1IiByeT0iMTUiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLW9wYWNpdHk9Ii4xIiBzdHJva2Utd2lkdGg9IjQiLz48dGV4dCB4PSIyMCIgeT0iMzQiIGZvbnQtZmFtaWx5PSInQ291cmllciBOZXcnLEFyaWFsLG1vbm9zcGFjZSIgZm9udC1zaXplPSIyMnB4Ij5Qcm9ncmVzczwvdGV4dD48dGV4dCB4PSIyMCIgeT0iNzIiIGZvbnQtZmFtaWx5PSInQ291cmllciBOZXcnLEFyaWFsLG1vbm9zcGFjZSIgZm9udC1zaXplPSIyNnB4Ij4yNSU8L3RleHQ+PGcgZmlsbD0ibm9uZSI+PGNpcmNsZSBjeD0iMTY2IiBjeT0iNTAiIHI9IjIyIiBzdHJva2U9ImhzbCgyMzAsMjElLDExJSkiIHN0cm9rZS13aWR0aD0iMTAiLz48Y2lyY2xlIGN4PSIxNjYiIGN5PSI1MCIgcGF0aExlbmd0aD0iMTAwMDAiIHI9IjIyIiBzdHJva2U9ImhzbCgxOSwyMiUsNjMlKSIgc3Ryb2tlLWRhc2hhcnJheT0iMTAwMDAiIHN0cm9rZS1kYXNob2Zmc2V0PSI3NTAwIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS13aWR0aD0iNSIgdHJhbnNmb3JtPSJyb3RhdGUoLTkwKSIgdHJhbnNmb3JtLW9yaWdpbj0iMTY2IDUwIi8+PC9nPjwvZz48ZyBpZD0iU3RhdHVzIiBmaWxsPSIjZmZmIj48cmVjdCB3aWR0aD0iMTg0IiBoZWlnaHQ9IjEwMCIgZmlsbC1vcGFjaXR5PSIuMDMiIHJ4PSIxNSIgcnk9IjE1IiBzdHJva2U9IiNmZmYiIHN0cm9rZS1vcGFjaXR5PSIuMSIgc3Ryb2tlLXdpZHRoPSI0Ii8+PHRleHQgeD0iMjAiIHk9IjM0IiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMjJweCI+U3RhdHVzPC90ZXh0Pjx0ZXh0IHg9IjIwIiB5PSI3MiIgZm9udC1mYW1pbHk9IidDb3VyaWVyIE5ldycsQXJpYWwsbW9ub3NwYWNlIiBmb250LXNpemU9IjI2cHgiPlN0cmVhbWluZzwvdGV4dD48L2c+PGcgaWQ9IlN0cmVhbWVkIiBmaWxsPSIjZmZmIj48cmVjdCB3aWR0aD0iMTUyIiBoZWlnaHQ9IjEwMCIgZmlsbC1vcGFjaXR5PSIuMDMiIHJ4PSIxNSIgcnk9IjE1IiBzdHJva2U9IiNmZmYiIHN0cm9rZS1vcGFjaXR5PSIuMSIgc3Ryb2tlLXdpZHRoPSI0Ii8+PHRleHQgeD0iMjAiIHk9IjM0IiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMjJweCI+U3RyZWFtZWQ8L3RleHQ+PHRleHQgeD0iMjAiIHk9IjcyIiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMjZweCI+JiM4ODA1OyAyLjUwSzwvdGV4dD48L2c+PGcgaWQ9IkR1cmF0aW9uIiBmaWxsPSIjZmZmIj48cmVjdCB3aWR0aD0iMTUyIiBoZWlnaHQ9IjEwMCIgZmlsbC1vcGFjaXR5PSIuMDMiIHJ4PSIxNSIgcnk9IjE1IiBzdHJva2U9IiNmZmYiIHN0cm9rZS1vcGFjaXR5PSIuMSIgc3Ryb2tlLXdpZHRoPSI0Ii8+PHRleHQgeD0iMjAiIHk9IjM0IiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMjJweCI+RHVyYXRpb248L3RleHQ+PHRleHQgeD0iMjAiIHk9IjcyIiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMjZweCI+Jmx0OyAxIERheTwvdGV4dD48L2c+PC9kZWZzPjx0ZXh0IHRleHQtcmVuZGVyaW5nPSJvcHRpbWl6ZVNwZWVkIj48dGV4dFBhdGggc3RhcnRPZmZzZXQ9Ii0xMDAlIiBocmVmPSIjRmxvYXRpbmdUZXh0IiBmaWxsPSIjZmZmIiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZpbGwtb3BhY2l0eT0iLjgiIGZvbnQtc2l6ZT0iMjZweCIgPjxhbmltYXRlIGFkZGl0aXZlPSJzdW0iIGF0dHJpYnV0ZU5hbWU9InN0YXJ0T2Zmc2V0IiBiZWdpbj0iMHMiIGR1cj0iNTBzIiBmcm9tPSIwJSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHRvPSIxMDAlIi8+MHgzMzgxY2QxOGUyZmI0ZGIyMzZiZjA1MjU5MzhhYjZlNDNkYjA0NDBmIOKAoiBTYWJsaWVyIFYyIExvY2t1cCBMaW5lYXI8L3RleHRQYXRoPjx0ZXh0UGF0aCBzdGFydE9mZnNldD0iMCUiIGhyZWY9IiNGbG9hdGluZ1RleHQiIGZpbGw9IiNmZmYiIGZvbnQtZmFtaWx5PSInQ291cmllciBOZXcnLEFyaWFsLG1vbm9zcGFjZSIgZmlsbC1vcGFjaXR5PSIuOCIgZm9udC1zaXplPSIyNnB4IiA+PGFuaW1hdGUgYWRkaXRpdmU9InN1bSIgYXR0cmlidXRlTmFtZT0ic3RhcnRPZmZzZXQiIGJlZ2luPSIwcyIgZHVyPSI1MHMiIGZyb209IjAlIiByZXBlYXRDb3VudD0iaW5kZWZpbml0ZSIgdG89IjEwMCUiLz4weDMzODFjZDE4ZTJmYjRkYjIzNmJmMDUyNTkzOGFiNmU0M2RiMDQ0MGYg4oCiIFNhYmxpZXIgVjIgTG9ja3VwIExpbmVhcjwvdGV4dFBhdGg+PHRleHRQYXRoIHN0YXJ0T2Zmc2V0PSItNTAlIiBocmVmPSIjRmxvYXRpbmdUZXh0IiBmaWxsPSIjZmZmIiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZpbGwtb3BhY2l0eT0iLjgiIGZvbnQtc2l6ZT0iMjZweCIgPjxhbmltYXRlIGFkZGl0aXZlPSJzdW0iIGF0dHJpYnV0ZU5hbWU9InN0YXJ0T2Zmc2V0IiBiZWdpbj0iMHMiIGR1cj0iNTBzIiBmcm9tPSIwJSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHRvPSIxMDAlIi8+MHgwM2E2YTg0Y2Q3NjJkOTcwN2EyMTYwNWI1NDhhYWFiODkxNTYyYWFiIOKAoiBEQUk8L3RleHRQYXRoPjx0ZXh0UGF0aCBzdGFydE9mZnNldD0iNTAlIiBocmVmPSIjRmxvYXRpbmdUZXh0IiBmaWxsPSIjZmZmIiBmb250LWZhbWlseT0iJ0NvdXJpZXIgTmV3JyxBcmlhbCxtb25vc3BhY2UiIGZpbGwtb3BhY2l0eT0iLjgiIGZvbnQtc2l6ZT0iMjZweCIgPjxhbmltYXRlIGFkZGl0aXZlPSJzdW0iIGF0dHJpYnV0ZU5hbWU9InN0YXJ0T2Zmc2V0IiBiZWdpbj0iMHMiIGR1cj0iNTBzIiBmcm9tPSIwJSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHRvPSIxMDAlIi8+MHgwM2E2YTg0Y2Q3NjJkOTcwN2EyMTYwNWI1NDhhYWFiODkxNTYyYWFiIOKAoiBEQUk8L3RleHRQYXRoPjwvdGV4dD48dXNlIGhyZWY9IiNHbG93IiBmaWxsLW9wYWNpdHk9Ii45Ii8+PHVzZSBocmVmPSIjR2xvdyIgeD0iMTAwMCIgeT0iMTAwMCIgZmlsbC1vcGFjaXR5PSIuOSIvPjx1c2UgaHJlZj0iI0xvZ28iIHg9IjE3MCIgeT0iMTcwIiB0cmFuc2Zvcm09InNjYWxlKC42KSIgLz48dXNlIGhyZWY9IiNIb3VyZ2xhc3MiIHg9IjE1MCIgeT0iOTAiIHRyYW5zZm9ybT0icm90YXRlKDEwKSIgdHJhbnNmb3JtLW9yaWdpbj0iNTAwIDUwMCIvPjx1c2UgaHJlZj0iI1Byb2dyZXNzIiB4PSIxMjgiIHk9Ijc5MCIvPjx1c2UgaHJlZj0iI1N0YXR1cyIgeD0iMzUyIiB5PSI3OTAiLz48dXNlIGhyZWY9IiNTdHJlYW1lZCIgeD0iNTUyIiB5PSI3OTAiLz48dXNlIGhyZWY9IiNEdXJhdGlvbiIgeD0iNzIwIiB5PSI3OTAiLz48L3N2Zz4="}';
        assertEq(actualDecodedTokenURI, expectedDecodedTokenURI, "decoded token URI");
    }

    function test_TokenURI_Full() external skipOnMismatch whenNFTExists {
        string memory actualTokenURI = lockupLinear.tokenURI(defaultStreamId);
        string memory expectedTokenURI =
            "ZGF0YTphcHBsaWNhdGlvbi9qc29uO2Jhc2U2NCx7ImF0dHJpYnV0ZXMiOlt7InRyYWl0X3R5cGUiOiJBc3NldCIsInZhbHVlIjoiREFJIn0seyJ0cmFpdF90eXBlIjoiU2VuZGVyIiwidmFsdWUiOiIweDYzMzJlN2IxZGViMWYxYTBiNzdiMmJiMThiMTQ0MzMwYzcyOTFiY2EifSx7InRyYWl0X3R5cGUiOiJTdGF0dXMiLCJ2YWx1ZSI6IlN0cmVhbWluZyJ9XSwiZGVzY3JpcHRpb24iOiJUaGlzIE5GVCByZXByZXNlbnRzIGEgcGF5bWVudCBzdHJlYW0gaW4gYSBTYWJsaWVyIFYyIExvY2t1cCBMaW5lYXIgY29udHJhY3QuIFRoZSBvd25lciBvZiB0aGlzIE5GVCBjYW4gd2l0aGRyYXcgdGhlIHN0cmVhbWVkIGFzc2V0cywgd2hpY2ggYXJlIGRlbm9taW5hdGVkIGluIERBSS5cblxuLSBTdHJlYW0gSUQ6IDFcbi0gTG9ja3VwIExpbmVhciBBZGRyZXNzOiAweDMzODFjZDE4ZTJmYjRkYjIzNmJmMDUyNTkzOGFiNmU0M2RiMDQ0MGZcbi0gREFJIEFkZHJlc3M6IDB4MDNhNmE4NGNkNzYyZDk3MDdhMjE2MDViNTQ4YWFhYjg5MTU2MmFhYlxuXG7imqDvuI8gV0FSTklORzogVHJhbnNmZXJyaW5nIHRoZSBORlQgbWFrZXMgdGhlIG5ldyBvd25lciB0aGUgcmVjaXBpZW50IG9mIHRoZSBzdHJlYW0uIFRoZSBmdW5kcyBhcmUgbm90IGF1dG9tYXRpY2FsbHkgd2l0aGRyYXduIGZvciB0aGUgcHJldmlvdXMgcmVjaXBpZW50LiIsImV4dGVybmFsX3VybCI6Imh0dHBzOi8vc2FibGllci5jb20iLCJuYW1lIjoiU2FibGllciBWMiBMb2NrdXAgTGluZWFyICMxIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSGRwWkhSb1BTSXhNREF3SWlCb1pXbG5hSFE5SWpFd01EQWlJSFpwWlhkQ2IzZzlJakFnTUNBeE1EQXdJREV3TURBaVBqeHlaV04wSUhkcFpIUm9QU0l4TURBbElpQm9aV2xuYUhROUlqRXdNQ1VpSUdacGJIUmxjajBpZFhKc0tDTk9iMmx6WlNraUx6NDhjbVZqZENCNFBTSTNNQ0lnZVQwaU56QWlJSGRwWkhSb1BTSTROakFpSUdobGFXZG9kRDBpT0RZd0lpQm1hV3hzUFNJalptWm1JaUJtYVd4c0xXOXdZV05wZEhrOUlpNHdNeUlnY25nOUlqUTFJaUJ5ZVQwaU5EVWlJSE4wY205clpUMGlJMlptWmlJZ2MzUnliMnRsTFc5d1lXTnBkSGs5SWk0eElpQnpkSEp2YTJVdGQybGtkR2c5SWpRaUx6NDhaR1ZtY3o0OFkybHlZMnhsSUdsa1BTSkhiRzkzSWlCeVBTSTFNREFpSUdacGJHdzlJblZ5YkNnalVtRmthV0ZzUjJ4dmR5a2lMejQ4Wm1sc2RHVnlJR2xrUFNKT2IybHpaU0krUEdabFJteHZiMlFnZUQwaU1DSWdlVDBpTUNJZ2QybGtkR2c5SWpFd01DVWlJR2hsYVdkb2REMGlNVEF3SlNJZ1pteHZiMlF0WTI5c2IzSTlJbWh6YkNneU16QXNNakVsTERFeEpTa2lJR1pzYjI5a0xXOXdZV05wZEhrOUlqRWlJSEpsYzNWc2REMGlabXh2YjJSR2FXeHNJaTgrUEdabFZIVnlZblZzWlc1alpTQmlZWE5sUm5KbGNYVmxibU41UFNJdU5DSWdiblZ0VDJOMFlYWmxjejBpTXlJZ2NtVnpkV3gwUFNKT2IybHpaU0lnZEhsd1pUMGlabkpoWTNSaGJFNXZhWE5sSWk4K1BHWmxRbXhsYm1RZ2FXNDlJazV2YVhObElpQnBiakk5SW1ac2IyOWtSbWxzYkNJZ2JXOWtaVDBpYzI5bWRDMXNhV2RvZENJdlBqd3ZabWxzZEdWeVBqeHdZWFJvSUdsa1BTSk1iMmR2SWlCbWFXeHNQU0lqWm1abUlpQm1hV3hzTFc5d1lXTnBkSGs5SWk0eElpQmtQU0p0TVRNekxqVTFPU3d4TWpRdU1ETTBZeTB1TURFekxESXVOREV5TFRFdU1EVTVMRFF1T0RRNExUSXVPVEl6TERZdU5EQXlMVEl1TlRVNExERXVPREU1TFRVdU1UWTRMRE11TkRNNUxUY3VPRGc0TERRdU9UazJMVEUwTGpRMExEZ3VNall5TFRNeExqQTBOeXd4TWk0MU5qVXRORGN1TmpjMExERXlMalUyT1MwNExqZzFPQzR3TXpZdE1UY3VPRE00TFRFdU1qY3lMVEkyTGpNeU9DMHpMalkyTXkwNUxqZ3dOaTB5TGpjMk5pMHhPUzR3T0RjdE55NHhNVE10TWpjdU5UWXlMVEV5TGpjM09DMHhNeTQ0TkRJdE9DNHdNalVzT1M0ME5qZ3RNamd1TmpBMkxERTJMakUxTXkwek5TNHlOalZvTUdNeUxqQXpOUzB4TGpnek9DdzBMakkxTWkwekxqVTBOaXcyTGpRMk15MDFMakl5Tkdnd1l6WXVOREk1TFRVdU5qVTFMREUyTGpJeE9DMHlMamd6TlN3eU1DNHpOVGdzTkM0eE55dzBMakUwTXl3MUxqQTFOeXc0TGpneE5pdzVMalkwT1N3eE15NDVNaXd4TXk0M016Um9MakF6TjJNMUxqY3pOaXcyTGpRMk1Td3hOUzR6TlRjdE1pNHlOVE1zT1M0ek9DMDRMalE0TERBc01DMHpMalV4TlMwekxqVXhOUzB6TGpVeE5TMHpMalV4TlMweE1TNDBPUzB4TVM0ME56Z3ROVEl1TmpVMkxUVXlMalkyTkMwMk5DNDRNemN0TmpRdU9ETTNiQzR3TkRrdExqQXpOMk10TVM0M01qVXRNUzQyTURZdE1pNDNNVGt0TXk0NE5EY3RNaTQzTlRFdE5pNHlNRFJvTUdNdExqQTBOaTB5TGpNM05Td3hMakEyTWkwMExqVTRNaXd5TGpjeU5pMDJMakl5T1dnd2JDNHhPRFV0TGpFME9HZ3dZeTR3T1RrdExqQTJNaXd1TWpJeUxTNHhORGdzTGpNM0xTNHlOVGxvTUdNeUxqQTJMVEV1TXpZeUxETXVPVFV4TFRJdU5qSXhMRFl1TURRMExUTXVPRFF5UXpVM0xqYzJNeTB6TGpRM015dzVOeTQzTmkweUxqTTBNU3d4TWpndU5qTTNMREU0TGpNek1tTXhOaTQyTnpFc09TNDVORFl0TWpZdU16UTBMRFUwTGpneE15MHpPQzQyTlRFc05EQXVNVGs1TFRZdU1qazVMVFl1TURrMkxURTRMakEyTXkweE55NDNORE10TVRrdU5qWTRMVEU0TGpneE1TMDJMakF4TmkwMExqQTBOeTB4TXk0d05qRXNOQzQzTnpZdE55NDNOVElzT1M0M05URnNOamd1TWpVMExEWTRMak0zTVdNeExqY3lOQ3d4TGpZd01Td3lMamN4TkN3ekxqZzBMREl1TnpNNExEWXVNVGt5V2lJdlBqeHdZWFJvSUdsa1BTSkdiRzloZEdsdVoxUmxlSFFpSUdacGJHdzlJbTV2Ym1VaUlHUTlJazB4TWpVZ05EVm9OelV3Y3pnd0lEQWdPREFnT0RCMk56VXdjekFnT0RBZ0xUZ3dJRGd3YUMwM05UQnpMVGd3SURBZ0xUZ3dJQzA0TUhZdE56VXdjekFnTFRnd0lEZ3dJQzA0TUNJdlBqeHlZV1JwWVd4SGNtRmthV1Z1ZENCcFpEMGlVbUZrYVdGc1IyeHZkeUkrUEhOMGIzQWdiMlptYzJWMFBTSXdKU0lnYzNSdmNDMWpiMnh2Y2owaWFITnNLREU1TERJeUpTdzJNeVVwSWlCemRHOXdMVzl3WVdOcGRIazlJaTQySWk4K1BITjBiM0FnYjJabWMyVjBQU0l4TURBbElpQnpkRzl3TFdOdmJHOXlQU0pvYzJ3b01qTXdMREl4SlN3eE1TVXBJaUJ6ZEc5d0xXOXdZV05wZEhrOUlqQWlMejQ4TDNKaFpHbGhiRWR5WVdScFpXNTBQanhzYVc1bFlYSkhjbUZrYVdWdWRDQnBaRDBpVTJGdVpGUnZjQ0lnZURFOUlqQWxJaUI1TVQwaU1DVWlQanh6ZEc5d0lHOW1abk5sZEQwaU1DVWlJSE4wYjNBdFkyOXNiM0k5SW1oemJDZ3hPU3d5TWlVc05qTWxLU0l2UGp4emRHOXdJRzltWm5ObGREMGlNVEF3SlNJZ2MzUnZjQzFqYjJ4dmNqMGlhSE5zS0RJek1Dd3lNU1VzTVRFbEtTSXZQand2YkdsdVpXRnlSM0poWkdsbGJuUStQR3hwYm1WaGNrZHlZV1JwWlc1MElHbGtQU0pUWVc1a1FtOTBkRzl0SWlCNE1UMGlNVEF3SlNJZ2VURTlJakV3TUNVaVBqeHpkRzl3SUc5bVpuTmxkRDBpTVRBbElpQnpkRzl3TFdOdmJHOXlQU0pvYzJ3b01qTXdMREl4SlN3eE1TVXBJaTgrUEhOMGIzQWdiMlptYzJWMFBTSXhNREFsSWlCemRHOXdMV052Ykc5eVBTSm9jMndvTVRrc01qSWxMRFl6SlNraUx6NDhZVzVwYldGMFpTQmhkSFJ5YVdKMWRHVk9ZVzFsUFNKNE1TSWdaSFZ5UFNJMmN5SWdjbVZ3WldGMFEyOTFiblE5SW1sdVpHVm1hVzVwZEdVaUlIWmhiSFZsY3owaU16QWxPell3SlRzeE1qQWxPell3SlRzek1DVTdJaTgrUEM5c2FXNWxZWEpIY21Ga2FXVnVkRDQ4YkdsdVpXRnlSM0poWkdsbGJuUWdhV1E5SWtodmRYSm5iR0Z6YzFOMGNtOXJaU0lnWjNKaFpHbGxiblJVY21GdWMyWnZjbTA5SW5KdmRHRjBaU2c1TUNraUlHZHlZV1JwWlc1MFZXNXBkSE05SW5WelpYSlRjR0ZqWlU5dVZYTmxJajQ4YzNSdmNDQnZabVp6WlhROUlqVXdKU0lnYzNSdmNDMWpiMnh2Y2owaWFITnNLREU1TERJeUpTdzJNeVVwSWk4K1BITjBiM0FnYjJabWMyVjBQU0k0TUNVaUlITjBiM0F0WTI5c2IzSTlJbWh6YkNneU16QXNNakVsTERFeEpTa2lMejQ4TDJ4cGJtVmhja2R5WVdScFpXNTBQanhuSUdsa1BTSkliM1Z5WjJ4aGMzTWlQanh3WVhSb0lHUTlJazBnTlRBc016WXdJR0VnTXpBd0xETXdNQ0F3SURFc01TQTJNREFzTUNCaElETXdNQ3d6TURBZ01DQXhMREVnTFRZd01Dd3dJaUJtYVd4c1BTSWpabVptSWlCbWFXeHNMVzl3WVdOcGRIazlJaTR3TWlJZ2MzUnliMnRsUFNKMWNtd29JMGh2ZFhKbmJHRnpjMU4wY205clpTa2lJSE4wY205clpTMTNhV1IwYUQwaU5DSXZQanh3WVhSb0lHUTlJbTAxTmpZc01UWXhMakl3TVhZdE5UTXVPVEkwWXpBdE1Ua3VNemd5TFRJeUxqVXhNeTB6Tnk0MU5qTXROak11TXprNExUVXhMakU1T0MwME1DNDNOVFl0TVRNdU5Ua3lMVGswTGprME5pMHlNUzR3TnprdE1UVXlMalU0TnkweU1TNHdOemx6TFRFeE1TNDRNemdzTnk0ME9EY3RNVFV5TGpZd01pd3lNUzR3TnpsakxUUXdMamc1TXl3eE15NDJNell0TmpNdU5ERXpMRE14TGpneE5pMDJNeTQwTVRNc05URXVNVGs0ZGpVekxqa3lOR013TERFM0xqRTRNU3d4Tnk0M01EUXNNek11TkRJM0xEVXdMakl5TXl3ME5pNHpPVFIyTWpnMExqZ3dPV010TXpJdU5URTVMREV5TGprMkxUVXdMakl5TXl3eU9TNHlNRFl0TlRBdU1qSXpMRFEyTGpNNU5IWTFNeTQ1TWpSak1Dd3hPUzR6T0RJc01qSXVOVElzTXpjdU5UWXpMRFl6TGpReE15dzFNUzR4T1Rnc05EQXVOell6TERFekxqVTVNaXc1TkM0NU5UUXNNakV1TURjNUxERTFNaTQyTURJc01qRXVNRGM1Y3pFeE1TNDRNekV0Tnk0ME9EY3NNVFV5TGpVNE55MHlNUzR3Tnpsak5EQXVPRGcyTFRFekxqWXpOaXcyTXk0ek9UZ3RNekV1T0RFMkxEWXpMak01T0MwMU1TNHhPVGgyTFRVekxqa3lOR013TFRFM0xqRTVOaTB4Tnk0M01EUXRNek11TkRNMUxUVXdMakl5TXkwME5pNDBNREZXTWpBM0xqWXdNMk16TWk0MU1Ua3RNVEl1T1RZM0xEVXdMakl5TXkweU9TNHlNRFlzTlRBdU1qSXpMVFEyTGpRd01WcHRMVE0wTnk0ME5qSXNOVGN1TnpremJERXpNQzQ1TlRrc01UTXhMakF5TnkweE16QXVPVFU1TERFek1TNHdNVE5XTWpFNExqazVORnB0TWpZeUxqa3lOQzR3TWpKMk1qWXlMakF4T0d3dE1UTXdMamt6TnkweE16RXVNREEyTERFek1DNDVNemN0TVRNeExqQXhNMW9pSUdacGJHdzlJaU14TmpFNE1qSWlQand2Y0dGMGFENDhjRzlzZVdkdmJpQndiMmx1ZEhNOUlqTTFNQ0F6TlRBdU1ESTJJRFF4TlM0d015QXlPRFF1T1RjNElESTROU0F5T0RRdU9UYzRJRE0xTUNBek5UQXVNREkySWlCbWFXeHNQU0oxY213b0kxTmhibVJDYjNSMGIyMHBJaTgrUEhCaGRHZ2daRDBpYlRReE5pNHpOREVzTWpneExqazNOV013TEM0NU1UUXRMak0xTkN3eExqZ3dPUzB4TGpBek5Td3lMalk0TFRVdU5UUXlMRGN1TURjMkxUTXlMalkyTVN3eE1pNDBOUzAyTlM0eU9Dd3hNaTQwTlMwek1pNDJNalFzTUMwMU9TNDNNemd0TlM0ek56UXROalV1TWpndE1USXVORFV0TGpZNE1TMHVPRGN5TFRFdU1ETTFMVEV1TnpZM0xURXVNRE0xTFRJdU5qZ3NNQzB1T1RFMExqTTFOQzB4TGpnd09Dd3hMakF6TlMweUxqWTNOaXcxTGpVME1pMDNMakEzTml3ek1pNDJOVFl0TVRJdU5EVXNOalV1TWpndE1USXVORFVzTXpJdU5qRTVMREFzTlRrdU56TTRMRFV1TXpjMExEWTFMakk0TERFeUxqUTFMalk0TVM0NE5qY3NNUzR3TXpVc01TNDNOaklzTVM0d016VXNNaTQyTnpaYUlpQm1hV3hzUFNKMWNtd29JMU5oYm1SVWIzQXBJaTgrUEhCaGRHZ2daRDBpYlRRNE1TNDBOaXcwT0RFdU5UUjJPREV1TURGakxUSXVNelV1TnpjdE5DNDRNaXd4TGpVeExUY3VNemtzTWk0eU15MHpNQzR6TERndU5UUXROelF1TmpVc01UTXVPVEl0TVRJMExqQTJMREV6TGpreUxUVXpMallzTUMweE1ERXVNalF0Tmk0ek15MHhNekV1TkRjdE1UWXVNVFoyTFRneGJEUTJMak10TkRZdU16Rm9NVGN3TGpNemJEUTJMakk1TERRMkxqTXhXaUlnWm1sc2JEMGlkWEpzS0NOVFlXNWtRbTkwZEc5dEtTSXZQanh3WVhSb0lHUTlJbTAwTXpVdU1UY3NORE0xTGpJell6QXNNUzR4TnkwdU5EWXNNaTR6TWkweExqTXpMRE11TkRRdE55NHhNU3c1TGpBNExUUXhMamt6TERFMUxqazRMVGd6TGpneExERTFMams0Y3kwM05pNDNMVFl1T1MwNE15NDRNaTB4TlM0NU9HTXRMamczTFRFdU1USXRNUzR6TXkweUxqSTNMVEV1TXpNdE15NDBOSFl0TGpBMGJEZ3VNelF0T0M0ek5TNHdNUzB1TURGak1UTXVOekl0Tmk0MU1TdzBNaTQ1TlMweE1TNHdNaXczTmk0NExURXhMakF5Y3pZeUxqazNMRFF1TkRrc056WXVOeklzTVRGc09DNDBNaXc0TGpReVdpSWdabWxzYkQwaWRYSnNLQ05UWVc1a1ZHOXdLU0l2UGp4bklHWnBiR3c5SW01dmJtVWlJSE4wY205clpUMGlkWEpzS0NOSWIzVnlaMnhoYzNOVGRISnZhMlVwSWlCemRISnZhMlV0YkdsdVpXTmhjRDBpY205MWJtUWlJSE4wY205clpTMXRhWFJsY214cGJXbDBQU0l4TUNJZ2MzUnliMnRsTFhkcFpIUm9QU0kwSWo0OGNHRjBhQ0JrUFNKdE5UWTFMalkwTVN3eE1EY3VNamhqTUN3NUxqVXpOeTAxTGpVMkxERTRMall5T1MweE5TNDJOellzTWpZdU9UY3phQzB1TURJell5MDVMakl3TkN3M0xqVTVOaTB5TWk0eE9UUXNNVFF1TlRZeUxUTTRMakU1Tnl3eU1DNDFPVEl0TXprdU5UQTBMREUwTGprek5pMDVOeTR6TWpVc01qUXVNelUxTFRFMk1TNDNNek1zTWpRdU16VTFMVGt3TGpRNExEQXRNVFkzTGprME9DMHhPQzQxT0RJdE1UazVMamsxTXkwME5DNDVORGhvTFM0d01qTmpMVEV3TGpFeE5TMDRMak0wTkMweE5TNDJOell0TVRjdU5ETTNMVEUxTGpZM05pMHlOaTQ1TnpNc01DMHpPUzQzTXpVc09UWXVOVFUwTFRjeExqa3lNU3d5TVRVdU5qVXlMVGN4TGpreU1YTXlNVFV1TmpJNUxETXlMakU0TlN3eU1UVXVOakk1TERjeExqa3lNVm9pTHo0OGNHRjBhQ0JrUFNKdE1UTTBMak0yTERFMk1TNHlNRE5qTUN3ek9TNDNNelVzT1RZdU5UVTBMRGN4TGpreU1Td3lNVFV1TmpVeUxEY3hMamt5TVhNeU1UVXVOakk1TFRNeUxqRTROaXd5TVRVdU5qSTVMVGN4TGpreU1TSXZQanhzYVc1bElIZ3hQU0l4TXpRdU16WWlJSGt4UFNJeE5qRXVNakF6SWlCNE1qMGlNVE0wTGpNMklpQjVNajBpTVRBM0xqSTRJaTgrUEd4cGJtVWdlREU5SWpVMk5TNDJOQ0lnZVRFOUlqRTJNUzR5TURNaUlIZ3lQU0kxTmpVdU5qUWlJSGt5UFNJeE1EY3VNamdpTHo0OGJHbHVaU0I0TVQwaU1UZzBMalU0TkNJZ2VURTlJakl3Tmk0NE1qTWlJSGd5UFNJeE9EUXVOVGcxSWlCNU1qMGlOVE0zTGpVM09TSXZQanhzYVc1bElIZ3hQU0l5TVRndU1UZ3hJaUI1TVQwaU1qRTRMakV4T0NJZ2VESTlJakl4T0M0eE9ERWlJSGt5UFNJMU5qSXVOVE0zSWk4K1BHeHBibVVnZURFOUlqUTRNUzQ0TVRnaUlIa3hQU0l5TVRndU1UUXlJaUI0TWowaU5EZ3hMamd4T1NJZ2VUSTlJalUyTWk0ME1qZ2lMejQ4YkdsdVpTQjRNVDBpTlRFMUxqUXhOU0lnZVRFOUlqSXdOeTR6TlRJaUlIZ3lQU0kxTVRVdU5ERTJJaUI1TWowaU5UTTNMalUzT1NJdlBqeHdZWFJvSUdROUltMHhPRFF1TlRnc05UTTNMalU0WXpBc05TNDBOU3cwTGpJM0xERXdMalkxTERFeUxqQXpMREUxTGpReWFDNHdNbU0xTGpVeExETXVNemtzTVRJdU56a3NOaTQxTlN3eU1TNDFOU3c1TGpReUxETXdMakl4TERrdU9TdzNPQzR3TWl3eE5pNHlPQ3d4TXpFdU9ETXNNVFl1TWpnc05Ea3VOREVzTUN3NU15NDNOaTAxTGpNNExERXlOQzR3TmkweE15NDVNaXd5TGpjdExqYzJMRFV1TWprdE1TNDFOQ3czTGpjMUxUSXVNelVzT0M0M055MHlMamczTERFMkxqQTFMVFl1TURRc01qRXVOVFl0T1M0ME0yZ3dZemN1TnpZdE5DNDNOeXd4TWk0d05DMDVMamszTERFeUxqQTBMVEUxTGpReUlpOCtQSEJoZEdnZ1pEMGliVEU0TkM0MU9ESXNORGt5TGpZMU5tTXRNekV1TXpVMExERXlMalE0TlMwMU1DNHlNak1zTWpndU5UZ3ROVEF1TWpJekxEUTJMakUwTWl3d0xEa3VOVE0yTERVdU5UWTBMREU0TGpZeU55d3hOUzQyTnpjc01qWXVPVFk1YUM0d01qSmpPQzQxTURNc055NHdNRFVzTWpBdU1qRXpMREV6TGpRMk15d3pOQzQxTWpRc01Ua3VNVFU1TERrdU9UazVMRE11T1RreExESXhMakkyT1N3M0xqWXdPU3d6TXk0MU9UY3NNVEF1TnpnNExETTJMalExTERrdU5EQTNMRGd5TGpFNE1Td3hOUzR3TURJc01UTXhMamd6TlN3eE5TNHdNREp6T1RVdU16WXpMVFV1TlRrMUxERXpNUzQ0TURjdE1UVXVNREF5WXpFd0xqZzBOeTB5TGpjNUxESXdMamcyTnkwMUxqa3lOaXd5T1M0NU1qUXRPUzR6TkRrc01TNHlORFF0TGpRMk55d3lMalEzTXkwdU9UUXlMRE11TmpjekxURXVOREkwTERFMExqTXlOaTAxTGpZNU5pd3lOaTR3TXpVdE1USXVNVFl4TERNMExqVXlOQzB4T1M0eE56Tm9MakF5TW1NeE1DNHhNVFF0T0M0ek5ESXNNVFV1TmpjM0xURTNMalF6TXl3eE5TNDJOemN0TWpZdU9UWTVMREF0TVRjdU5UWXlMVEU0TGpnMk9TMHpNeTQyTmpVdE5UQXVNakl6TFRRMkxqRTFJaTgrUEhCaGRHZ2daRDBpYlRFek5DNHpOaXcxT1RJdU56SmpNQ3d6T1M0M016VXNPVFl1TlRVMExEY3hMamt5TVN3eU1UVXVOalV5TERjeExqa3lNWE15TVRVdU5qSTVMVE15TGpFNE5pd3lNVFV1TmpJNUxUY3hMamt5TVNJdlBqeHNhVzVsSUhneFBTSXhNelF1TXpZaUlIa3hQU0kxT1RJdU56SWlJSGd5UFNJeE16UXVNellpSUhreVBTSTFNemd1TnprM0lpOCtQR3hwYm1VZ2VERTlJalUyTlM0Mk5DSWdlVEU5SWpVNU1pNDNNaUlnZURJOUlqVTJOUzQyTkNJZ2VUSTlJalV6T0M0M09UY2lMejQ4Y0c5c2VXeHBibVVnY0c5cGJuUnpQU0kwT0RFdU9ESXlJRFE0TVM0NU1ERWdORGd4TGpjNU9DQTBPREV1T0RjM0lEUTRNUzQzTnpVZ05EZ3hMamcxTkNBek5UQXVNREUxSURNMU1DNHdNallnTWpFNExqRTROU0F5TVRndU1USTVJaTgrUEhCdmJIbHNhVzVsSUhCdmFXNTBjejBpTWpFNExqRTROU0EwT0RFdU9UQXhJREl4T0M0eU16RWdORGd4TGpnMU5DQXpOVEF1TURFMUlETTFNQzR3TWpZZ05EZ3hMamd5TWlBeU1UZ3VNVFV5SWk4K1BDOW5Qand2Wno0OFp5QnBaRDBpVUhKdlozSmxjM01pSUdacGJHdzlJaU5tWm1ZaVBqeHlaV04wSUhkcFpIUm9QU0l5TURnaUlHaGxhV2RvZEQwaU1UQXdJaUJtYVd4c0xXOXdZV05wZEhrOUlpNHdNeUlnY25nOUlqRTFJaUJ5ZVQwaU1UVWlJSE4wY205clpUMGlJMlptWmlJZ2MzUnliMnRsTFc5d1lXTnBkSGs5SWk0eElpQnpkSEp2YTJVdGQybGtkR2c5SWpRaUx6NDhkR1Y0ZENCNFBTSXlNQ0lnZVQwaU16UWlJR1p2Ym5RdFptRnRhV3g1UFNJblEyOTFjbWxsY2lCT1pYY25MRUZ5YVdGc0xHMXZibTl6Y0dGalpTSWdabTl1ZEMxemFYcGxQU0l5TW5CNElqNVFjbTluY21WemN6d3ZkR1Y0ZEQ0OGRHVjRkQ0I0UFNJeU1DSWdlVDBpTnpJaUlHWnZiblF0Wm1GdGFXeDVQU0luUTI5MWNtbGxjaUJPWlhjbkxFRnlhV0ZzTEcxdmJtOXpjR0ZqWlNJZ1ptOXVkQzF6YVhwbFBTSXlObkI0SWo0eU5TVThMM1JsZUhRK1BHY2dabWxzYkQwaWJtOXVaU0krUEdOcGNtTnNaU0JqZUQwaU1UWTJJaUJqZVQwaU5UQWlJSEk5SWpJeUlpQnpkSEp2YTJVOUltaHpiQ2d5TXpBc01qRWxMREV4SlNraUlITjBjbTlyWlMxM2FXUjBhRDBpTVRBaUx6NDhZMmx5WTJ4bElHTjRQU0l4TmpZaUlHTjVQU0kxTUNJZ2NHRjBhRXhsYm1kMGFEMGlNVEF3TURBaUlISTlJakl5SWlCemRISnZhMlU5SW1oemJDZ3hPU3d5TWlVc05qTWxLU0lnYzNSeWIydGxMV1JoYzJoaGNuSmhlVDBpTVRBd01EQWlJSE4wY205clpTMWtZWE5vYjJabWMyVjBQU0kzTlRBd0lpQnpkSEp2YTJVdGJHbHVaV05oY0QwaWNtOTFibVFpSUhOMGNtOXJaUzEzYVdSMGFEMGlOU0lnZEhKaGJuTm1iM0p0UFNKeWIzUmhkR1VvTFRrd0tTSWdkSEpoYm5ObWIzSnRMVzl5YVdkcGJqMGlNVFkySURVd0lpOCtQQzluUGp3dlp6NDhaeUJwWkQwaVUzUmhkSFZ6SWlCbWFXeHNQU0lqWm1abUlqNDhjbVZqZENCM2FXUjBhRDBpTVRnMElpQm9aV2xuYUhROUlqRXdNQ0lnWm1sc2JDMXZjR0ZqYVhSNVBTSXVNRE1pSUhKNFBTSXhOU0lnY25rOUlqRTFJaUJ6ZEhKdmEyVTlJaU5tWm1ZaUlITjBjbTlyWlMxdmNHRmphWFI1UFNJdU1TSWdjM1J5YjJ0bExYZHBaSFJvUFNJMElpOCtQSFJsZUhRZ2VEMGlNakFpSUhrOUlqTTBJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXhCY21saGJDeHRiMjV2YzNCaFkyVWlJR1p2Ym5RdGMybDZaVDBpTWpKd2VDSStVM1JoZEhWelBDOTBaWGgwUGp4MFpYaDBJSGc5SWpJd0lpQjVQU0kzTWlJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc1FYSnBZV3dzYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqSTJjSGdpUGxOMGNtVmhiV2x1Wnp3dmRHVjRkRDQ4TDJjK1BHY2dhV1E5SWxOMGNtVmhiV1ZrSWlCbWFXeHNQU0lqWm1abUlqNDhjbVZqZENCM2FXUjBhRDBpTVRVeUlpQm9aV2xuYUhROUlqRXdNQ0lnWm1sc2JDMXZjR0ZqYVhSNVBTSXVNRE1pSUhKNFBTSXhOU0lnY25rOUlqRTFJaUJ6ZEhKdmEyVTlJaU5tWm1ZaUlITjBjbTlyWlMxdmNHRmphWFI1UFNJdU1TSWdjM1J5YjJ0bExYZHBaSFJvUFNJMElpOCtQSFJsZUhRZ2VEMGlNakFpSUhrOUlqTTBJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXhCY21saGJDeHRiMjV2YzNCaFkyVWlJR1p2Ym5RdGMybDZaVDBpTWpKd2VDSStVM1J5WldGdFpXUThMM1JsZUhRK1BIUmxlSFFnZUQwaU1qQWlJSGs5SWpjeUlpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5eEJjbWxoYkN4dGIyNXZjM0JoWTJVaUlHWnZiblF0YzJsNlpUMGlNalp3ZUNJK0ppTTRPREExT3lBeUxqVXdTend2ZEdWNGRENDhMMmMrUEdjZ2FXUTlJa1IxY21GMGFXOXVJaUJtYVd4c1BTSWpabVptSWo0OGNtVmpkQ0IzYVdSMGFEMGlNVFV5SWlCb1pXbG5hSFE5SWpFd01DSWdabWxzYkMxdmNHRmphWFI1UFNJdU1ETWlJSEo0UFNJeE5TSWdjbms5SWpFMUlpQnpkSEp2YTJVOUlpTm1abVlpSUhOMGNtOXJaUzF2Y0dGamFYUjVQU0l1TVNJZ2MzUnliMnRsTFhkcFpIUm9QU0kwSWk4K1BIUmxlSFFnZUQwaU1qQWlJSGs5SWpNMElpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5eEJjbWxoYkN4dGIyNXZjM0JoWTJVaUlHWnZiblF0YzJsNlpUMGlNakp3ZUNJK1JIVnlZWFJwYjI0OEwzUmxlSFErUEhSbGVIUWdlRDBpTWpBaUlIazlJamN5SWlCbWIyNTBMV1poYldsc2VUMGlKME52ZFhKcFpYSWdUbVYzSnl4QmNtbGhiQ3h0YjI1dmMzQmhZMlVpSUdadmJuUXRjMmw2WlQwaU1qWndlQ0krSm14ME95QXhJRVJoZVR3dmRHVjRkRDQ4TDJjK1BDOWtaV1p6UGp4MFpYaDBJSFJsZUhRdGNtVnVaR1Z5YVc1blBTSnZjSFJwYldsNlpWTndaV1ZrSWo0OGRHVjRkRkJoZEdnZ2MzUmhjblJQWm1aelpYUTlJaTB4TURBbElpQm9jbVZtUFNJalJteHZZWFJwYm1kVVpYaDBJaUJtYVd4c1BTSWpabVptSWlCbWIyNTBMV1poYldsc2VUMGlKME52ZFhKcFpYSWdUbVYzSnl4QmNtbGhiQ3h0YjI1dmMzQmhZMlVpSUdacGJHd3RiM0JoWTJsMGVUMGlMamdpSUdadmJuUXRjMmw2WlQwaU1qWndlQ0lnUGp4aGJtbHRZWFJsSUdGa1pHbDBhWFpsUFNKemRXMGlJR0YwZEhKcFluVjBaVTVoYldVOUluTjBZWEowVDJabWMyVjBJaUJpWldkcGJqMGlNSE1pSUdSMWNqMGlOVEJ6SWlCbWNtOXRQU0l3SlNJZ2NtVndaV0YwUTI5MWJuUTlJbWx1WkdWbWFXNXBkR1VpSUhSdlBTSXhNREFsSWk4K01IZ3pNemd4WTJReE9HVXlabUkwWkdJeU16WmlaakExTWpVNU16aGhZalpsTkROa1lqQTBOREJtSU9LQW9pQlRZV0pzYVdWeUlGWXlJRXh2WTJ0MWNDQk1hVzVsWVhJOEwzUmxlSFJRWVhSb1BqeDBaWGgwVUdGMGFDQnpkR0Z5ZEU5bVpuTmxkRDBpTUNVaUlHaHlaV1k5SWlOR2JHOWhkR2x1WjFSbGVIUWlJR1pwYkd3OUlpTm1abVlpSUdadmJuUXRabUZ0YVd4NVBTSW5RMjkxY21sbGNpQk9aWGNuTEVGeWFXRnNMRzF2Ym05emNHRmpaU0lnWm1sc2JDMXZjR0ZqYVhSNVBTSXVPQ0lnWm05dWRDMXphWHBsUFNJeU5uQjRJaUErUEdGdWFXMWhkR1VnWVdSa2FYUnBkbVU5SW5OMWJTSWdZWFIwY21saWRYUmxUbUZ0WlQwaWMzUmhjblJQWm1aelpYUWlJR0psWjJsdVBTSXdjeUlnWkhWeVBTSTFNSE1pSUdaeWIyMDlJakFsSWlCeVpYQmxZWFJEYjNWdWREMGlhVzVrWldacGJtbDBaU0lnZEc4OUlqRXdNQ1VpTHo0d2VETXpPREZqWkRFNFpUSm1ZalJrWWpJek5tSm1NRFV5TlRrek9HRmlObVUwTTJSaU1EUTBNR1lnNG9DaUlGTmhZbXhwWlhJZ1ZqSWdURzlqYTNWd0lFeHBibVZoY2p3dmRHVjRkRkJoZEdnK1BIUmxlSFJRWVhSb0lITjBZWEowVDJabWMyVjBQU0l0TlRBbElpQm9jbVZtUFNJalJteHZZWFJwYm1kVVpYaDBJaUJtYVd4c1BTSWpabVptSWlCbWIyNTBMV1poYldsc2VUMGlKME52ZFhKcFpYSWdUbVYzSnl4QmNtbGhiQ3h0YjI1dmMzQmhZMlVpSUdacGJHd3RiM0JoWTJsMGVUMGlMamdpSUdadmJuUXRjMmw2WlQwaU1qWndlQ0lnUGp4aGJtbHRZWFJsSUdGa1pHbDBhWFpsUFNKemRXMGlJR0YwZEhKcFluVjBaVTVoYldVOUluTjBZWEowVDJabWMyVjBJaUJpWldkcGJqMGlNSE1pSUdSMWNqMGlOVEJ6SWlCbWNtOXRQU0l3SlNJZ2NtVndaV0YwUTI5MWJuUTlJbWx1WkdWbWFXNXBkR1VpSUhSdlBTSXhNREFsSWk4K01IZ3dNMkUyWVRnMFkyUTNOakprT1Rjd04yRXlNVFl3TldJMU5EaGhZV0ZpT0RreE5UWXlZV0ZpSU9LQW9pQkVRVWs4TDNSbGVIUlFZWFJvUGp4MFpYaDBVR0YwYUNCemRHRnlkRTltWm5ObGREMGlOVEFsSWlCb2NtVm1QU0lqUm14dllYUnBibWRVWlhoMElpQm1hV3hzUFNJalptWm1JaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXhCY21saGJDeHRiMjV2YzNCaFkyVWlJR1pwYkd3dGIzQmhZMmwwZVQwaUxqZ2lJR1p2Ym5RdGMybDZaVDBpTWpad2VDSWdQanhoYm1sdFlYUmxJR0ZrWkdsMGFYWmxQU0p6ZFcwaUlHRjBkSEpwWW5WMFpVNWhiV1U5SW5OMFlYSjBUMlptYzJWMElpQmlaV2RwYmowaU1ITWlJR1IxY2owaU5UQnpJaUJtY205dFBTSXdKU0lnY21Wd1pXRjBRMjkxYm5ROUltbHVaR1ZtYVc1cGRHVWlJSFJ2UFNJeE1EQWxJaTgrTUhnd00yRTJZVGcwWTJRM05qSmtPVGN3TjJFeU1UWXdOV0kxTkRoaFlXRmlPRGt4TlRZeVlXRmlJT0tBb2lCRVFVazhMM1JsZUhSUVlYUm9Qand2ZEdWNGRENDhkWE5sSUdoeVpXWTlJaU5IYkc5M0lpQm1hV3hzTFc5d1lXTnBkSGs5SWk0NUlpOCtQSFZ6WlNCb2NtVm1QU0lqUjJ4dmR5SWdlRDBpTVRBd01DSWdlVDBpTVRBd01DSWdabWxzYkMxdmNHRmphWFI1UFNJdU9TSXZQangxYzJVZ2FISmxaajBpSTB4dloyOGlJSGc5SWpFM01DSWdlVDBpTVRjd0lpQjBjbUZ1YzJadmNtMDlJbk5qWVd4bEtDNDJLU0lnTHo0OGRYTmxJR2h5WldZOUlpTkliM1Z5WjJ4aGMzTWlJSGc5SWpFMU1DSWdlVDBpT1RBaUlIUnlZVzV6Wm05eWJUMGljbTkwWVhSbEtERXdLU0lnZEhKaGJuTm1iM0p0TFc5eWFXZHBiajBpTlRBd0lEVXdNQ0l2UGp4MWMyVWdhSEpsWmowaUkxQnliMmR5WlhOeklpQjRQU0l4TWpnaUlIazlJamM1TUNJdlBqeDFjMlVnYUhKbFpqMGlJMU4wWVhSMWN5SWdlRDBpTXpVeUlpQjVQU0kzT1RBaUx6NDhkWE5sSUdoeVpXWTlJaU5UZEhKbFlXMWxaQ0lnZUQwaU5UVXlJaUI1UFNJM09UQWlMejQ4ZFhObElHaHlaV1k5SWlORWRYSmhkR2x2YmlJZ2VEMGlOekl3SWlCNVBTSTNPVEFpTHo0OEwzTjJaejQ9In0=";
        assertEq(actualTokenURI, expectedTokenURI, "token URI");
    }
}
