import 'package:flutter_web3/flutter_web3.dart';
import 'package:web3dart/crypto.dart';

import '../../models/pool.dart';
import '../../models/pool_create_request.dart';
import '../../models/pool_swap_request.dart';
import '../../models/token.dart';
import '../../utils.dart';
import '../web3controller.dart';

class ContractController {
  List<String> _abi = [
    'event Created(uint256 indexed index, address indexed sender, (string,address,address,address,uint,uint,uint,uint,uint,uint) pool)',
    'function create((string,address,address,uint,uint,uint,uint,uint,uint))',
    'function approve(address,uint)',
    'function poolCount() view returns(uint)',
    'function poolOwnerCount(address) view returns(uint)',
    'function poolOwner(address,uint) view returns(uint)',
    'function pools(uint) view returns(string,address,address,address,uint,uint,uint,uint,uint,uint)',
    'function swap(uint,uint) payable',
    'function amountSwap1P(uint) view returns(uint)',
    'function creatorClaimed(address,uint) view returns(bool)',
    'function creatorClaim(uint)',
    'function balanceOf(address) view returns (uint)',
    'function allowance(address,address) view returns (uint)',
    'function symbol() view returns (string)',
    'function decimals() view returns (uint)',
  ];

  String get fixedSwapContractAddress =>
      Web3Controller.to.currentChain?.fixedSwapContractAddress ?? '';

  // Should not be used, use events subscription instead.
  Stream<BigInt> amountSoldStreamByIndex(int index) async* {
    yield* Stream.periodic(kPollingRate, (tick) async {
      return await getAmountSoldByIndex(index);
    }).asyncMap((event) async => await event);
  }

  Future<TransactionResponse> approveBuyingTokenForPool(
      PoolSwapRequest request) async {
    final contract =
        ContractERC20(request.currencyAddress, provider!.getSigner());
    return contract.approve(fixedSwapContractAddress, request.amountPaid);
  }

  Future<TransactionResponse> approveSellingTokenForPool(
      PoolCreateRequest request) async {
    final contract =
        ContractERC20(request.token0Address, provider!.getSigner());
    return contract.approve(
        fixedSwapContractAddress, request.amountTotalToken0);
  }

  Future<TransactionResponse> claimPool(int index) async {
    final contract = connectToContract(fixedSwapContractAddress);
    return contract.send('creatorClaim', [index]);
  }

  Contract connectToContract(String address) =>
      Contract(address, _abi, provider!.getSigner());

  Future<TransactionResponse> createPool(PoolCreateRequest request) async {
    final contract = connectToContract(fixedSwapContractAddress);
    return contract.send('create', [request.parseToAbiList()]);
  }

  Future<BigInt> getAllowanceOf(
      String tokenAddress, String owner, String spender) async {
    final contract = ContractERC20(tokenAddress, provider!);
    return contract.allowance(owner, spender);
  }

  Future<BigInt> getAmountSoldByIndex(int index) async {
    final contract = connectToContract(fixedSwapContractAddress);
    return contract.call<BigInt>('amountSwap1P', [index]);
  }

  Future<BigInt> getBalanceOf(String tokenAddress, String address) async {
    final contract = ContractERC20(tokenAddress, provider!);
    return contract.balanceOf(address);
  }

  Future<List<Pool>> getAllPool() async {
    final contract = connectToContract(fixedSwapContractAddress);
    final logs = await contract.queryFilter(contract.getFilter('Created'));
    return logs.reversed.mapIndexed((e, i) {
      final result = (abiCoder.decode([
        'string',
        'address',
        'address',
        'address',
        'uint',
        'uint',
        'uint',
        'uint',
        'uint',
        'uint',
      ], '0x' + e.data.substring(66)));

      return Pool(
        index: i,
        name: result[0].toString(),
        creatorAddress: result[1].toString(),
        token0Address: result[2].toString(),
        token1Address: result[3].toString(),
        amountTotalToken0: (result[4] as BigNumber).toBigInt,
        amountTotalToken1: (result[5] as BigNumber).toBigInt,
        openAt: DateTime.fromMillisecondsSinceEpoch(
            (result[6] as BigNumber).toInt * 1000),
        closeAt: DateTime.fromMillisecondsSinceEpoch(
            (result[7] as BigNumber).toInt * 1000),
        claimDelay: Duration(seconds: (result[8] as BigNumber).toInt),
        maxPerWallet: (result[9] as BigNumber).toBigInt,
      );
    }).toList();
  }

  Future<Pool> getPoolByIndex(int index) async {
    final contract = connectToContract(fixedSwapContractAddress);
    final List<dynamic> tx = await Future.wait([
      contract.call('pools', [index]),
      contract.call<BigNumber>('amountSwap1P', [index]),
    ]);

    final data = tx[0];
    final token0 = await getToken(data[2]);

    return Pool(
      index: index,
      name: data[0],
      creatorAddress: data[1],
      token0Address: data[2],
      token1Address: data[3],
      amountTotalToken0: (data[4] as BigNumber).toBigInt,
      amountTotalToken1: (data[5] as BigNumber).toBigInt,
      openAt: DateTime.fromMillisecondsSinceEpoch(
          (data[6] as BigNumber).toInt * 1000),
      closeAt: DateTime.fromMillisecondsSinceEpoch(
          (data[7] as BigNumber).toInt * 1000),
      claimDelay: Duration(seconds: (data[8] as BigNumber).toInt),
      maxPerWallet: (data[9] as BigNumber).toBigInt,
      token0: token0,
      amountSold: (tx[1] as BigNumber).toBigInt,
    );
  }

  Future<int> getPoolLength() async {
    final contract = connectToContract(fixedSwapContractAddress);
    return (await contract.call<BigNumber>('poolCount')).toInt;
  }

  Future<int> getPoolOwnerCount() async {
    final contract = connectToContract(fixedSwapContractAddress);
    return (await contract.call<BigNumber>(
            'poolOwnerCount', [Web3Controller.to.selectedAddress]))
        .toInt;
  }

  Future<List<int>> getPoolOwnerIndexList() async {
    final totalLength = await getPoolOwnerCount();
    final args = [
      for (var i = 0; i < totalLength; i++)
        [Web3Controller.to.selectedAddress, i]
    ];

    final contract = connectToContract(fixedSwapContractAddress);
    final tx = await contract.multicall<BigNumber>('poolOwner', args);

    return tx.map((e) => e.toInt).toList().reversed.toList();
  }

  Future<Token> getToken(String tokenAddress) async {
    final contract = ContractERC20(tokenAddress, provider!);
    final symbol = await contract.symbol;
    final decimals = await contract.decimals;

    String? name;

    try {
      name = await contract.name;
    } catch (error) {}

    return Token(
      tokenAddress,
      symbol,
      decimals,
      name: name,
    );
  }

  Future<bool> isCreatorClaimedPool(int index) async {
    final contract = connectToContract(fixedSwapContractAddress);
    final b = await contract.call<bool>(
        'creatorClaimed', [Web3Controller.to.selectedAddress, index]);

    return await contract.call<bool>(
        'creatorClaimed', [Web3Controller.to.selectedAddress, index]);
  }

  Future<TransactionResponse> swap(PoolSwapRequest request) async {
    final contract = connectToContract(fixedSwapContractAddress);
    return contract.send(
      'swap',
      request.parseToAbiList(),
      request.isNative ? TransactionOverride(value: request.amountPaid) : null,
    );
  }
}
