import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';

import '../../controllers/fixed_swap/home_controller.dart';
import '../../controllers/web3controller.dart';
import '../../routes.dart';
import '../../utils.dart';
import '../../widgets/layout.dart';
import 'create.dart';
import 'widgets/create_listing.dart';
import 'widgets/fixed_pool_mini.dart';
import 'widgets/paginate.dart';

Widget _gridBuilder(int itemCount, IndexedWidgetBuilder itemBuilder) =>
    GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 320,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

class FixedSwapHomePage extends StatelessWidget {
  static String routeName = Routes.fixedSwapPrefix + '/';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Web3Controller>(
      builder: (w3) {
        return GetBuilder<FixedSwapHomeController>(
          builder: (h) {
            bool usePlaceholder =
                !w3.isConnectedAndInSupportedChain || h.isLoadingItem;
            return PageLayout(
              bottomChild: [
                [
                  CreateListing(
                    textToDisplay: 'Create Pool',
                    color: usePlaceholder ? kGrey : null,
                    bgColor: usePlaceholder ? kLightGrey : null,
                    icon: CupertinoIcons.add,
                    padding: roundedBoxPaddingBig,
                  ).changePage(
                      usePlaceholder ? null : FixedSwapCreatePage.routeName),
                  CreateListing(
                    textToDisplay:
                        h.isYourPool ? 'View all pool' : 'View your pool',
                    color: usePlaceholder ? kGrey : null,
                    bgColor: usePlaceholder ? kLightGrey : null,
                    icon: CupertinoIcons.search,
                    padding: roundedBoxPaddingBig,
                  ).onTap(usePlaceholder
                      ? null
                      : () {
                          h.togggleYourPool(!h.isYourPool);
                        }),
                ].wrap.spacing(15).runSpacing(15).crossCenter(),
                Divider(thickness: 2, height: 60, color: kBlack),
                [
                  Niku(),
                  usePlaceholder ? PaginatePlaceholder() : Paginate(),
                ].wrap.spaceBetween().crossCenter().niku().fullWidth(),
                Divider(thickness: 2, height: 60, color: kBlack),
                //Niku().height(10),
                usePlaceholder
                    ? _gridBuilder(
                        h.pageController.maxItemPerPage,
                        (_, __) => FixedPoolMiniPlaceholder(),
                      )
                    : _gridBuilder(
                        h.pageController.itemInThisPage,
                        (_, index) => FixedPoolMini(h.currentPoolList[index]),
                      ),
              ].column.crossStart().mainSize(MainAxisSize.min),
            );
          },
        );
      },
    );
  }
}
