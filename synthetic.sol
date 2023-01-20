//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint _amountt) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint _amountt) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint _amountt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract SyntheticRewards {
    IERC20 public  stakingToken;
    IERC20 public  rewardsToken;

   uint public rewardRate = 100;
   uint public lastRewardTime;
   uint public rewardPerTokenstored;

   mapping(address => uint) public userPerRewardPerTokenPaid;
   mapping(address => uint) public rewards;

   uint private _totalSuply;
    mapping(address => uint) private _balances;

    modifier updateReward(address account) {
        rewardPerTokenstored = rewardPerToken();
        lastRewardTime = block.timestamp;
        rewards[account] = earned(account);
        userPerRewardPerTokenPaid[account] = rewardPerTokenstored;
        _;
    }

    constructor(address _rewardsToken, address _stakingToken) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
    }

    function rewardPerToken() public view returns (uint) {
        if(_totalSuply == 0) {
            return 0;
        } return rewardPerTokenstored +
        rewardRate *(block.timestamp - lastRewardTime) * 1e18 / _totalSuply;
    }

    function earned(address account) public view returns (uint) {
        return(
            _balances[account] * (rewardPerToken() - userPerRewardPerTokenPaid[account]) / 1e18
        ) + rewards[account];
    }

    function stake(uint _amountt) external updateReward(msg.sender) {
        _totalSuply += _amountt;
        _balances[msg.sender] += _amountt;
        stakingToken.transferFrom(msg.sender, address(this), _amountt);
    }
    
    function withdraw(uint _amountt) external updateReward(msg.sender) {
         _totalSuply -= _amountt;
        _balances[msg.sender] -= _amountt;
        stakingToken.transfer(msg.sender, _amountt);
    }

    function getReward() external {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }
}
