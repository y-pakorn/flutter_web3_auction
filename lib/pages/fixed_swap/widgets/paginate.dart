import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';

import '../../../controllers/fixed_swap/home_controller.dart';
import '../../../utils.dart';

class PaginatePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      'page 1'
          .text(FontWeight.bold)
          .niku()
          .padding(EdgeInsets.symmetric(horizontal: 5)),
      Icon(CupertinoIcons.arrow_clockwise, size: 14).scale(),
      'next'.text().niku().padding(EdgeInsets.symmetric(horizontal: 5)).scale(),
      'last'
          .text()
          .textDecoration(TextDecoration.underline)
          .niku()
          .padding(EdgeInsets.symmetric(horizontal: 5))
          .scale(),
    ].row.mainSize(MainAxisSize.min).crossCenter();
  }
}

class Paginate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final h = Get.find<FixedSwapHomeController>();
    return [
      if (!h.pageController.isFirstPage) ...[
        'first'
            .text()
            .textDecoration(TextDecoration.underline)
            .niku()
            .padding(EdgeInsets.symmetric(horizontal: 5))
            .scale()
            .onTap(h.isLoadingItem
                ? null
                : () {
                    h.changePage(h.pageController.firstPage);
                  }),
        'prev'
            .text()
            .niku()
            .padding(EdgeInsets.symmetric(horizontal: 5))
            .scale()
            .onTap(h.isLoadingItem
                ? null
                : () {
                    h.changePage(h.pageController.currentPage - 1);
                  }),
      ],
      'page ${h.pageController.currentPage}'
          .text(FontWeight.bold)
          .niku()
          .padding(EdgeInsets.symmetric(horizontal: 5)),
      Icon(CupertinoIcons.arrow_clockwise, size: 14)
          .scale()
          .onTap(h.isLoadingItem
              ? null
              : () {
                  h.changePage(h.pageController.currentPage);
                })
          .showTooltip('Refresh this page'),
      if (!h.pageController.isLastPage) ...[
        'next'
            .text()
            .niku()
            .padding(EdgeInsets.symmetric(horizontal: 5))
            .scale()
            .onTap(h.isLoadingItem
                ? null
                : () {
                    h.changePage(h.pageController.currentPage + 1);
                  }),
        'last'
            .text()
            .textDecoration(TextDecoration.underline)
            .niku()
            .padding(EdgeInsets.symmetric(horizontal: 5))
            .scale()
            .onTap(h.isLoadingItem
                ? null
                : () {
                    h.changePage(h.pageController.lastPage);
                  }),
      ],
    ].row.mainSize(MainAxisSize.min).crossCenter();
  }
}
