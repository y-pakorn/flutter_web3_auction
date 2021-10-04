import 'package:flutter/material.dart';
import 'package:typeweight/typeweight.dart';

import '../pages/fixed_swap/home.dart';
import '../routes.dart';
import '../utils.dart';

class NavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      'Fixed Swap'
          .text(ModalRoute.of(context)!
                  .settings
                  .name!
                  .contains(Routes.fixedSwapPrefix)
              ? TypeWeight.extraBold
              : TypeWeight.medium)
          .fontSize(16)
          .changePagePop(FixedSwapHomePage.routeName)
          .moveY(),
      'Dutch Auction'.text(TypeWeight.medium).fontSize(16).color(kGrey).moveY(),
      'Liquidity Lock'
          .text(TypeWeight.medium)
          .fontSize(16)
          .color(kGrey)
          .moveY(),
      'NFTs'.text(TypeWeight.medium).fontSize(16).color(kGrey).moveY(),
    ].wrap.spacing(20).crossCenter();
  }
}
