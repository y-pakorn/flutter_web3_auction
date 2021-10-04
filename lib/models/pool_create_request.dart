import '../controllers/web3controller.dart';
import '../utils.dart';

class PoolCreateRequest {
  /// Pool Name
  final String name;

  /// Address of token that would be selling
  final String token0Address;

  /// Address of token that would be accepted as currency
  final String token1Address;

  /// Total amount of token 0
  final BigInt amountTotalToken0;

  /// Total amount of token 1
  final BigInt amountTotalToken1;

  DateTime? openAt;

  DateTime? closeAt;

  Duration? duration;

  /// Delay duration that buyer can claim the token after pool is filled,
  /// default to 0; that mean buyer will instantly get their token
  final Duration claimDelayInSec;

  /// Maximum spending allocation of token1 per wallet
  final BigInt maxPerWallet;

  PoolCreateRequest({
    required this.name,
    required this.token0Address,
    required this.token1Address,
    required this.amountTotalToken0,
    required this.amountTotalToken1,
    this.openAt,
    this.closeAt,
    this.duration,
    required this.claimDelayInSec,
    required this.maxPerWallet,
  }) : assert(duration != null || closeAt != null);

  List<dynamic> parseToAbiList() {
    assert(closeAt != null || duration != null);

    return [
      name,
      token0Address,
      token1Address,
      amountTotalToken0.string,
      amountTotalToken1.string,
      openAt!.secondsSinceEpoch,
      closeAt!.secondsSinceEpoch,
      claimDelayInSec.inSeconds,
      maxPerWallet.string,
    ];
  }
}
