import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/fixed_swap/contract_controller.dart';
import '../../../controllers/fixed_swap/pool_controller.dart';
import '../../../utils.dart';
import 'pool_dialog_action.dart';

class ClaimPool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Get.find<FixedSwapPoolController>();
    return [
      'Your Pool'.text(TypeWeight.extraBold).fontSize(22).center(),
      Niku().height(20),
      if (p.pool!.isNotYetLive)
        'Going Live In'.text()
      else
        'Claimable In'.text(),
      StreamBuilder<Duration>(
          stream: p.durationStream,
          initialData: 0.seconds,
          builder: (_, snapshot) {
            final time = snapshot.data ?? 0.seconds;
            return [
              '${time.inDaysDiv.paddedTwoZero} : ${time.inHoursDiv.paddedTwoZero} : ${time.inMinutesDiv.paddedTwoZero} : ${time.inSecondsDiv.paddedTwoZero}'
                  .text(TypeWeight.bold)
                  .fontSize(16),
            ].column;
          }),
      'd:h:m:s'.text().fontSize(12),
      Niku().height(10),
      StreamBuilder<BigInt>(
        stream: ContractController().amountSoldStreamByIndex(p.poolId),
        initialData: p.pool!.amountSold,
        builder: (_, snapshot) {
          final value = snapshot.data ?? BigInt.zero;
          return [
            'Progress'.text(),
            [
              '${toDecimal(value).toStringAsFixed(2)}/${toDecimal(p.pool!.amountTotalToken1).toStringAsFixed(2)}'
                  .text(TypeWeight.extraBold)
                  .fontSize(16),
              p.pool!.currency.symbol.text(TypeWeight.bold).fontSize(16),
            ].wrap.crossCenter().spacing(10).runSpacing(10),
            Niku().height(10),
            'Left Claimable'.text(),
            [
              processDecimal(toDecimal(p.pool!.amountTotalToken1 - value) *
                      p.pool!.ratio)
                  .text(TypeWeight.extraBold)
                  .fontSize(16),
              p.pool!.token0!.symbol.text(TypeWeight.bold).fontSize(16),
            ].wrap.crossCenter().spacing(10).runSpacing(10),
          ].column;
        },
      ),
      Divider(thickness: 2, height: 40, color: kBlack),
      Spacer(),
      PoolDialogAction(
        loadingText: 'Claiming',
        doneText: 'Claimed',
        textToDisplay: 'Claim',
        isEnabled: p.pool!.isClosed && !p.pool!.isFilled,
        isDone: p.isClaimed,
        isLoading: p.isClaiming,
        onTap: p.claim,
      ).niku().fullWidth(),
    ]
        .column
        .mainSize(MainAxisSize.min)
        .niku()
        .width(400)
        .height(370)
        .padding(roundedBoxPaddingBig)
        .boxDecoration(defaultPoolItemBoxDecoration);
  }
}
