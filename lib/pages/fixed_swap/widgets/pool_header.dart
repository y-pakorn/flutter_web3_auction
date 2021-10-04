import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/web3controller.dart';
import '../../../models/pool.dart';
import '../../../models/token.dart';
import '../../../utils.dart';

class PoolHeaderPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      placeholderBox(200, 30),
      Niku().height(10),
      [
        placeholderBox(80, 30),
        placeholderBox(40, 30),
      ].wrap.center().spacing(20),
      Niku().height(10),
      placeholderBox(120, 20),
      Niku().height(10),
      [
        placeholderBox(80, 20),
        placeholderBox(100, 20),
        placeholderBox(100, 20),
      ].wrap.center().spacing(20),
    ].column;
  }
}

class PoolHeader extends StatelessWidget {
  final Pool pool;

  const PoolHeader(this.pool, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name ?? '';

    return [
      '${pool.name}'.text(TypeWeight.extraBold).fontSize(26),
      [
        [
          Niku()
              .boxDecoration(BoxDecoration(
                  shape: BoxShape.circle, color: pool.status.color))
              .width(10)
              .height(10),
          Niku().width(5),
          pool.status.string
              .toUpperCase()
              .text(TypeWeight.extraBold)
              .color(pool.status.color)
              .fontSize(16),
        ].row.crossCenter().mainSize(MainAxisSize.min),
        '#${pool.index}'.text(TypeWeight.medium).color(kGrey).fontSize(16),
      ].wrap.crossCenter().spacing(20),
      Niku().height(10),
      [
        'by'.text(),
        pool.creatorAddress
            .substring(0, 10)
            .text()
            .textDecoration(TextDecoration.underline)
            .launchAddress(pool.creatorAddress),
      ].wrap.center().spacing(5),
      Niku().height(10),
      [
        _buildButton(
            'Copy link',
            CupertinoIcons.doc_on_clipboard,
            routeName.isEmpty
                ? null
                : () {
                    FlutterClipboard.copy(urlPrefix + routeName);
                  }),
        _buildButton('Share in Twitter', FontAwesomeIcons.twitter, null).launch(
          routeName.isEmpty
              ? null
              : 'https://twitter.com/intent/tweet?text=Pool%20${pool.name.trim().replaceAll(' ', '%20')}%20is%20now%20launched%20on%20$urlPrefixWithoutHttp!\n\n&url=${urlPrefix + routeName}',
        ),
        _buildButtonMetamask(
            'Add to Metamask', FontAwesomeIcons.firefox, pool.token0!),
      ].wrap.crossCenter().spacing(20).runSpacing(10),
    ].column;
  }
}

Widget _buildButton(String text, IconData icon, void Function()? onTap) => [
      text.text(TypeWeight.bold).fontSize(12),
      Icon(icon, size: 14),
    ].wrap.crossCenter().spacing(5).niku().scale().onTap(onTap);

Widget _buildButtonMetamask(String text, IconData icon, Token token) => [
      text.text(TypeWeight.bold).fontSize(12),
      Icon(icon, size: 14),
    ].wrap.crossCenter().spacing(5).niku().scale().onTap(() async {
      await Web3Controller.to.addTokenToWatchList(token);
    });
