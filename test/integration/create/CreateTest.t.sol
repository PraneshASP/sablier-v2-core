// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { SD1x18 } from "@prb/math/SD1x18.sol";
import { Solarray } from "solarray/Solarray.sol";

import { DataTypes } from "src/libraries/DataTypes.sol";

import { IntegrationTest } from "../IntegrationTest.t.sol";

abstract contract CreateTest is IntegrationTest {
    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();

        // Make the token holder the caller in this test suite.
        vm.startPrank({ msgSender: holder() });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev it should create the linear stream.
    function testCreateLinear(
        address sender,
        address recipient,
        uint128 depositAmount,
        uint40 startTime,
        uint40 cliffTime,
        uint40 stopTime,
        bool isCancelable
    ) external {
        vm.assume(sender != address(0));
        vm.assume(recipient != address(0));
        vm.assume(depositAmount > 0);
        vm.assume(depositAmount <= IERC20(token()).balanceOf(holder()));
        vm.assume(startTime <= cliffTime);
        vm.assume(cliffTime <= stopTime);

        // Pull the next stream id.
        uint256 expectedStreamId = linear.nextStreamId();

        // Create the stream.
        uint256 actualStreamId = linear.create(
            sender,
            recipient,
            depositAmount,
            token(),
            isCancelable,
            startTime,
            cliffTime,
            stopTime
        );

        // Declare the expected stream struct.
        DataTypes.LinearStream memory stream = DataTypes.LinearStream({
            cliffTime: cliffTime,
            depositAmount: depositAmount,
            isCancelable: cancelable,
            isEntity: true,
            sender: sender,
            startTime: startTime,
            stopTime: stopTime,
            token: token(),
            withdrawnAmount: 0
        });

        // Run the tests.
        assertEq(actualStreamId, expectedStreamId);
        assertEq(linear.nextStreamId(), expectedStreamId + 1);
        assertEq(linear.getStream(actualStreamId), stream);
        assertEq(linear.getRecipient(actualStreamId), recipient);
    }

    /// @dev it should create the pro stream.
    function testCreatePro(
        address sender,
        address recipient,
        uint128 depositAmount,
        uint40 startTime,
        uint40 stopTime,
        SD1x18 exponent,
        bool isCancelable
    ) external {
        vm.assume(sender != address(0));
        vm.assume(recipient != address(0));
        vm.assume(depositAmount > 0);
        vm.assume(depositAmount <= IERC20(token()).balanceOf(holder()));
        vm.assume(startTime > 0); // needed for the segments to be ordered
        vm.assume(startTime <= stopTime);

        SD1x18[] memory segmentExponents = Solarray.SD1x18s(exponent);
        uint128[] memory segmentAmounts = Solarray.uint128s(depositAmount);
        uint40[] memory segmentMilestones = Solarray.uint40s(stopTime);

        // Pull the next stream id.
        uint256 expectedStreamId = pro.nextStreamId();

        // Create the stream.
        uint256 actualStreamId = pro.create(
            sender,
            recipient,
            depositAmount,
            token(),
            isCancelable,
            startTime,
            segmentAmounts,
            segmentExponents,
            segmentMilestones
        );

        // Declare the expected stream struct.
        DataTypes.ProStream memory expectedStream = DataTypes.ProStream({
            depositAmount: depositAmount,
            isCancelable: cancelable,
            isEntity: true,
            segmentAmounts: segmentAmounts,
            segmentExponents: segmentExponents,
            segmentMilestones: segmentMilestones,
            sender: sender,
            startTime: startTime,
            stopTime: stopTime,
            token: token(),
            withdrawnAmount: 0
        });

        // Run the tests.
        assertEq(actualStreamId, expectedStreamId);
        assertEq(pro.nextStreamId(), expectedStreamId + 1);
        assertEq(pro.getStream(actualStreamId), expectedStream);
        assertEq(pro.getRecipient(actualStreamId), recipient);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to approve the Sablier V2 contracts to spend tokens.
    function approveSablierV2() internal {
        IERC20(token()).approve({ spender: address(linear), value: UINT256_MAX });
        IERC20(token()).approve({ spender: address(pro), value: UINT256_MAX });
    }

    /// @dev Helper function to return the token holder's address.
    function holder() internal pure virtual returns (address);

    /// @dev Helper function to return the token address.
    function token() internal pure virtual returns (address);
}
