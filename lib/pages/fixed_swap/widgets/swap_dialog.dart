import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/fixed_swap/contract_controller.dart';
import '../../../controllers/web3controller.dart';
import '../../../models/pool_swap_request.dart';
import '../../../utils.dart';
import 'pool_dialog_action.dart';

class SwapDialog extends StatelessWidget {
  final PoolSwapRequest request;

  const SwapDialog(this.request, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => _SwapDialogController(request));
    return GetBuilder<_SwapDialogController>(
      builder: (sw) => AlertDialog(
        title: [
          'Buy Token'.text(TypeWeight.extraBold).fontSize(22),
          'cancel'.text().fontSize(12).onTap(() => Get.back()),
        ].row.spaceBetween().crossCenter(),
        content: [
          PoolDialogAction(
            textToDisplay: 'Approve Token',
            loadingText: 'Approving Token',
            doneText: 'Token Approved',
            isEnabled: true,
            isDone: sw.isApproved,
            isLoading: sw.isApproving,
            onTap: sw.approve,
          ),
          PoolDialogAction(
            textToDisplay: 'Buy Token',
            loadingText: 'Buying Token',
            doneText: 'Token Bought',
            isEnabled: sw.isApproved,
            isDone: sw.isSwapped,
            isLoading: sw.isSwapping,
            onTap: sw.swap,
          ),
          PoolDialogAction(
              loadingText: 'Go Back',
              doneText: 'Go Back',
              textToDisplay: 'Go Back',
              isEnabled: sw.isSwapped,
              isDone: false,
              isLoading: false,
              onTap: () {
                Get.back();
              }),
        ].column.mainSize(MainAxisSize.min).crossCenter(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
    );
  }
}

class _SwapDialogController extends GetxController {
  final PoolSwapRequest swapRequest;
  _SwapDialogController(this.swapRequest);

  final ContractController contract = ContractController();

  BigInt allowance = BigInt.zero;

  bool isApproving = false;
  bool isApproved = false;

  bool isSwapping = false;
  bool isSwapped = false;

  Future<void> approve() async {
    isApproving = true;
    update();

    try {
      final tx = await contract.approveBuyingTokenForPool(swapRequest);
      final receipt = await tx.wait();
      if (!receipt.status) throw Exception('invalid');

      isApproved = true;
      isApproving = false;
      update();
    } catch (error) {
      isApproving = false;
      update();

      rethrow;
    }
  }

  Future<void> swap() async {
    isSwapping = true;
    update();

    try {
      final tx = await contract.swap(swapRequest);
      final receipt = await tx.wait();
      if (!receipt.status) throw Exception('invalid');

      isSwapped = true;
      isSwapping = false;
      update();
    } catch (error) {
      isSwapping = false;
      update();

      rethrow;
    }
  }

  @override
  void onInit() async {
    if (swapRequest.isNative) {
      isApproved = true;
      update();
    } else {
      final allowance = await contract.getAllowanceOf(
        swapRequest.currencyAddress,
        Web3Controller.to.selectedAddress,
        Web3Controller.to.currentChain?.fixedSwapContractAddress ?? '',
      );
      if (allowance >= swapRequest.amountPaid) {
        isApproved = true;
        update();
      }
    }
    super.onInit();
  }
}
