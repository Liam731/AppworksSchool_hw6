// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";
import {WrappedEther} from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(address indexed spender, uint256 amount);

    WrappedEther public we;
    address user1;
    address user2;

    function setUp() public {
        we = new WrappedEther();
        user1 = makeAddr("Liam");
        user2 = makeAddr("Bob");
    }

    function testDepositAndWithdraw() public {
        //deposit test
        uint256 beforeContractBalance = we.totalSupply();
        startHoax(user1, 100 ether);

        vm.expectEmit(true, false, false, true); //test03
        emit Deposit(user1, 15 ether);
        (bool isDeposit,) = address(we).call{value: 15 ether}(abi.encodeWithSignature("deposit(address)", user1));
        require(isDeposit);

        (bool isBalanceOf,bytes memory value) = address(we).call(abi.encodeWithSignature("balanceOf(address)", user1));
        require(isBalanceOf);
        uint256 userBalance = abi.decode(value,(uint256));
        assertEq(userBalance, 15 ether); //test01

        uint256 afterContractBalance = we.totalSupply();
        assertEq(afterContractBalance - beforeContractBalance, 15 ether); //test02

        //withdraw test
        uint256 beforeUserBalance = user1.balance;
        beforeContractBalance = we.totalSupply();
        vm.expectEmit(true,false,false,true); //test06
        emit Withdraw(user1, 5 ether);
        (bool isWithdraw,) = address(we).call(abi.encodeWithSignature("withdraw(uint256)", 5 ether));
        require(isWithdraw);
        uint256 afterUserBalance = user1.balance;
        afterContractBalance = we.totalSupply();
        
        assertEq(beforeContractBalance - afterContractBalance, 5 ether); //test04
        assertEq(afterUserBalance - beforeUserBalance, 5 ether); //test05

        vm.stopPrank();
    }

    function testTransfer() public {

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
        assertEq(tAfterUser2Balance - tBeforeUser2Balance, 3 ether); //test07

        vm.stopPrank();
    }

    function testApproveAndTansferfrom() public {
        //approve test
        startHoax(user1, 100 ether);
        vm.expectEmit(true,false,false,true);
        emit Approve(user2, 20 ether);
        (bool isApprove,) = address(we).call(abi.encodeWithSignature("approve(address,uint256)", user2, 20 ether));
        require(isApprove);
        

        vm.stopPrank();
    }
}
