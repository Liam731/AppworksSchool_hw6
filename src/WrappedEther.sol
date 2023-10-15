// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IERC20 {

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address account, uint256 value) external returns (bool);
    function burn(address account, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract WrappedEther is IERC20 {

    string _name;
    string _symbol;
    address _owner;
    uint _totalSupply;
    mapping(address => uint) _balance;
    mapping(address => mapping(address => uint)) _allowance;

     constructor(){ 
        _name = "Wrapped Ether";
        _symbol = "WETH";
        _owner = msg.sender;

        _balance[msg.sender] = 10 ether;
        _totalSupply = 10 ether;       
     }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }

    function deposit(address account) external payable returns(bool){
        require(account != address(0), "ERROR: mint to address 0");
        _totalSupply += msg.value;
        _balance[account] += msg.value;
        emit Deposit(account, msg.value);
        return true;
    }
    function withdraw(uint256 _amount) external returns(bool){
        burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
        return true;
    }

    function mint(address account, uint256 amount) public returns(bool){
        require(account != address(0), "ERROR: mint to address 0");
        _totalSupply += amount;
        _balance[account] += amount;
        emit Transfer(address(0), account, amount);
        return true;
    }

    function burn(address account, uint256 amount) public returns(bool){
        require(account != address(0), "ERROR: burn from address 0");
        uint256 accountBalance = _balance[account];
        require(accountBalance >= amount, "ERROR: no more token to burn");
        _balance[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        return true;
    }
    
    function totalSupply() external view returns(uint){
        return _totalSupply;
    }

    function balanceOf(address account) external view returns(uint){
        return _balance[account];
    }

    function transfer(address to, uint amount) external returns(bool){
        uint senderBalance = _balance[msg.sender];
        require(senderBalance >= amount, "ERROR: Not enough token");

        _balance[msg.sender] = senderBalance - amount;
        _balance[to] = _balance[to] + amount;
        emit Transfer(msg.sender, to, amount);

        return true;
    } 

    function approve(address spender, uint amount) external returns(bool){
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns(uint){
        return _allowance[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 myAllowance = _allowance[from][msg.sender];
        require(myAllowance >= amount, "ERROR: myAllowance < amount");
        _allowance[from][msg.sender] = myAllowance - amount;
        emit Approval(from, msg.sender, myAllowance - amount);

        uint fromBalance = _balance[from];
        require(fromBalance >= amount, "ERROR: fromBalance < amount");
        _balance[from] = fromBalance - amount;
        _balance[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }


}