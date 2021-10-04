import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/fixed_swap/contract_controller.dart';
import '../../../controllers/fixed_swap/pool_controller.dart';
import '../../../utils.dart';
import 'create_listing.dart';

class JoinPoolPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      placeholderBox(200, 40),
      Niku().height(20),
      placeholderBox(60),
      Niku().height(5),
      placeholderBox(160),
      Niku().height(5),
      placeholderBox(),
      Niku().height(10),
      placeholderBox(60),
      Niku().height(5),
      placeholderBox(120),
      Divider(thickness: 2, height: 40, color: kBlack),
      [
        placeholderBox(80),
      ].row,
      Niku().height(20),
      [
        placeholderBox(370, 40),
      ].row,
      Spacer(),
      CreateListing(
        textToDisplay: 'Buy',
        color: kGrey,
        bgColor: kLightGrey,
        icon: CupertinoIcons.chevron_right,
        padding: roundedBoxPaddingBig,
      ).niku().fullWidth()
    ]
        .column
        .niku()
        .width(400)
        .height(370)
        .padding(roundedBoxPaddingBig)
        .boxDecoration(defaultPoolItemBoxDecoration);
  }
}

class JoinPool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Get.find<FixedSwapPoolController>();

    return [
      _poolJoin(p.pool!.name),
      Niku().height(20),
      if (p.pool!.isNotYetLive)
        'Going Live In'.text()
      else if (p.pool!.isFilledOrClosed)
        'Closed'.text()
      else
        'Time left'.text(),

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
      'Progress'.text(),
      StreamBuilder<BigInt>(
        stream: ContractController().amountSoldStreamByIndex(p.poolId),
        initialData: p.pool!.amountSold,
        builder: (_, snapshot) {
          final value = snapshot.data ?? BigInt.zero;
          return [
            '${toDecimal(value).toStringAsFixed(2)}/${toDecimal(p.pool!.amountTotalToken1).toStringAsFixed(2)}'
                .text(TypeWeight.extraBold)
                .fontSize(16),
            p.pool!.currency.symbol.text(TypeWeight.bold).fontSize(16),
          ].wrap.crossCenter().spacing(10).runSpacing(10);
        },
      ),
      Divider(thickness: 2, height: 40, color: kBlack),
      ['Amount in ${p.pool!.currency.symbol}'.text(TypeWeight.bold)].row,
      //Niku().height(10),
      Expanded(
        child: 'Input Amount Desired in ${p.pool!.currency.symbol}'
            .textField
            .enabled(!p.isLoading &&
                !p.pool!.isFilledOrClosed &&
                !p.pool!.isNotYetLive)
            .labelFontSize(14)
            .textEditingController(p.amountController.textController)
            .focusNode(p.amountController.focusNode)
            .maxLines(1)
            .expands(false)
            .validator(p.amountController.validator)
            .hintText('250.20')
            .floatingLabelBehavior(FloatingLabelBehavior.never)
            .isDense(true)
            .cursorColor(kBlack)
            .errorText(p.amountController.tokenIsError
                ? p.amountController.errorText
                : null)
            .suffix(
              '100%'
                  .text(TypeWeight.bold)
                  .scale()
                  .onTap(() {
                    p.amountController.focusNode.unfocus();
                    p.setAmountMax();
                  })
                  .niku()
                  .padding(EdgeInsets.only(left: 10)),
            ),
      ),
      //Spacer(),
      CreateListing(
        textToDisplay: 'Buy',
        color:
            !p.isLoading && !p.pool!.isFilledOrClosed && !p.pool!.isNotYetLive
                ? null
                : kGrey,
        bgColor:
            !p.isLoading && !p.pool!.isFilledOrClosed && !p.pool!.isNotYetLive
                ? null
                : kLightGrey,
        icon: CupertinoIcons.chevron_right,
        padding: roundedBoxPaddingBig,
        //).niku().fullWidth().onTap(
      ).niku().fullWidth().onTap(p.isLoading || p.amountController.text.isEmpty
          ? null
          : () async {
              //() async {
              p.amountController.focusNode.unfocus();
              await p.joinPool();
            }),
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

Widget _poolJoin([String? poolName]) =>
    (poolName == null ? 'Join' : 'Join $poolName')
        .text(TypeWeight.extraBold)
        .fontSize(22)
        .center();
