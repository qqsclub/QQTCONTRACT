// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract QQTToken is IERC20 {
    
    using SafeMath for uint256;

    uint public totalSupply;
    uint public maxSupply = 10000000000000000000000000000; //10B
    uint public premintSupply  = 100000000000000000000000000; //100 M
    uint8 public decimals = 18;
    uint8 public tax = 150; //x100
    uint256 public lastminttime ;
    uint256 public maxMintPerDay = 250000000000000000000000; //250K
    uint32 public minMintDifference = 86400; //1 Day in Seconds
    
    address public mintAllowAddress;
    address public owner;
    address public treasury;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public whitelistedAddrees;
    string public name = "QQ Token";
    string public symbol = "QQT";


    constructor(address pre_mint_address)
    {
        owner = msg.sender;
        premint(premintSupply,pre_mint_address);
    }

     modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        
        balanceOf[msg.sender] -= amount;
        if(whitelistedAddrees[msg.sender] == true || tax == 0){
            balanceOf[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
        }
        else{
            uint256 taxamount = amount.mul(tax).div(10000);
            uint256 receivable = amount.sub(taxamount);

            balanceOf[recipient] += receivable;
            balanceOf[treasury] += taxamount;

            emit Transfer(msg.sender, recipient, receivable);
            emit Transfer(msg.sender, treasury, taxamount);
        }
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;

        if(whitelistedAddrees[msg.sender] == true || tax == 0){
            balanceOf[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
        else{
            uint256 taxamount = amount.mul(tax).div(10000);
            uint256 receivable = amount.sub(taxamount);

            balanceOf[recipient] += receivable;
            balanceOf[treasury] += taxamount;

            emit Transfer(sender, recipient, receivable);
            emit Transfer(sender, treasury, taxamount);
        }
        
        return true;
    }

    function mint(uint256 amount) external {

        require(totalSupply+amount <=maxSupply ,"Mint 10 B Token already");

        require(msg.sender == mintAllowAddress,"Only QQT Minting System Allow to Mint Token");

        require( block.timestamp > lastminttime+minMintDifference ,"Minimum 24 Hr Different Between Each Mint");

        require(amount <= maxMintPerDay," Maximum Can Mint only 5K Per Mint");

        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        
        lastminttime = block.timestamp;
        emit minted(msg.sender,amount);
        emit Transfer(address(0), msg.sender, amount);
    }

    function premint(uint amount,address _private_address) private {
        balanceOf[_private_address] += amount;
        totalSupply += amount;
        emit Transfer(address(0), _private_address , amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function whitelistMintAddress(address _addr) onlyOwner external{
        mintAllowAddress = _addr;

    }

    function addFullTransferAddress(address _addr) onlyOwner external {
        whitelistedAddrees[_addr] = true;
    }

    function addTreasuryAddress(address _addr) onlyOwner external {
        require(_addr != address(0),"Required Valid Address");
        treasury = _addr;
    }

    function changeTax(uint8 _tax) onlyOwner external {
        tax = _tax;
    }

    event minted(address indexed _to,uint value);
}
