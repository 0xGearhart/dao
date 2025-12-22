// SPDX-License-Identifier: MIT

import {CodeConstants} from "../../script/HelperConfig.s.sol";
import {DaoToken} from "../../src/DaoToken.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.27;

contract DaoTokenTest is Test {
    DaoToken public daoToken;
    address USER = makeAddr("user");

    function setUp() public {
        daoToken = new DaoToken(TOKEN_NAME, TOKEN_SYMBOL, INITIAL_SUPPLY);
    }
}
