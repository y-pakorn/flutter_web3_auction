import '../utils.dart';

class PoolSwapRequest {
  final int index;
  final BigInt amountPaid;
  final bool isNative;
  final String currencyAddress;

  PoolSwapRequest({
    required this.index,
    required this.amountPaid,
    required this.isNative,
    required this.currencyAddress,
  }) : assert(isNative ? currencyAddress == zeroAddress : true);

  List<dynamic> parseToAbiList() => [index, amountPaid.string];
}
