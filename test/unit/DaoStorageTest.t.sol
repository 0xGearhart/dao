// SPDX-License-Identifier: MIT

import {DaoStorage} from "../../src/DaoStorage.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.27;

contract DaoStorageTest is Test {
    DaoStorage public daoStorage;

    address USER = makeAddr("user");
    address OWNER = DEFAULT_SENDER;

    function setUp() public {
        daoStorage = new DaoStorage(OWNER);
    }
}
