import 'package:decimal/decimal.dart';

import '../controllers/fixed_swap/contract_controller.dart';
import '../controllers/web3controller.dart';
import '../utils.dart';
import 'chain.dart';
import 'token.dart';

class Pool {
  final int index;

  /// Pool Name
  final String name;

  final String creatorAddress;

  /// Address of token that would be selling
  final String token0Address;

  /// Address of token that would be accepted as currency
  final String token1Address;

  /// Total amount of token 0
  final BigInt amountTotalToken0;

  /// Total amount of token 1
  final BigInt amountTotalToken1;

  final DateTime openAt;

  final DateTime closeAt;

  /// Delay duration that buyer can claim the token after pool is filled,
  /// default to 0; that mean buyer will instantly get their token
  final Duration claimDelay;

  /// Maximum spending allocation of token1 per wallet
  final BigInt maxPerWallet;

  /// Token 0 object
  Token? token0;

  /// Current amount that is sold in currency.
  BigInt? amountSold;

  Pool({
    required this.index,
    required this.name,
    required this.creatorAddress,
    required this.token0Address,
    required this.token1Address,
    required this.amountTotalToken0,
    required this.amountTotalToken1,
    required this.openAt,
    required this.closeAt,
    required this.claimDelay,
    required this.maxPerWallet,
    this.token0,
    this.amountSold,
  });

  CurrencyToken get currency =>
      Web3Controller.to.currentChain!.fixedSwapCurrency!.firstWhere((element) =>
          element.address.toLowerCase() == token1Address.toLowerCase());

  bool get isClosed => status == PoolStatus.Closed;

  bool get isCreator =>
      Web3Controller.to.selectedAddress.toLowerCase() ==
      creatorAddress.toLowerCase();

  bool get isFilled => status == PoolStatus.Filled;

  bool get isFilledOrClosed => isClosed || isFilled;

  bool get isLive => status == PoolStatus.Live;

  bool get isNoClaimDelay => claimDelay == Duration.zero;

  bool get isNotYetLive => DateTime.now().isBefore(openAt);

  bool get isUnlimitedPerWallet => maxPerWallet == BigInt.zero;

  bool get paidInNativeToken =>
      token1Address.toLowerCase() == zeroAddress.toLowerCase();

  Decimal get percentSold => amountSold == null
      ? Decimal.parse('0.00')
      : toDecimal(amountSold!) /
          toDecimal(amountTotalToken1) *
          Decimal.fromInt(100);

  Decimal get ratio =>
      toDecimal(amountTotalToken0, token0?.decimal ?? 18) /
      toDecimal(amountTotalToken1);

  PoolStatus get status {
    if (amountSold != null && amountSold! >= amountTotalToken1)
      return PoolStatus.Filled;
    else if (DateTime.now().isAfter(closeAt))
      return PoolStatus.Closed;
    else if (DateTime.now().isAfter(openAt))
      return PoolStatus.Live;
    else
      return PoolStatus.Pending;
  }

  Decimal calculateAmountFromInput(BigInt wad) {
    return ratio * toDecimal(wad);
  }

  Decimal getPercentSoldByAmount(BigInt amount) =>
      toDecimal(amount) / toDecimal(amountTotalToken1);

  getToken0() async {
    token0 = await ContractController().getToken(token0Address);
  }

  @override
  String toString() {
    return '$index $name from ${creatorAddress.substring(0, 6)}';
  }
}

enum PoolStatus {
  Pending,
  Live,
  Closed,
  Filled,
}
