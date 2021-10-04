import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../utils.dart';
import 'account_large.dart';
import 'logo_large.dart';
import 'navigation_bar.dart';

Widget _buildIconLink(
  String name,
  IconData icon,
  String url,
) {
  return [
    Icon(icon, size: 14),
    name.text(TypeWeight.bold).fontSize(12),
  ].column.crossCenter().mainSize(MainAxisSize.min).scale().launch(url);
}

class PageLayout extends StatelessWidget {
  //final Widget topChild;
  final Widget bottomChild;

  const PageLayout({
    Key? key,
    //required this.topChild,
    required this.bottomChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: [
          [
            Spacer(),
            Expanded(
              flex: kFlex,
              child: [
                LogoLarge(),
                Spacer(),
                AccountLarge(),
              ].row.crossCenter(),
            ),
            Spacer(),
          ].row.crossCenter().niku().backgroundColor(kWhite).height(70),
          [
            Spacer(),
            Expanded(
              flex: kFlex,
              child: NavigationBar(),
            ),
            Spacer(),
          ]
              .row
              .crossCenter()
              .niku()
              .padding(EdgeInsets.only(bottom: 10, top: 5))
              .backgroundColor(kWhite),
          Niku().height(20),
          [
            Spacer(),
            Expanded(
              flex: kFlex,
              child: bottomChild,
            ),
            Spacer(),
          ].row.crossCenter(),
          [
            Spacer(),
            Expanded(
              flex: kFlex,
              child: [
                [
                  [
                    Divider(thickness: 2, height: 60, color: kBlack),
                    '$urlPrefixWithoutHttp is a decentralized auction/marketplace application protocol.'
                        .text()
                        .fontSize(12)
                        .start(),
                    'Protocol\'s user must be concious and only proceed with great consideration of your own risk.'
                        .text()
                        .fontSize(12)
                        .start(),
                  ].column.mainStart(),
                ].wrap,
                Niku().height(20),
                [
                  _buildIconLink('Docs', FontAwesomeIcons.book, ''),
                  _buildIconLink('Twitter', FontAwesomeIcons.twitter, ''),
                  _buildIconLink('Medium', FontAwesomeIcons.medium, ''),
                ].wrap.crossCenter().spacing(15),
              ].column,
            ),
            Spacer(),
          ].row.crossCenter(),
          Niku().height(50),
        ].column.crossCenter(),
      ),
    );
  }
}
