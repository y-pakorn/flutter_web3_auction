import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../controllers/fixed_swap/create_controller.dart';
import '../../controllers/web3controller.dart';
import '../../routes.dart';
import '../../utils.dart';
import '../../widgets/layout.dart';
import 'widgets/create_listing.dart';
import 'widgets/pool_settings.dart';
import 'widgets/token_contract_form.dart';

class FixedSwapCreatePage extends StatelessWidget {
  static String routeName = Routes.fixedSwapPrefix + '/create';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Web3Controller>(
      builder: (w3) => GetBuilder<FixedSwapCreateController>(
        builder: (c) => PageLayout(
          bottomChild: [
            //if (!w3.isConnectedAndInSupportedChain) ...[
            [
              'Create Fixed Swap Pool'.text(TypeWeight.extraBold).fontSize(22),
              [
                [
                  'ITO/ICO'.text(TypeWeight.extraBold).fontSize(16),
                  infoTooltip(
                      'ITO: Initial Token Offering\nICO: Initial Coin Offering'),
                ]
                    .wrap
                    .spacing(5)
                    .crossCenter()
                    .niku()
                    .padding(roundedBoxPadding)
                    .boxDecoration(roundedBoxDeco),
                'Guide'
                    .text(TypeWeight.extraBold)
                    .fontSize(16)
                    .niku()
                    .padding(roundedBoxPadding)
                    .boxDecoration(roundedBoxDeco),
              ].wrap.crossCenter().spacing(10)
            ]
                .wrap
                .crossCenter()
                .spaceBetween()
                .runSpacing(10)
                .niku()
                .fullWidth(),
            Divider(thickness: 2, height: 60, color: kBlack),
            if (MediaQuery.of(context).size.width > 1200)
              [
                Expanded(
                  child: w3.isConnectedAndInSupportedChain
                      ? TokenContractForm()
                      : TokenContractFormPlaceholder(),
                ),
                VerticalDivider(thickness: 2, width: 40, color: kBlack),
                Expanded(
                  child: w3.isConnectedAndInSupportedChain
                      ? PoolSettings()
                      : PoolSettingsPlaceholder(),
                ),
              ].row.crossEnd()
            else ...[
              w3.isConnectedAndInSupportedChain
                  ? TokenContractForm()
                  : TokenContractFormPlaceholder(),
              Divider(thickness: 2, height: 60, color: kBlack),
              w3.isConnectedAndInSupportedChain
                  ? PoolSettings()
                  : PoolSettingsPlaceholder(),
            ],
            Divider(thickness: 2, height: 60, color: kBlack),
            [
              [
                CreateListing(
                  textToDisplay: 'Create Pool',
                  color: w3.isConnectedAndInSupportedChain ? null : kGrey,
                  bgColor:
                      w3.isConnectedAndInSupportedChain ? null : kLightGrey,
                  fontSize: 20,
                  icon: CupertinoIcons.plus,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ).onTap(c.isTokenEmpty
                    ? null
                    : () async {
                        await c.createPool();
                      }),
              ].row.mainSize(MainAxisSize.min),
              [
                CreateListing(
                  textToDisplay: 'Clear All',
                  color: w3.isConnectedAndInSupportedChain ? null : kGrey,
                  bgColor:
                      w3.isConnectedAndInSupportedChain ? null : kLightGrey,
                  fontSize: 20,
                  icon: CupertinoIcons.xmark,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ).onTap(c.isTokenEmpty
                    ? null
                    : () async {
                        await c.createPool();
                      }),
              ].row.mainSize(MainAxisSize.min),
            ].wrap.crossCenter().center().spacing(15).niku().fullWidth(),
          ].column.crossStart().mainSize(MainAxisSize.min),
        ).supportTapUnfocus(context),
      ),
    );
  }
}
