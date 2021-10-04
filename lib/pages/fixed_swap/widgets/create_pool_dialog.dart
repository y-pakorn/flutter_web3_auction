import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:typeweight/typeweight.dart';
import 'package:web3dart/crypto.dart';

import 'package:flutter_web3/flutter_web3.dart';
import '../../../controllers/fixed_swap/contract_controller.dart';
import '../../../controllers/web3controller.dart';
import '../../../models/pool_create_request.dart';
import '../../../utils.dart';
import 'pool_dialog_action.dart';

class CreatePoolDialog extends StatelessWidget {
  final PoolCreateRequest poolCreateRequest;

  const CreatePoolDialog(this.poolCreateRequest, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => _CreatePoolDialogController(poolCreateRequest));

    return GetBuilder<_CreatePoolDialogController>(
      builder: (cp) => AlertDialog(
        title: [
          'Create Pool'.text(TypeWeight.extraBold).fontSize(22),
          'cancel'.text().fontSize(12).onTap(() => Get.back()),
        ].row.spaceBetween().crossCenter(),
        content: [
          PoolDialogAction(
            textToDisplay: 'Approve Token',
            loadingText: 'Approving Token',
            doneText: 'Token Approved',
            isEnabled: true,
            isDone: cp.isApproved,
            isLoading: cp.isApproving,
            onTap: cp.approve,
          ),
          PoolDialogAction(
            textToDisplay: 'Create Pool',
            loadingText: 'Creating Pool',
            doneText: 'Pool Created',
            isEnabled: cp.isApproved,
            isDone: cp.isCreated,
            isLoading: cp.isCreating,
            onTap: cp.create,
          ),
          PoolDialogAction(
              loadingText: 'Go to your pool',
              doneText: 'Go To Your Pool',
              textToDisplay: 'Go To Your Pool',
              isEnabled: cp.isCreated,
              isDone: false,
              isLoading: false,
              onTap: () {
                Get.back<int>(result: cp.poolIndex);
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

class _CreatePoolDialogController extends GetxController {
  final PoolCreateRequest createRequest;
  final ContractController contract = ContractController();

  bool isApproving = false;

  bool isApproved = false;
  bool isCreating = false;

  bool isCreated = false;
  int poolIndex = -1;

  _CreatePoolDialogController(this.createRequest);

  Future<void> approve() async {
    isApproving = true;
    update();

    try {
      final tx = await contract.approveSellingTokenForPool(createRequest);
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

  Future<void> create() async {
    TransactionResponse? tx;

    isCreating = true;
    update();

    try {
      if (createRequest.duration != null) {
        createRequest.openAt = DateTime.now().add(1.minutes);
        createRequest.closeAt = DateTime.now().add(createRequest.duration!);
        tx = await contract.createPool(createRequest);
      } else {
        createRequest.openAt = DateTime.now().add(1.minutes);
        tx = await contract.createPool(createRequest);
      }
      if (tx != null) {
        final receipt = await tx.wait();

        if (!receipt.status) throw Exception('invalid');

        final index = receipt.logs
            .firstWhere((element) => element.topics.first == createPoolHash)
            .topics[1];

        poolIndex = hexToInt(index).toInt();
      } else
        throw Exception('invalid');

      isCreated = true;
      isCreating = false;
      update();
    } catch (error) {
      isCreating = false;
      update();

      rethrow;
    }
  }

  @override
  void onInit() async {
    final allowance = await contract.getAllowanceOf(
        createRequest.token0Address,
        Web3Controller.to.selectedAddress,
        Web3Controller.to.currentChain?.fixedSwapContractAddress ?? '');
    if (allowance >= createRequest.amountTotalToken0) {
      isApproved = true;
      update();
    }
    super.onInit();
  }
}
