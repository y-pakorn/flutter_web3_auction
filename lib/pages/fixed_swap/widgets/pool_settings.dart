import 'package:clipboard/clipboard.dart';
import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/fixed_swap/create_controller.dart';
import '../../../utils.dart';

class PoolSettingsPlaceholder extends StatelessWidget {
  Widget _buildSectionHeader(String sectionName, String tooltipText) => [
        '$sectionName'.text(TypeWeight.bold).fontSize(16),
        Niku().width(5),
        infoTooltip('$tooltipText'),
      ].row.crossCenter().mainSize(MainAxisSize.min);

  @override
  Widget build(BuildContext context) {
    return [
      'Pool Information/Settings'.text(TypeWeight.bold).fontSize(18),
      [
        _buildSectionHeader(
          'Pool Name',
          'Your pool name that will be shown in our website',
        ),
        Niku().height(10),
        Flexible(
          child: [
            placeholderBox(300, 40),
            Niku().height(5),
            placeholderBox(60, 15),
          ].column.crossEnd(),
        ),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Currency',
          'Currency that will be used in your pool',
        ),
        Niku().height(10),
        [
          ['BUSD', 'assets/busd.svg'],
          ['USDT', 'assets/usdt.svg']
        ]
            .map((e) => [
                  SvgPicture.asset(
                    e[1],
                    fit: BoxFit.scaleDown,
                    width: 20,
                    height: 20,
                  ),
                  Niku().width(5),
                  '${e[0]}'.text(TypeWeight.medium).color(kGrey).fontSize(16),
                ]
                    .row
                    .crossCenter()
                    .mainSize(MainAxisSize.min)
                    .niku()
                    .padding(EdgeInsets.all(10))
                    .boxDecoration(defaultPoolItemBoxDecoration.copyWith(
                        color: Colors.grey.shade200))
                    .scale())
            .toList()
            .wrap
            .spacing(15)
            .runSpacing(15)
            .crossCenter()
            .end()
            .niku()
            .fullWidth(),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Total Amount',
          'Total token amount that you will put in this pool',
        ),
        Niku().height(10),
        Flexible(
          child: [
            placeholderBox(400, 40),
            Niku().height(5),
            placeholderBox(60, 15),
          ].column.crossEnd(),
        ),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Fixed Swap Ratio',
          'Fixed swap ratio of the pool, this will determine maximum amount of token you would get back',
        ),
        Niku().height(10),
        Flexible(
          child: [
            placeholderBox(400, 40),
            Niku().height(5),
            placeholderBox(60, 15),
          ].column.crossEnd(),
        ),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Duration',
          'Total duration of the pool i.e. time until the pool is closed',
        ),
        Niku().height(10),
        [1.hours, 2.hours, 4.hours, 6.hours]
            .map((e) => prettyDuration(e)
                .text(TypeWeight.bold)
                .color(kGrey)
                .niku()
                .padding(EdgeInsets.all(10))
                .boxDecoration(defaultPoolItemBoxDecoration.copyWith(
                    color: Colors.grey.shade200))
                .scale())
            .toList()
            .wrap
            .crossCenter()
            .end()
            .spacing(15)
            .runSpacing(15)
            .niku()
            .fullWidth(),
        Divider(thickness: 1, height: 40, color: kGrey),
        'Pool will ran for 1 hour.'.text(TypeWeight.extraBold).fontSize(20),
        [
          'And you will get total of 0 BUSD'
              .text(TypeWeight.extraBold)
              .fontSize(20),
          Niku().width(5),
          infoTooltip('$urlPrefixWithoutHttp tax excluded')
        ].row.mainEnd().crossCenter()
      ].column.crossEnd().mainSize(MainAxisSize.min),
    ].column.crossStart().mainSize(MainAxisSize.min);
  }
}

class PoolSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<FixedSwapCreateController>();

    return [
      'Pool Information/Settings'.text(TypeWeight.bold).fontSize(18),
      [
        _buildSectionHeader(
          'Pool Name',
          'Your pool name that will be shown in our website',
        ),
        Niku().height(10),
        _buildPoolName(c),
        _buildSectionHeader(
          'Pool Currency',
          'Currency that will be used in your pool',
        ),
        Niku().height(10),
        _buildCurrency(c),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Total Amount',
          'Total token amount that you will put in this pool',
        ),
        _buildAmount(c),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Fixed Swap Ratio',
          'Fixed swap ratio of the pool, this will determine maximum amount of token you would get back',
        ),
        _buildRatio(c),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Maximum Swap Per Wallet',
          'Maximum buying allocation per wallet of the pool',
        ),
        Niku().height(10),
        _buildMaxPerWalletSelect(c),
        if (!c.isNoLimitPerWallet) _buildMaxPerWallet(c),
        Niku().height(20),
        _buildSectionHeader(
          'Pool Duration',
          'Total duration of the pool i.e. time until the pool is closed',
        ),
        Niku().height(10),
        _buildDuration(c),
        Divider(thickness: 1, height: 40, color: kGrey),
        'Pool ${c.poolNameController.text} will ran for ${prettyDuration(c.selectedDuration)}.'
            .text(TypeWeight.extraBold)
            .fontSize(20)
            .end(),
        [
          Flexible(
              child:
                  'And you will get total of ${processDecimal(c.totalCurrencyAmountByRatio)} ${c.selectedCurrency!.symbol}'
                      .text(TypeWeight.extraBold)
                      .fontSize(20)
                      .end()),
          Niku().width(5),
          infoTooltip('$urlPrefixWithoutHttp tax excluded')
        ].row.mainEnd().crossCenter()
      ].column.crossEnd(),
    ].column.crossStart().mainSize(MainAxisSize.min);
  }

  Widget _buildMaxPerWalletSelect(FixedSwapCreateController c) => [
        'Unlimited'
            .text(
                c.isNoLimitPerWallet ? TypeWeight.extraBold : TypeWeight.medium)
            .color(c.isNoLimitPerWallet ? kBlack : kGrey)
            .niku()
            .padding(EdgeInsets.all(10))
            .boxDecoration(defaultPoolItemBoxDecoration.copyWith(
                color: c.isNoLimitPerWallet ? null : Colors.grey.shade200))
            .scale()
            .onTap(c.isTokenEmpty
                ? null
                : () {
                    c.toggleWalletUnlimited(true);
                  }),
        'Limited'
            .text(!c.isNoLimitPerWallet
                ? TypeWeight.extraBold
                : TypeWeight.medium)
            .color(!c.isNoLimitPerWallet ? kBlack : kGrey)
            .niku()
            .padding(EdgeInsets.all(10))
            .boxDecoration(defaultPoolItemBoxDecoration.copyWith(
                color: !c.isNoLimitPerWallet ? null : Colors.grey.shade200))
            .scale()
            .onTap(c.isTokenEmpty
                ? null
                : () {
                    c.toggleWalletUnlimited(false);
                  }),
      ].wrap.crossCenter().spacing(15).runSpacing(15);

  Widget _buildMaxPerWallet(FixedSwapCreateController c) =>
      'Input Maximum Swap Amount'
          .textField
          .enabled(!c.isTokenEmpty && !c.isNoLimitPerWallet)
          .labelFontSize(14)
          .textEditingController(c.maxPerWalletController.textController)
          .focusNode(c.maxPerWalletController.focusNode)
          .maxLines(1)
          .expands(false)
          //.maxLength(20)
          .validator(c.maxPerWalletController.validator)
          .hintText('100')
          .floatingLabelBehavior(FloatingLabelBehavior.never)
          .isDense(true)
          .cursorColor(kBlack)
          .errorText(c.maxPerWalletController.tokenIsError
              ? c.maxPerWalletController.errorText
              : null)
          .onChanged((val) {
            c.maxPerWalletController.validate();
            //c.update();
          })
          .suffix(
            '${c.selectedCurrency!.symbol}'
                .text(TypeWeight.bold)
                .niku()
                .padding(EdgeInsets.only(right: 10)),
          )
          .niku()
          .width(200);

  Widget _buildAmount(FixedSwapCreateController c) =>
      'Input Your Token Total Amount'
          .textField
          .enabled(!c.isTokenEmpty)
          .labelFontSize(14)
          .textEditingController(c.amountController!.textController)
          .focusNode(c.amountController!.focusNode)
          .maxLines(1)
          .expands(false)
          //.maxLength(20)
          .validator(c.amountController!.validator)
          .hintText('69696969.0')
          .floatingLabelBehavior(FloatingLabelBehavior.never)
          .isDense(true)
          .cursorColor(kBlack)
          .errorText(c.amountController!.tokenIsError
              ? c.amountController!.errorText
              : null)
          .onChanged((val) {
            c.amountController!.validate();
            //c.update();
          })
          .suffix(
            [
              '50%'.text(TypeWeight.bold).scale().onTap(
                    c.isTokenEmpty
                        ? null
                        : () {
                            c.amountController!.changeTextControllerValue(
                              toDecimal(c.currentTokenBalance ~/ BigInt.two)
                                  .toString(),
                            );
                            c.update();
                          },
                  ),
              Niku().width(5),
              '75%'.text(TypeWeight.bold).scale().onTap(c.isTokenEmpty
                  ? null
                  : () {
                      c.amountController!.changeTextControllerValue(
                        toDecimal(c.currentTokenBalance *
                                BigInt.parse('75') ~/
                                BigInt.parse('100'))
                            .toString(),
                      );
                      c.update();
                    }),
              Niku().width(5),
              '100%'.text(TypeWeight.bold).scale().onTap(c.isTokenEmpty
                  ? null
                  : () {
                      c.amountController!.changeTextControllerValue(
                        toDecimal(c.currentTokenBalance).toString(),
                      );
                      c.update();
                    }),
            ].row.mainSize(MainAxisSize.min),
          )
          .niku()
          .width(400);

  Widget _buildCurrency(FixedSwapCreateController c) => c.availableCurrency
      .map(
        (e) => [
          SvgPicture.asset(
            e.logoAsset,
            fit: BoxFit.scaleDown,
            width: 20,
            height: 20,
          ),
          Niku().width(5),
          '${e.symbol}'
              .text(e == c.selectedCurrency
                  ? TypeWeight.extraBold
                  : TypeWeight.medium)
              .color(e == c.selectedCurrency ? kBlack : kGrey)
              .fontSize(16),
          if (e.address != zeroAddress) ...[
            Niku().width(5),
            Icon(CupertinoIcons.doc_on_doc, size: 12, color: kDarkGrey)
                .showTooltip('Copy address')
                .scale()
                .onTap(() {
              FlutterClipboard.copy(e.address);
            }),
            Niku().width(5),
            Icon(CupertinoIcons.arrow_up_right, size: 12, color: kDarkGrey)
                .showTooltip('Open in block explorer')
                .scale()
                .launchAddress(e.address),
          ]
        ]
            .row
            .crossCenter()
            .mainSize(MainAxisSize.min)
            .niku()
            .padding(EdgeInsets.all(10))
            .boxDecoration(defaultPoolItemBoxDecoration.copyWith(
                color: e == c.selectedCurrency ? null : Colors.grey.shade200))
            .scale()
            .onTap(c.isTokenEmpty
                ? null
                : () {
                    c.changeCurrency(e);
                  }),
      )
      .toList()
      .wrap
      .spacing(15)
      .runSpacing(15)
      .crossCenter()
      .end()
      .niku()
      .fullWidth();

  Widget _buildDuration(FixedSwapCreateController c) => c.availableDuration
      .map(
        (e) => prettyDuration(e)
            .text(e == c.selectedDuration
                ? TypeWeight.extraBold
                : TypeWeight.medium)
            .color(e == c.selectedDuration ? kBlack : kGrey)
            .niku()
            .padding(EdgeInsets.all(10))
            .boxDecoration(defaultPoolItemBoxDecoration.copyWith(
                color: e == c.selectedDuration ? null : Colors.grey.shade200))
            .scale()
            .onTap(c.isTokenEmpty
                ? null
                : () {
                    c.changeDuration(e);
                  }),
      )
      .toList()
      .wrap
      .crossCenter()
      .end()
      .spacing(15)
      .runSpacing(15)
      .niku()
      .fullWidth();

  Widget _buildPoolName(FixedSwapCreateController c) => 'Input Pool Name'
      .textField
      .enabled(!c.isTokenEmpty)
      .labelFontSize(14)
      .textEditingController(c.poolNameController.textController)
      .focusNode(c.poolNameController.focusNode)
      .maxLines(1)
      .expands(false)
      .maxLength(15)
      .validator(c.poolNameController.validator)
      .hintText('Inwza007 Presale')
      .floatingLabelBehavior(FloatingLabelBehavior.never)
      .isDense(true)
      .cursorColor(kBlack)
      .errorText(c.poolNameController.tokenIsError
          ? c.poolNameController.errorText
          : null)
      .onEditingComplete(() {})
      .onChanged((val) {
        c.poolNameController.validate();
        //c.update();
      })
      .suffix(
        Icon(CupertinoIcons.doc_on_clipboard_fill, size: 16)
            .scale()
            .onTap(() async {
              final text = await FlutterClipboard.paste();
              c.tokenController.changeTextControllerValue(text);
            })
            .niku()
            .padding(EdgeInsets.only(right: 10)),
      )
      .niku()
      .width(300);

  Widget _buildRatio(FixedSwapCreateController c) =>
      'Input Your Pool Swap Ratio'
          .textField
          .enabled(!c.isTokenEmpty)
          .labelFontSize(14)
          .textEditingController(c.ratioController.textController)
          .focusNode(c.ratioController.focusNode)
          .maxLines(1)
          .expands(false)
          //.maxLength(20)
          .validator(c.ratioController.validator)
          .hintText('101200')
          .floatingLabelBehavior(FloatingLabelBehavior.never)
          .isDense(true)
          .cursorColor(kBlack)
          .errorText(c.ratioController.tokenIsError
              ? c.ratioController.errorText
              : null)
          .onChanged((val) {
            c.ratioController.validate();
            //c.update();
          })
          .prefix(
            [
              '1 ${c.selectedCurrency!.symbol} for'
                  .text(TypeWeight.bold)
                  .niku()
                  .padding(EdgeInsets.only(right: 10)),
              //Niku().width(5),
              //'100%'.text(TypeWeight.bold).scale().onTap(() {
              //c.amountController!.changeTextControllerValue(
              //toDecimal(c.currentTokenBalance).toString(),
              //);
              //}),
            ].row.mainSize(MainAxisSize.min),
          )
          .suffix(
            '${c.isTokenEmpty ? '' : c.currentToken.first.symbol}'
                .text(TypeWeight.bold)
                .niku()
                .padding(EdgeInsets.only(left: 10)),
          )
          .niku()
          .width(400);

  Widget _buildSectionHeader(String sectionName, String tooltipText) => [
        '$sectionName'.text(TypeWeight.bold).fontSize(16),
        Niku().width(5),
        infoTooltip('$tooltipText'),
      ].row.crossCenter().mainSize(MainAxisSize.min);
}
