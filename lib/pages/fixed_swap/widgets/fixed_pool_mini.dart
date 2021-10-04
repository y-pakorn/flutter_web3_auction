import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/web3controller.dart';
import '../../../models/pool.dart';
import "../../../utils.dart";
import '../pool.dart';

class FixedPoolMiniPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildBox(double width, [double height = 15]) => Niku()
        .height(height)
        .width(width)
        .boxDecoration(
          BoxDecoration(
            color: kGrey,
            borderRadius: BorderRadius.circular(10),
          ),
        )
        .shimmer;

    return [
      [
        _buildBox(10),
        Niku().width(5),
        _buildBox(25),
        Spacer(),
        _buildBox(30),
      ].row.crossCenter(),
      Niku().height(10),
      _buildBox(150, 20),
      Divider(thickness: 1.5, height: 30),
      [
        _buildBox(30),
        _buildBox(60),
      ].wrap.spacing(5),
      Niku().height(5),
      _buildBox(80),
      Niku().height(20),
      [
        _buildBox(80),
        Spacer(),
        _buildBox(60),
      ].row,
      Niku().height(5),
      [
        _buildBox(50),
        Spacer(),
        _buildBox(60),
      ].row,
      Spacer(),
      Divider(thickness: 1.5, height: 20),
      [
        _buildBox(50),
        Spacer(),
        _buildBox(60),
      ].row,
      Divider(thickness: 1.5, height: 30),
      _buildBox(60, 20),
    ]
        .column
        .niku()
        .padding(EdgeInsets.all(10))
        .boxDecoration(defaultPoolItemBoxDecoration)
        .margin(EdgeInsets.all(5))
        .width(250)
        .height(250);
  }
}

class FixedPoolMini extends StatelessWidget {
  final Pool pool;

  const FixedPoolMini(this.pool, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return [
      [
        Niku()
            .boxDecoration(
                BoxDecoration(shape: BoxShape.circle, color: pool.status.color))
            .width(7)
            .height(7),
        Niku().width(5),
        pool.status.string
            .toUpperCase()
            .text(TypeWeight.extraBold)
            .color(pool.status.color)
            .fontSize(15),
        Spacer(),
        '#${pool.index}'.text(TypeWeight.medium).color(kGrey),
      ].row.crossCenter(),
      Niku().height(10),
      pool.name.text(FontWeight.bold).fontSize(18).bold(),
      Divider(thickness: 1.5, height: 30),
      [
        pool.token0!.symbol.text(TypeWeight.extraBold).fontSize(16),
        '(${pool.token0Address.substring(0, 8)})'
            .text()
            .textDecoration(TextDecoration.underline)
            .launchAddress(pool.token0Address)
      ].wrap.spacing(5).runSpacing(10).crossCenter(),
      'From ${pool.creatorAddress.substring(0, 8)}'
          .text()
          .fontSize(12)
          .launchAddress(pool.creatorAddress),
      Niku().height(10),
      [
        '${pool.token0!.symbol}/${pool.currency.symbol}'
            .text(TypeWeight.medium)
            .color(kDarkGrey)
            .fontSize(13),
        Spacer(),
        '≈ ${processDecimal(pool.ratio)}'.text(TypeWeight.bold),
      ].row.crossCenter(),
      [
        'Price'.text(TypeWeight.medium).color(kDarkGrey).fontSize(13),
        Spacer(),
        if (pool.paidInNativeToken)
          FutureBuilder<Decimal>(
            initialData: Decimal.zero,
            future: Web3Controller.to.fetchNativeTokenPriceThisChain(),
            builder: (_, snapshot) {
              final perUsd = pool.ratio * (snapshot.data ?? Decimal.zero);
              return '≈ ${processDecimal(perUsd == Decimal.zero ? Decimal.zero : perUsd.inverse)}$nativeCurrency'
                  .text();
            },
          )
        else
          '≈ ${processDecimal(pool.ratio)}$nativeCurrency'.text()
        //'≈ xx.xx'.text(TypeWeight.bold),
      ].row.crossCenter(),
      Spacer(),
      Divider(thickness: 1.5, height: 20),
      [
        'Progress'.text(TypeWeight.bold).color(kDarkerGrey),
        Spacer(),
        '${pool.percentSold.toStringAsFixed(2)}%'
            .text(TypeWeight.extraBold)
            .color(pool.isLive ? kGreen : kBlack)
            .niku()
            .padding(roundedBoxPadding)
            .boxDecoration(
              roundedBoxDeco.copyWith(
                border:
                    pool.isLive ? Border.all(color: kGreen, width: 2) : null,
              ),
            )
      ].row.crossCenter(),
      Divider(thickness: 1.5, height: 20),
      (pool.isFilledOrClosed ? 'View Result' : 'Join')
          .text(TypeWeight.extraBold)
          .fontSize(18)
          .scale()
          .changePage(FixedSwapPoolPage.routeNameFromIndex(pool.index))
    ]
        .column
        .niku()
        .padding(EdgeInsets.all(10))
        .boxDecoration(defaultPoolItemBoxDecoration)
        .margin(EdgeInsets.all(5))
        .width(250)
        .height(250);
  }
}
