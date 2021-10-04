import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../controllers/fixed_swap/pool_controller.dart';
import '../../controllers/web3controller.dart';
import '../../extensions.dart';
import '../../routes.dart';
import '../../utils.dart';
import '../../widgets/layout.dart';
import 'home.dart';
import 'widgets/claim_pool.dart';
import 'widgets/join_pool.dart';
import 'widgets/pool_header.dart';
import 'widgets/pool_information.dart';

class FixedSwapPoolPage extends StatelessWidget {
  static String routeName = Routes.fixedSwapPrefix + '/pool/:id';

  static String routeNameFromIndex(int index) =>
      Routes.fixedSwapPrefix + '/pool/$index';

  @override
  Widget build(BuildContext context) {
    //Get.lazyPut<FixedSwapPoolController>(

    return GetBuilder<Web3Controller>(
      builder: (w3) => GetBuilder<FixedSwapPoolController>(
        builder: (p) => PageLayout(
          bottomChild: [
            [
              Icon(CupertinoIcons.chevron_back)
                  .scale()
                  .changePagePop(FixedSwapHomePage.routeName),
              'Fixed Swap Pool'.text(TypeWeight.bold),
              Niku(),
            ]
                .wrap
                .spaceBetween()
                .crossCenter()
                .spacing(10)
                .runSpacing(10)
                .niku()
                .fullWidth(),
            Divider(thickness: 2, height: 60, color: kBlack),
            w3.isConnectedAndInSupportedChain && p.poolLoaded
                ? PoolHeader(p.pool!)
                : PoolHeaderPlaceholder(),
            Divider(thickness: 2, height: 60, color: kBlack),
            if (MediaQuery.of(context).size.width > 1200)
              [
                Expanded(
                  child: [
                    [
                      'Pool Information'
                          .text(TypeWeight.extraBold)
                          .fontSize(22),
                    ].row,
                    w3.isConnectedAndInSupportedChain && p.poolLoaded
                        ? PoolInformation(p.pool!)
                        : PoolInformationPlaceholder()
                  ].column,
                ),
                VerticalDivider(thickness: 2, width: 40, color: kBlack),
                Expanded(
                  child: w3.isConnectedAndInSupportedChain && p.poolLoaded
                      ? p.pool!.isCreator
                          ? ClaimPool()
                          : JoinPool()
                      //? JoinPool()
                      : JoinPoolPlaceholder(),
                ),
              ].row.crossCenter().crossEnd()
            else ...[
              [
                'Pool Information'.text(TypeWeight.extraBold).fontSize(22),
              ].row,
              Niku().height(20),
              w3.isConnectedAndInSupportedChain && p.poolLoaded
                  ? PoolInformation(p.pool!)
                  : PoolInformationPlaceholder(),
              Divider(thickness: 2, height: 60, color: kBlack),
              w3.isConnectedAndInSupportedChain && p.poolLoaded
                  ? p.pool!.isCreator
                      ? ClaimPool()
                      : JoinPool()
                  //? JoinPool()
                  : JoinPoolPlaceholder(),
            ],
          ].column.crossCenter(),
        ).supportTapUnfocus(context),
      ),
    );
  }
}
