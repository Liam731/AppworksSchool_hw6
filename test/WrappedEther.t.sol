// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";
import {WrappedEther} from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(address indexed owner, address indexed spender, uint256 amount);

    WrappedEther public we;
    address user1;
    address user2;
    address user3;

    function setUp() public {
        we = new WrappedEther();
        user1 = makeAddr("Liam");
        user2 = makeAddr("Bob");
        user3 = makeAddr("Dora");
    }

    function testDeposit01() public {

        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        (bool isBalanceOf,bytes memory value) = address(we).call(abi.encodeWithSignature("balanceOf(address)", user1));
        require(isBalanceOf);
        uint256 userBalance = abi.decode(value,(uint256));

        assertEq(userBalance, 15 ether);

        vm.stopPrank();
    }

    function testDeposit02() public {

        uint256 beforeContractBalance = we.totalSupply();
        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        uint256 afterContractBalance = we.totalSupply();
        assertEq(afterContractBalance - beforeContractBalance, 15 ether);

        vm.stopPrank();
    }

    function testDeposit03() public {

        startHoax(user1, 100 ether);

        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, 15 ether);
        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        vm.stopPrank();
    }

    function testWithdraw04() public {

        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        uint256 beforeContractBalance = we.totalSupply();

        bool isWithdraw = we.withdraw(5 ether);
        require(isWithdraw);

        uint256 afterContractBalance = we.totalSupply();
        
        assertEq(beforeContractBalance - afterContractBalance, 5 ether);

        vm.stopPrank();
    }

    function testWithdraw05() public {

        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        uint256 beforeUserBalance = user1.balance;
        bool isWithdraw = we.withdraw(5 ether);
        require(isWithdraw);
        uint256 afterUserBalance = user1.balance;
        
        assertEq(afterUserBalance - beforeUserBalance, 5 ether);

        vm.stopPrank();
    }

    function testWithdraw06() public {

        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        vm.expectEmit(true,false,false,true);
        emit Withdraw(user1, 5 ether);
        bool isWithdraw = we.withdraw(5 ether);
        require(isWithdraw);

        vm.stopPrank();
    }

    function testTransfer07() public {

        startHoax(user1, 30 ether);
        (bool isDeposit1,) = address(we).call{value: 30 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit1);
 
        uint256 tBeforeUser1Balance = we.balanceOf(user1);
        uint256 tBeforeUser2Balance = we.balanceOf(user2);
        vm.expectEmit(true,true,false,true);
        emit Transfer(user1, user2, 3 ether);
        (bool isTransfer,) = address(we).call(abi.encodeWithSignature("transfer(address,uint256)", user2, 3 ether));
        require(isTransfer);
        uint256 tAfterUser1Balance = we.balanceOf(user1);
        uint256 tAfterUser2Balance = we.balanceOf(user2);
        
        assertEq(tBeforeUser1Balance - tAfterUser1Balance, 3 ether);
        assertEq(tAfterUser2Balance - tBeforeUser2Balance, 3 ether);

        vm.stopPrank();
    }

    function testApprove08() public {

        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 30 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);
        bool isApprove = we.approve(user2, 20 ether);
        require(isApprove);
        uint256 beforeAllowance = we.allowance(user1, user2);

        assertEq(beforeAllowance, 20 ether);

        vm.stopPrank();
    }

    function testTransferFrom09() public {

        startHoax(user1, 100 ether);

        (bool isDeposit,) = address(we).call{value: 30 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);
        bool isApprove = we.approve(user2, 20 ether);
        require(isApprove);

        vm.stopPrank();

        vm.startPrank(user2);

        bool isTransferFrom = we.transferFrom(user1, user3, 8 ether);
        assertEq(isTransferFrom, true);

        vm.stopPrank();
    }

    function testTransferFrom10() public {

        startHoax(user1, 100 ether);
        (bool isDeposit,) = address(we).call{value: 30 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);
        bool isApprove = we.approve(user2, 20 ether);
        require(isApprove);
        uint256 beforeAllowance = we.allowance(user1, user2);

        vm.stopPrank();

        vm.startPrank(user2);
        bool isTansferFrom = we.transferFrom(user1, user3, 8 ether);
        require(isTansferFrom);
        uint256 afterAllowance = we.allowance(user1, user2);
        assertEq(beforeAllowance - afterAllowance, 8 ether);

        vm.stopPrank();
    }

}
