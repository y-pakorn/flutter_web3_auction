import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/fixed_swap/create_controller.dart';
import '../../../utils.dart';

class TokenContractForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<FixedSwapCreateController>();

    _fetch() async {
      c.tokenController.focusNode.unfocus();
      await c.fetchToken();
    }

    return [
      'Token Contract'.text(TypeWeight.bold).fontSize(18),
      [
        Flexible(
          child: 'Input Token Address (0x...)'
              .textField
              .enabled(c.isTokenEmpty)
              .labelFontSize(14)
              .textEditingController(c.tokenController.textController)
              .focusNode(c.tokenController.focusNode)
              .maxLines(1)
              .expands(false)
              .maxLength(42)
              .validator(c.tokenController.validator)
              .hintText('0xe9e7cea3dedca5984780bafc599bd69add087d56')
              .floatingLabelBehavior(FloatingLabelBehavior.never)
              .isDense(true)
              .cursorColor(kBlack)
              .errorText(c.tokenController.tokenIsError
                  ? c.tokenController.errorText
                  : null)
              .onEditingComplete(
                  c.isLoading || !c.isTokenEmpty ? () {} : _fetch)
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
              .width(500),
        ),
        Niku().width(10),
        Icon(CupertinoIcons.search, size: 26)
            .scale(1.25)
            .onTap(c.isLoading || !c.isTokenEmpty ? null : _fetch)
            .showTooltip('Search for this token'),
        Niku().width(10),
        Icon(CupertinoIcons.xmark, size: 26)
            .scale(1.25)
            .onTap(c.isLoading || c.isTokenEmpty ? null : c.clearToken)
            .showTooltip('Clear this token'),
      ].row.crossCenter().mainEnd(),
      Divider(thickness: 1, height: 40, color: kGrey),
      //[
      'Token Information'.text(TypeWeight.bold).fontSize(18),
      if (c.isTokenEmpty)
        ['Token Not Selected'.text(TypeWeight.bold)]
            .wrap
            .crossCenter()
            .end()
            .niku()
            .fullWidth()
      else
        [
          '${c.currentToken.first.name ?? ''}'
              .text(TypeWeight.extraBold)
              .fontSize(16),
          '${c.currentToken.first.symbol}'
              .text(TypeWeight.extraBold)
              .fontSize(16),
          [
            '(${c.currentToken.first.address.substring(0, 8)})'
                .text()
                .fontSize(12)
                .textDecoration(TextDecoration.underline)
                .launchAddress(c.currentToken.first.address),
            '${c.currentToken.first.decimal} decimals'
                .text()
                .fontSize(12)
                .height(0.95),
          ].column,
          [
            'Balance: ${processDecimal(toDecimal(c.currentTokenBalance, c.currentToken.first.decimal))}'
                .text(FontWeight.bold),
            Niku().width(5),
            infoTooltip(
                'Your token balance will relate to max token you could setup your pool'),
          ]
              .wrap
              .crossCenter()
              .niku()
              .padding(roundedBoxPadding)
              .boxDecoration(roundedBoxDeco)
        ]
            .wrap
            .crossCenter()
            .spacing(10)
            .runSpacing(10)
            .end()
            .niku()
            .fullWidth(),
      //].wrap.crossCenter().spaceBetween().runSpacing(10).niku().fullWidth(),
    ].column.crossStart();
  }
}

class TokenContractFormPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      'Token Contract'.text(TypeWeight.bold).fontSize(18),
      Niku().height(10),
      [
        Flexible(
          child: [
            placeholderBox(500, 40),
            Niku().height(5),
            placeholderBox(60, 15),
          ].column.crossEnd(),
        ),
        Niku().width(10),
        Icon(CupertinoIcons.search, size: 26).scale(1.25),
        Niku().width(10),
        Icon(CupertinoIcons.xmark, size: 26).scale(1.25),
      ].row.crossCenter().mainEnd(),
      Divider(thickness: 1, height: 40, color: kGrey),
      'Token Information'.text(TypeWeight.bold).fontSize(18),
      [
        Flexible(child: placeholderBox(250, 30)),
      ].wrap.crossCenter().end().niku().fullWidth()
    ].column.crossStart();
  }
}
