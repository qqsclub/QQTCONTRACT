// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

library Address {
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

   
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mintFromContract(address _addr,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract QQTPreSales {

    struct User {
        address upline;
        uint256 totalPurchase;
        uint256 mainPoolShare;
        uint256 NodeAPoolsShare;
        uint256 NodeBPoolsShare;
        uint256 NodeCPoolsShare;
        uint256 totalSpend;
        uint32 referrals;
        uint32 lastTransTime;
        bool status;
        bool isDev;
        bool isCompleted;
    }

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public dailyMintLimit;
    uint256 public limitLeft;
    uint256 public dailyPurchased;
    uint256 public preMintPrice = 25800000; //0.02580 Starting Price
    uint256 public blocks;
    uint256 public totalPurchase ;
    uint256 public mintprice_decimals = 1000000000;

    uint256 public qqs_lp_token = 20000000000000000000000000; // 20 M
    uint256 public qqs_developer_token = 20000000000000000000000000; // 20 M for BURN 
    uint256 public qqs_dev_toke_left = 20000000000000000000000000; //20 M left
    uint256 public per_dev_limit = 1000000000000000000000000; //1 M per Dev
    uint256 public left_overs ;
    uint256 public initTime;
    uint256 public startTime;
    uint256 public totalMainPoolShare;
    uint256 public totalNodeAShare;
    uint256 public totalNodeBShare;
    uint256 public totalNodeCShare;
    uint256 public resalesPrice;

    uint32 public dailyTimeDiff = 86400; //1 Day in Seconds
    uint32 public totalUser = 1;


    uint16 public blockPurchaseTime = 15; //Same User Cannot Buy New Blocks for 30 Seconds

    uint8 public dayCount;
    uint8 public maxDayCount;


    bool public buyStatus = true; // 1 Meaning Enabled
    bool public burnDevQQS = false; //Only one time can Burn
    bool public withdrawQQS = false; 
    bool public leftOverWithdraw = false; 

    address public owner;
    address public qqt_address;
    address public qqc_address = 0x552CEB4330ea92C66cDAa457d26524766b7c32Da;
    address public qqg_address = 0x66592b510Fe0217364208B4aD9894925F5212A63;
    address public company_address;
    address public crm_address;
    address public burnAddress = address(0);
    
    mapping(address => User) public users;
    mapping(address => mapping(uint256 => address))public downline_list;
    mapping(uint8 => uint256) public salesList;
    mapping(address => bool) public allowedTokens;

    constructor() {
        
        owner = msg.sender;
        maxDayCount = 60;
        dayCount  = 1;
        initTime = startTime= 1652587200; // Temporary user Block Start time
        dailyMintLimit =limitLeft = 1000000000000000000000000;
        dailyPurchased = 0;
        blocks = 10000000000000000000000;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function buyQQT(address _tokenaddress) external {
        
        require(block.timestamp > startTime);
        require(users[msg.sender].status == true,"User Required Whitelisted");
        require(block.timestamp > users[msg.sender].lastTransTime+blockPurchaseTime ,"Continues Purchase Blocked");

        require(allowedTokens[_tokenaddress]== true,"Only use BUSD or USDT for Payment");

        checkAllocation();

        require(buyStatus == true,"Required Purchase Must Enabled");

        IERC20 er = IERC20(_tokenaddress);
        IERC20 qq = IERC20(qqt_address);
        IERC20 qqc = IERC20(qqc_address);
        IERC20 qqg = IERC20(qqg_address);

        uint256 usdt_value = blocks.mul(preMintPrice).div(mintprice_decimals);

        require(
            er.allowance(msg.sender, address(this)) > usdt_value,
            "USDT APPROVAL FAILED"
        );
    
        require(qq.allowance(msg.sender,address(this)) > blocks,"Required QQT Approval");

        er.safeTransferFrom(msg.sender,address(this),usdt_value); // Transfer USDT to Contract
        qq.safeTransfer(msg.sender,blocks);  // Send QQS To Buyer
        qq.safeTransferFrom(msg.sender,burnAddress,blocks); //Send to BURN ADDRESS
        qqc.mintFromContract(msg.sender,blocks); //Mint QQC for Each Main Pool Shares
        qqg.mintFromContract(msg.sender,blocks); //Mint QQG for Each Main Pool Shares

        emit QQSBurn(msg.sender,blocks);

        limitLeft = limitLeft.sub(blocks);
        
        users[msg.sender].totalPurchase = users[msg.sender].totalPurchase + blocks;
        users[msg.sender].mainPoolShare = users[msg.sender].mainPoolShare + blocks;
        users[msg.sender].totalSpend    = users[msg.sender].totalSpend + usdt_value;

        totalPurchase = totalPurchase+blocks;
        totalMainPoolShare = totalMainPoolShare+blocks;
        
    }

    function buyDevToken() external {
        require(block.timestamp > startTime);
        require(users[msg.sender].status == true,"User Required Whitelisted");
        require(users[msg.sender].isDev == true,"Developer Address Required Whitelisted");
        require(users[msg.sender].isCompleted == false);
        require(qqs_dev_toke_left >= per_dev_limit);

        IERC20 qq = IERC20(qqt_address);

        require(qq.allowance(msg.sender,address(this)) > per_dev_limit,"Required QQT Approval");
        qq.safeTransfer(msg.sender,per_dev_limit);  // Send QQS To Buyer
        qq.safeTransferFrom(msg.sender,burnAddress,per_dev_limit); //Send to BURN ADDRESS
        qqs_dev_toke_left = qqs_dev_toke_left.sub(per_dev_limit);
        
        users[msg.sender].NodeAPoolsShare = per_dev_limit.mul(10); //10 Shares
        users[msg.sender].NodeBPoolsShare = per_dev_limit.mul(2); //2 Shares
        users[msg.sender].NodeCPoolsShare = per_dev_limit.div(2); //0.5 Shares

        totalNodeAShare = totalNodeAShare.add(users[msg.sender].NodeAPoolsShare);
        totalNodeBShare = totalNodeBShare.add(users[msg.sender].NodeBPoolsShare);
        totalNodeCShare = totalNodeCShare.add(users[msg.sender].NodeCPoolsShare);
    }

    function regsiterUser(address _upline) external {

        require(msg.sender != _upline, "Required Upline");
        require(users[msg.sender].status != true ,"Already Register");
        require((users[_upline].status == true || _upline == owner),"Required Upline");

        users[msg.sender].upline = _upline;
        users[_upline].referrals++;
        users[msg.sender].status = true;
        users[msg.sender].isDev = false;

        downline_list[_upline][users[_upline].referrals] = msg.sender;

        totalUser++;

    }

    function withdrawTokenForLP(address _addr) onlyOwner external {

            require(company_address != address(0));

            IERC20 er = IERC20(_addr);
            uint256 current_balance = er.balanceOf(address(this));
            er.safeTransfer(company_address,current_balance);

            emit LPWithdrawal(_addr,company_address,current_balance);

    }

    function withdrawQQTForLP() onlyOwner external {

        require(company_address != address(0));
        require(withdrawQQS == false);

        IERC20 qq = IERC20(qqt_address);
        qq.safeTransfer(company_address,qqs_lp_token);
        withdrawQQS = true;
        
        emit LPWithdrawal(qqt_address,company_address,qqs_lp_token);

    }

    function addCompanyAddress(address _addr) onlyOwner external {
            require(_addr != address(0));
            emit  AddCompanyAddress(company_address,_addr);
            company_address = _addr;

    }

    function addDevAddress(address _addr) onlyOwner external {
        users[_addr].status = true;
        users[_addr].isDev = true;
    }

    function updateDays() external
    {
        checkAllocation();
    }

    function addQQTAddress(address _addr) onlyOwner external {
        require(_addr != address(0));
        qqt_address = _addr;
    }

    function addNodeAddress(address _addr) onlyOwner external {
        crm_address = _addr;
    }

    function updateResalesPrice(uint256 _amount ) onlyOwner external {
        require(_amount > 0);
        resalesPrice = _amount;
    }

    function updateStarttime(uint256 _time) onlyOwner external {
        require(startTime > block.timestamp);
        require(_time > block.timestamp);
        startTime = _time;
    }
    
    function buyFromReSales(address _tokenaddress) external {

        require(buyStatus == false,"After IDO Only Can Buy");
        require(users[msg.sender].status == true,"User Required Whitelisted");
        require(allowedTokens[_tokenaddress]== true,"Only use USDT for Payment");
        require(left_overs >= blocks,"All Leftover Sold");

        IERC20 er = IERC20(_tokenaddress);
        IERC20 qq = IERC20(qqt_address);
        IERC20 qqc = IERC20(qqc_address);
        IERC20 qqg = IERC20(qqg_address);

        uint256 usdt_value = blocks.mul(resalesPrice).div(mintprice_decimals);

        require(
            er.allowance(msg.sender, address(this)) > usdt_value,
            "USDT APPROVAL FAILED"
        );
    
        require(qq.allowance(msg.sender,address(this)) > blocks,"Required QQT Approval");

        er.safeTransferFrom(msg.sender,address(this),usdt_value); // Transfer USDT to Contract
        qq.safeTransfer(msg.sender,blocks);  // Send QQS To Buyer
        qq.safeTransferFrom(msg.sender,burnAddress,blocks); //Send to BURN ADDRESS
        qqc.mintFromContract(msg.sender,blocks); //Mint QQC for Each Main Pool Shares
        qqg.mintFromContract(msg.sender,blocks); //Mint QQG for Each Main Pool Shares

        emit QQSBurn(msg.sender,blocks);

        left_overs = left_overs.sub(blocks);
        
        users[msg.sender].totalPurchase = users[msg.sender].totalPurchase + blocks;
        users[msg.sender].mainPoolShare = users[msg.sender].mainPoolShare + blocks;
        users[msg.sender].totalSpend    = users[msg.sender].totalSpend + usdt_value;

        totalPurchase = totalPurchase+blocks;
        totalMainPoolShare = totalMainPoolShare+blocks;

    }

    function addMainPoolShare(address _addr,uint256 shares) external {
        require(msg.sender == owner || msg.sender == crm_address);
        users[_addr].mainPoolShare = users[_addr].mainPoolShare+shares;
        totalMainPoolShare = totalMainPoolShare+shares;

        IERC20 qqc = IERC20(qqc_address);
        IERC20 qqg = IERC20(qqg_address);

        qqc.mintFromContract(_addr,shares); //Mint QQC for Each Main Pool Shares
        qqg.mintFromContract(_addr,shares); //Mint QQG for Each Main Pool Shares
    }
    function addNodePoolAShare(address _addr,uint256 shares) external {
        require(msg.sender == owner || msg.sender == crm_address);
        users[_addr].NodeAPoolsShare = users[_addr].NodeAPoolsShare+shares;
        totalNodeAShare = totalNodeAShare+shares;
    }
    function addNodePoolBShare(address _addr,uint256 shares) external {
        require(msg.sender == owner || msg.sender == crm_address);
        users[_addr].NodeBPoolsShare = users[_addr].NodeBPoolsShare+shares;
        totalNodeBShare = totalNodeBShare+shares;
    }
    function addNodePoolCShare(address _addr,uint256 shares) external {
        require(msg.sender == owner || msg.sender == crm_address);
        users[_addr].NodeCPoolsShare = users[_addr].NodeCPoolsShare+shares;
        totalNodeCShare = totalNodeCShare+shares;
    }

    function checkAllocation() internal {

        if(block.timestamp > startTime+dailyTimeDiff)
        {
            left_overs = left_overs.add(limitLeft);

            emit QQSBurn(address(this),limitLeft);

            salesList[dayCount] = dailyMintLimit.sub(limitLeft);

            if(dayCount+1 > maxDayCount)
                buyStatus =false;

            dayCount = dayCount+1;
            startTime = startTime+dailyTimeDiff;
            limitLeft = dailyMintLimit;
            uint256 pre_price = preMintPrice.mul(5).div(1000); // To Get 0.5 % Multiple by 1000 devide by 5 
            preMintPrice = preMintPrice.add(pre_price);

            resalesPrice = preMintPrice;
        }

        require(limitLeft >= blocks,"Max Limit Reached");
    }

    function addPaymetToken(address _addr) onlyOwner external {
        require(_addr != address(this),"OX Address Not Allowed");
        allowedTokens[_addr] = true;
    }

    function removePaymentToken(address _addr) onlyOwner external {
        require(_addr != address(this),"OX Address Not Allowed");
        allowedTokens[_addr] = false;
    }

    event LPWithdrawal(address indexed contract_address, address indexed to,uint256 value);
    event QQSBurn(address indexed burn_address , uint256 value);
    event AddCompanyAddress(address indexed old_address,address indexed new_address);
}