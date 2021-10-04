import 'currency.dart';

class Chain {
  final String name;
  final String logoAsset;
  final String blockExplorerUrl;

  //final Currency currency;
  final String? fixedSwapContractAddress;
  final List<CurrencyToken>? fixedSwapCurrency;
  final NativeTokenLP? nativeTokenLP;

  CurrencyToken? get nativeToken => fixedSwapCurrency?.first;

  bool get supported =>
      fixedSwapContractAddress != null && fixedSwapCurrency != null;

  const Chain({
    required this.name,
    required this.logoAsset,
    required this.blockExplorerUrl,
    //required this.currency,
    this.fixedSwapCurrency,
    this.fixedSwapContractAddress,
    this.nativeTokenLP,
  });
}

class CurrencyToken {
  final String symbol;
  final String address;
  final String logoAsset;
  final int decimal;

  const CurrencyToken({
    required this.symbol,
    required this.address,
    required this.logoAsset,
    required this.decimal,
  });
}

class NativeTokenLP {
  final String address;
  final bool isToken0Native;
  final int decimals;

  const NativeTokenLP({
    required this.address,
    required this.isToken0Native,
    required this.decimals,
  });
}
