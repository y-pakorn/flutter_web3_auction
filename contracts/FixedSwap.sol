// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FixedSwap is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using ECDSA for bytes32;

  address internal constant DEAD_ADDRESS =
    0x000000000000000000000000000000000000dEaD;

  uint256 public feesRatio;
  address public feesAddress;

  struct CreateReq {
    // pool name
    string name;
    // address of sell token
    address token0;
    // address of buy token
    address token1;
    // total amount of token0
    uint256 amountTotal0;
    // total amount of token1
    uint256 amountTotal1;
    // the timestamp in seconds the pool will open
    uint256 openAt;
    // the timestamp in seconds the pool will be closed
    uint256 closeAt;
    // the delay timestamp in seconds when buyers can claim after pool filled; default to 0 (instant)
    uint256 claimDelaySec;
    // maximum final token distributed per wallet; default to 0 (unlimited)
    uint256 maxPerWallet;
  }

  struct Pool {
    // pool name
    string name;
    // creator of the pool
    address creator;
    // address of sell token
    address token0;
    // address of buy token
    address token1;
    // total amount of token0
    uint256 amountTotal0;
    // total amount of token1
    uint256 amountTotal1;
    // the timestamp in seconds the pool will open
    uint256 openAt;
    // the timestamp in seconds the pool will be closed
    uint256 closeAt;
    // the delay timestamp in seconds when buyers can claim after pool filled; default to 0 (instant)
    uint256 claimDelaySec;
    // maximum final token distributed per wallet; default to 0 (unlimited)
    uint256 maxPerWallet;
  }

  // pool index => the timestamp which the pool filled at
  mapping(uint256 => uint256) public filledAtP;
  // pool index => swap amount of token0
  mapping(uint256 => uint256) public amountSwap0P;
  // pool index => swap amount of token1
  mapping(uint256 => uint256) public amountSwap1P;
  // team address => pool index => whether or not creator's pool has been claimed
  mapping(address => mapping(uint256 => bool)) public creatorClaimed;
  // user address => list of pools created by that address
  mapping(address => uint256[]) public poolOwner;
  // user address => pool index => swapped amount of token0
  mapping(address => mapping(uint256 => uint256)) public myAmountSwapped0;
  // user address => pool index => swapped amount of token1
  mapping(address => mapping(uint256 => uint256)) public myAmountSwapped1;
  // user address => pool index => whether or not my pool has been claimed
  mapping(address => mapping(uint256 => bool)) public myClaimed;

  event Created(uint256 indexed index, address indexed sender, Pool pool);
  
  event Swapped(
    uint256 indexed index,
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    uint256 txFee
  );
  
  event Claimed(uint256 indexed index, address indexed sender, uint256 amount0);
  event UserClaimed(
    uint256 indexed index,
    address indexed sender,
    uint256 amount0
  );
  
  event DeListed(uint256 indexed index, address indexed sender);
  event ChangedFeesRatio(
    uint256 indexed oldFeesRatio,
    uint256 indexed newFeesRatio
  );
  
  Pool[] public pools;

  constructor(uint256 _feesRatio, address _feesAddress) public {
    //FeesRatio, 200 mean 2%
    feesRatio = _feesRatio;
    feesAddress = _feesAddress;
  }

  function poolCount() public view returns (uint256 count) {
    return pools.length;
  }

  function poolOwnerCount(address _queryAddress)
    public
    view
    returns (uint256 count)
  {
    return poolOwner[_queryAddress].length;
  }

  function changeFeesRatio(uint256 _newFeesRatio) public onlyOwner {
    feesRatio = _newFeesRatio;
  }

  function changeFeesAddress(address _newFeesAddress) public onlyOwner {
    feesAddress = _newFeesAddress;
  }

  function create(CreateReq memory poolReq) public payable nonReentrant {
    uint256 index = pools.length;
    require(poolReq.token0 != poolReq.token1, "token0 and token1 is same");
    require(poolReq.token0 != address(0), "no support for native token");
    require(poolReq.amountTotal0 != 0, "invalid amountTotal0");
    require(poolReq.amountTotal1 != 0, "invalid amountTotal1");
    require(poolReq.openAt >= block.timestamp, "invalid openAt");
    require(poolReq.closeAt > poolReq.openAt,"invalid closeAt");
    require(bytes(poolReq.name).length <= 15, "length of name is too long");

    // transfer amount of token0 to this contract
    IERC20 _token0 = IERC20(poolReq.token0);

    uint256 token0BalanceBefore = _token0.balanceOf(address(this));
    _token0.safeTransferFrom(msg.sender, address(this), poolReq.amountTotal0);

    // check for deflationary token
    require(
      _token0.balanceOf(address(this)).sub(token0BalanceBefore) ==
        poolReq.amountTotal0,
      "no support for deflationary token"
    );

    // create new pool in pools array
    Pool memory pool;
    pool.name = poolReq.name;
    pool.creator = msg.sender;
    pool.token0 = poolReq.token0;
    pool.token1 = poolReq.token1;
    pool.amountTotal0 = poolReq.amountTotal0;
    pool.amountTotal1 = poolReq.amountTotal1;
    pool.openAt = poolReq.openAt;
    pool.closeAt = poolReq.closeAt;
    pool.maxPerWallet = poolReq.maxPerWallet;
    pool.claimDelaySec = poolReq.claimDelaySec;

    pools.push(pool);
    poolOwner[msg.sender].push(index);

    emit Created(index, msg.sender, pool);
  }

  function swap(uint256 index, uint256 amount1)
    external
    payable
    nonReentrant
    isPoolExist(index)
  {
    address sender = msg.sender;
    Pool memory pool = pools[index];

    require(pool.closeAt > block.timestamp, "this pool is closed");
    require(pool.openAt <= block.timestamp, "pool not open");
    require(pool.amountTotal1 > amountSwap1P[index], "swap amount is zero");

    // check if amount1 is exceeded
    uint256 excessAmount1 = 0;
    uint256 _amount1 = pool.amountTotal1.sub(amountSwap1P[index]);
    if (_amount1 < amount1) {
      excessAmount1 = amount1.sub(_amount1);
    } else {
      _amount1 = amount1;
    }

    // check if amount0 is exceeded
    uint256 amount0 = _amount1.mul(pool.amountTotal0).div(pool.amountTotal1);
    uint256 _amount0 = pool.amountTotal0.sub(amountSwap0P[index]);
    if (_amount0 < amount0) {
      require(amount0 - _amount0 > 100, "amount0 is too big");
    } else {
      _amount0 = amount0;
    }

    amountSwap0P[index] = amountSwap0P[index].add(_amount0);
    amountSwap1P[index] = amountSwap1P[index].add(_amount1);
    myAmountSwapped0[sender][index] = myAmountSwapped0[sender][index].add(
      _amount0
    );

    // check if swapped amount of token1 is exceeded maximum allowance
    if (pool.maxPerWallet != 0) {
      require(
        myAmountSwapped1[sender][index].add(_amount1) <= pool.maxPerWallet,
        "swapped amount of token1 is exceeded maximum allowance"
      );
      myAmountSwapped1[sender][index] = myAmountSwapped1[sender][index].add(
        _amount1
      );
    }

    if (pool.amountTotal1 == amountSwap1P[index]) {
      filledAtP[index] = block.timestamp;
    }

    // transfer amount of token1 to this contract
    if (pool.token1 == address(0)) {
      require(msg.value == amount1, "invalid amount of ETH");
    } else {
      IERC20(pool.token1).safeTransferFrom(sender, address(this), amount1);
    }

    // send token0 to swapper(sender)
    if (pool.claimDelaySec == 0) {
      if (_amount0 > 0) {
        if (pool.token0 == address(0)) {
          payable(sender).transfer(_amount0);
        } else {
          IERC20(pool.token0).safeTransfer(sender, _amount0);
        }
      }
    }

    // send excess amount of token1 back to swapper(sender)
    if (excessAmount1 > 0) {
      if (pool.token1 == address(0)) {
        payable(sender).transfer(excessAmount1);
      } else {
        IERC20(pool.token1).safeTransfer(sender, excessAmount1);
      }
    }

    uint256 txFee = _amount1.mul(feesRatio).div(10000);
    uint256 _actualAmount1 = _amount1.sub(txFee);

    // send token1 to feesAddress
    if (txFee > 0) {
      if (pool.token1 == address(0)) {
        payable(feesAddress).transfer(txFee);
      } else {
        IERC20(pool.token1).safeTransfer(feesAddress, txFee);
      }
    }

    // send token1 to creator
    if (_actualAmount1 > 0) {
      if (pool.token1 == address(0)) {
        payable(pool.creator).transfer(_actualAmount1);
      } else {
        IERC20(pool.token1).safeTransfer(pool.creator, _actualAmount1);
      }
    }

    emit Swapped(index, sender, _amount0, _actualAmount1, txFee);
  }

  function creatorClaim(uint256 index)
    external
    nonReentrant
    isPoolExist(index)
  {
    Pool memory pool = pools[index];
    
    require(!creatorClaimed[pool.creator][index], "claimed");
    require(pool.closeAt <= block.timestamp, "this pool is not closed");
    
    creatorClaimed[pool.creator][index] = true;
    uint256 unSwapAmount0 = pool.amountTotal0 - amountSwap0P[index];
    if (unSwapAmount0 > 0) {
      IERC20(pool.token0).safeTransfer(pool.creator, unSwapAmount0);
    }

    emit Claimed(index, msg.sender, unSwapAmount0);
  }

  function userClaim(uint256 index) external nonReentrant isPoolExist(index) {
    Pool memory pool = pools[index];
    address sender = msg.sender;
    
    require(pools[index].claimDelaySec > 0, "invalid claim");
    require(!myClaimed[sender][index], "claimed");
    require(
      pool.closeAt.add(pool.claimDelaySec) <= block.timestamp,
      "claim not ready"
    );
    
    myClaimed[sender][index] = true;
    if (myAmountSwapped0[sender][index] > 0) {
      // send token0 to sender
      IERC20(pool.token0).safeTransfer(
        msg.sender,
        myAmountSwapped0[sender][index]
      );
    }
    emit UserClaimed(index, sender, myAmountSwapped0[sender][index]);
  }

  modifier isPoolNotClosed(uint256 index) {
    require(pools[index].closeAt > block.timestamp, "this pool is closed");
    _;
  }

  modifier isPoolExist(uint256 index) {
    require(index < pools.length, "this pool does not exist");
    _;
  }
}
