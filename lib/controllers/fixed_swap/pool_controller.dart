import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

import '../../models/controller_bundle.dart';
import '../../models/pool.dart';
import '../../models/pool_swap_request.dart';
import '../../pages/fixed_swap/widgets/swap_dialog.dart';
import '../../utils.dart';
import '../web3controller.dart';
import 'contract_controller.dart';

class FixedSwapPoolController extends GetxController {
  final int poolId;
  final ContractController contract = ContractController();

  bool isLoading = false;

  Pool? pool;

  BigInt currentBalance = BigInt.zero;

  late final ControllerBundle amountController;

  late final Stream<Duration> durationStream;

  FixedSwapPoolController(this.poolId);

  bool get poolLoaded => pool != null;

  bool isClaimed = true;

  bool isClaiming = false;

  Future<void> claim() async {
    isClaiming = true;
    update();

    try {
      final tx = await contract.claimPool(pool!.index);
      final receipt = await tx.wait();
      if (!receipt.status) throw Exception('invalid');

      await fetchIsClaimed();
    } finally {
      isClaiming = false;
      update();
    }
  }

  Future<void> fetchIsClaimed() async {
    if (poolLoaded && pool!.isCreator) {
      isClaimed = await contract.isCreatorClaimedPool(pool!.index);
      update();
    }
  }

  Future<void> fetchCurrentBalance() async {
    if (poolLoaded) {
      currentBalance = pool!.paidInNativeToken
          ? await Web3Controller.to.getNativeTokenBalance()
          : await contract.getBalanceOf(
              pool!.token1Address, Web3Controller.to.selectedAddress);
    }
  }

  Future<void> fetchPool() async {
    pool = await contract.getPoolByIndex(poolId);
  }

  Future<void> joinPool() async {
    toggleLoading(true);
    try {
      if (poolLoaded && amountController.validate()) {
        await Get.dialog(
          SwapDialog(
            PoolSwapRequest(
              index: pool!.index,
              amountPaid: toBase(Decimal.parse(amountController.text)),
              isNative: pool!.paidInNativeToken,
              currencyAddress: pool!.currency.address,
            ),
          ),
        );
        await Future.wait([fetchPool(), fetchCurrentBalance()]);
      }
    } finally {
      toggleLoading(false);
    }
  }

  @override
  void onClose() {
    //print('pool close');

    super.onClose();
  }

  @override
  void onInit() {
    if (Web3Controller.to.isConnectedAndInSupportedChain) trigger(true);
    Web3Controller.to.connectionChangedToConnected().listen(trigger);

    amountController = ControllerBundle(validator: (val) {
      if (val == null || val.isEmpty) return 'empty amount';
      if (Decimal.tryParse(val) == null) return 'wrong amount';
      final value = Decimal.parse(val);
      if (value == Decimal.zero) return 'zero amount';
      if (value.isNegative) return 'negative amount';
      if (toBase(value) > currentBalance) return 'exceed current balance';
      if (pool != null) {
        if (pool!.maxPerWallet != BigInt.zero &&
            toBase(value) > pool!.maxPerWallet)
          return 'more than max per wallet';
        if (DateTime.now().isAfter(pool!.closeAt)) return 'pool is closed';
        if (DateTime.now().isBefore(pool!.openAt)) return 'pool not yet open';
        //if (pool!.amountSold + toBase(value) > pool!.amountTotalToken1) 'more'
      }
      return null;
    });

    durationStream = Stream<Duration>.periodic(
      1.seconds,
      (tick) {
        if (poolLoaded) {
          if (DateTime.now().difference(pool!.openAt).abs() < 1.seconds)
            update();

          if (DateTime.now().difference(pool!.closeAt).abs() < 1.seconds)
            update();

          if (pool!.status == PoolStatus.Pending) {
            return pool!.openAt.difference(DateTime.now()).abs();
          } else if (pool!.status == PoolStatus.Live) {
            return pool!.closeAt.difference(DateTime.now()).abs();
          }
        }
        return 0.seconds;
      },
    ).asBroadcastStream();

    //print('pool init');
    super.onInit();
  }

  void setAmountMax() {
    if (poolLoaded) {
      final amount = pool!.isUnlimitedPerWallet
          ? currentBalance > pool!.amountTotalToken1
              ? pool!.amountTotalToken1
              : currentBalance
          : currentBalance > pool!.maxPerWallet
              ? pool!.maxPerWallet > pool!.amountTotalToken1
                  ? pool!.amountTotalToken1
                  : pool!.maxPerWallet
              : currentBalance > pool!.amountTotalToken1
                  ? pool!.amountTotalToken1
                  : currentBalance;
      amountController.changeTextControllerValue(toDecimal(amount));
      update();
    }
  }

  void setPoolSoldAmount(BigInt val) {
    if (pool != null) {
      pool!.amountSold = val;
      update();
    }
  }

  void toggleLoading(bool val) {
    if (val != isLoading) {
      isLoading = val;
    }
    update();
  }

  trigger(bool val) async {
    if (val == true) {
      toggleLoading(true);
      final totalPoolLength = await contract.getPoolLength();
      if (poolId < totalPoolLength) {
        await fetchPool();
        await Future.wait([fetchCurrentBalance(), fetchIsClaimed()]);
        toggleLoading(false);
      }
    }
  }
}
