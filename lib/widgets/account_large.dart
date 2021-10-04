import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../controllers/web3controller.dart';
import '../utils.dart';

class AccountLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    return GetBuilder<Web3Controller>(
      builder: (w3) {
        if (w3.isConnectedAndInSupportedChain)
          return _build(
            isSmall,
            true,
            false,
            w3.selectedAddress,
            w3.currentChain!.name,
            w3.getChainId(),
            SvgPicture.asset(
              w3.currentChain!.logoAsset,
              fit: BoxFit.scaleDown,
              //height: 25,
            ),
          );
        else if (w3.isConnectedAndInKnownChain)
          return _build(
            isSmall,
            false,
            false,
            w3.selectedAddress,
            w3.currentChain!.name,
            w3.getChainId(),
            SvgPicture.asset(
              w3.currentChain!.logoAsset,
              fit: BoxFit.scaleDown,
            ),
          );
        else if (w3.isConnectedButInUnknownChain)
          return _build(
            isSmall,
            false,
            true,
            w3.selectedAddress,
            'Unknown Chain',
            w3.getChainId(),
            SvgPicture.asset(
              'assets/unknown.svg',
              fit: BoxFit.scaleDown,
            ),
          );
        else
          return (isSmall ? 'Connect' : 'Connect Wallet')
              .text(TypeWeight.bold)
              .fontSize(16)
              .niku()
              .padding(roundedBoxPadding)
              .boxDecoration(roundedBoxDeco)
              .scale()
              .onTap(() {
            w3.connectToLocalProvider();
          });
      },
    );
  }
}

Widget _build(
  bool isSmall,
  bool isSupported,
  bool isUnknownChain,
  String address,
  String chainName,
  int chainId, [
  Widget? prefix,
]) {
  BoxDecoration deco = BoxDecoration(
    color: kWhite,
    shape: BoxShape.circle,
  );
  //border: Border.all(color: kBlack));
  return [
    [
      if (prefix != null)
        prefix
            .niku()
            .center()
            .width(25)
            .height(25)
            .padding(EdgeInsets.all(5))
            .boxDecoration(deco)
      else
        '?'
            .text(TypeWeight.extraBold)
            .fontSize(25)
            .niku()
            .center()
            .width(30)
            .height(30),
      //.boxDecoration(deco),
      if (isSmall && !isSupported)
        infoTooltip('Chain not supported, please change chain'),
    ].row.crossEnd(),
    if (!isSmall) Niku().width(5),
    if (!isSmall)
      [
        (isUnknownChain ? chainName + ' ($chainId)' : chainName)
            .text(TypeWeight.bold)
            .fontSize(16),
        [
          address.substring(0, 8).text(),
          Niku().width(5),
          Icon(CupertinoIcons.doc_on_doc, size: 14)
              .showTooltip('Copy address')
              .scale()
              .onTap(() {
            FlutterClipboard.copy(address);
          }),
          if (!isUnknownChain) Niku().width(5),
          if (!isUnknownChain)
            Icon(CupertinoIcons.arrow_up_right, size: 14)
                .showTooltip('Open in block explorer')
                .scale()
                .launchAddress(address),
          if (!isSupported) Niku().width(5),
          if (!isSupported)
            infoTooltip('Chain not supported, please change chain'),
        ].row.crossCenter(),
      ].column.mainCenter().crossStart(),
  ].row.mainCenter().crossCenter().niku().padding(EdgeInsets.all(5));
}
