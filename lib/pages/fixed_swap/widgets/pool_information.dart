import 'package:decimal/decimal.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niku/niku.dart';
import 'package:typeweight/typeweight.dart';

import '../../../controllers/fixed_swap/contract_controller.dart';
import '../../../controllers/fixed_swap/pool_controller.dart';
import '../../../controllers/web3controller.dart';
import '../../../models/pool.dart';
import '../../../utils.dart';

class PoolInformationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      _poolToken(),
      [
        placeholderBox(100, 30),
        placeholderBox(50, 30),
        placeholderBox(70, 30),
        placeholderBox(100, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolCurrency(),
      [
        placeholderBox(100, 30),
        placeholderBox(50, 30),
        placeholderBox(70, 30),
        placeholderBox(100, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolTotalToken(),
      [
        placeholderBox(40, 30),
        placeholderBox(60, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolRatio(),
      [
        placeholderBox(20, 30),
        placeholderBox(100, 30),
        placeholderBox(60, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolPrice(),
      [
        placeholderBox(20, 30),
        placeholderBox(100, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolAllocation(),
      [
        placeholderBox(100, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolClaimDelay(),
      [
        placeholderBox(80, 30),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
    ].column;
  }
}

class PoolInformation extends StatelessWidget {
  final Pool pool;

  const PoolInformation(this.pool, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final p = Get.find<FixedSwapPoolController>();
    return [
      _poolToken(),
      [
        if (pool.token0!.name != null) ...[
          '${pool.token0!.name ?? ''}'.text(TypeWeight.extraBold).fontSize(16),
          '-'.text(),
        ],
        '${pool.token0!.symbol}'.text(TypeWeight.extraBold).fontSize(16),
        [
          '(${pool.token0!.address.substring(0, 8)})'
              .text()
              .fontSize(12)
              .textDecoration(TextDecoration.underline)
              .launchAddress(pool.token0!.address),
          '${pool.token0!.decimal} decimals'.text().fontSize(12).height(0.95),
        ].column,
        [
          FutureBuilder<BigInt>(
            future: ContractController().getBalanceOf(
                pool.token0Address, Web3Controller.to.selectedAddress),
            initialData: BigInt.zero,
            builder: (_, snapshot) =>
                'Balance: ${processDecimal(toDecimal(snapshot.data ?? BigInt.zero, pool.token0!.decimal))}'
                    .text(FontWeight.bold),
          ),
        ]
            .wrap
            .crossCenter()
            .niku()
            .padding(roundedBoxPadding)
            .boxDecoration(roundedBoxDeco)
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolCurrency(),
      [
        '${pool.currency.symbol}'.text(TypeWeight.extraBold).fontSize(16),
        [
          (pool.paidInNativeToken
                  ? 'Native'
                  : pool.currency.address.substring(0, 8))
              .text()
              .fontSize(12)
              .textDecoration(TextDecoration.underline)
              .launchAddress(
                  pool.paidInNativeToken ? null : pool.token0!.address),
          '18 decimals'.text().fontSize(12).height(0.95),
        ].column,
        [
          'Balance: ${processDecimal(toDecimal(p.currentBalance))}'
              .text(FontWeight.bold),
        ]
            .wrap
            .crossCenter()
            .niku()
            .padding(roundedBoxPadding)
            .boxDecoration(roundedBoxDeco)
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolTotalToken(),
      [
        toDecimal(pool.amountTotalToken0)
            .toString()
            .text(TypeWeight.extraBold)
            .fontSize(16),
        pool.token0!.symbol.text(TypeWeight.bold).fontSize(16),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolRatio(),
      [
        '≈ ${processDecimal(pool.ratio)}'
            .text(TypeWeight.extraBold)
            .fontSize(16),
        '${pool.token0!.symbol}/${pool.currency.symbol}'
            .text(TypeWeight.bold)
            .fontSize(16),
      ].wrap.crossCenter().spacing(10).runSpacing(10).end().niku().fullWidth(),
      _poolPrice(),
      [
        if (pool.paidInNativeToken)
          FutureBuilder<Decimal>(
            initialData: Decimal.zero,
            future: Web3Controller.to.fetchNativeTokenPriceThisChain(),
            builder: (_, snapshot) {
              final perUsd = pool.ratio * (snapshot.data ?? Decimal.zero);
              return '≈ ${processDecimal(perUsd == Decimal.zero ? Decimal.zero : perUsd.inverse)}$nativeCurrency'
                  .text(TypeWeight.extraBold)
                  .fontSize(16);
            },
          )
        else
          '≈ ${processDecimal(pool.ratio)}$nativeCurrency'
              .text(TypeWeight.extraBold)
              .fontSize(16),
      ].wrap.crossCenter().end().spacing(10).niku().fullWidth(),
      _poolAllocation(),
      [
        (pool.isUnlimitedPerWallet ? 'Unlimited' : 'Limited')
            .text(TypeWeight.extraBold)
            .fontSize(16),
        if (!pool.isUnlimitedPerWallet)
          '${processDecimal(toDecimal(pool.maxPerWallet))} ${pool.currency.symbol}'
              .text(TypeWeight.bold)
              .fontSize(16),
      ].wrap.crossCenter().end().spacing(10).niku().fullWidth(),
      _poolClaimDelay(),
      [
        (pool.isNoClaimDelay ? 'Instantly' : 'After Pool Closed')
            .text(TypeWeight.extraBold)
            .fontSize(16),
        if (!pool.isNoClaimDelay)
          prettyDuration(pool.claimDelay).text(TypeWeight.bold).fontSize(16),
      ].wrap.crossCenter().end().spacing(10).niku().fullWidth(),
    ].column.mainSize(MainAxisSize.min);
  }
}

Widget _poolToken() => [
      'Token'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip('Token that this pool is offering')
    ].row.crossCenter().paddingSymmetric(vertical: 5);

Widget _poolTotalToken() => [
      'Total Token Offered'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip('Total amount of token that is in this pool')
    ].row.crossCenter().paddingSymmetric(vertical: 5);

Widget _poolCurrency() => [
      'Pool Currency'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip('Token that this pool is used as currency')
    ].row.crossCenter().paddingSymmetric(vertical: 5);

Widget _poolRatio() => [
      'Pool Swap Ratio'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip(
          'Amount of token that you would get after spending one ether in pool\'s currency')
    ].row.crossCenter().paddingSymmetric(vertical: 5);

Widget _poolPrice() => [
      'Price Per Token'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip('Price of one token in USD')
    ].row.crossCenter().paddingSymmetric(vertical: 5);

Widget _poolAllocation() => [
      'Maximum Swap Per Wallet'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip(
          'Maximum amount limit that one wallet could swap in this pool')
    ].row.crossCenter().paddingSymmetric(vertical: 5);

Widget _poolClaimDelay() => [
      'Token Recieve Time'.text(TypeWeight.bold).fontSize(18),
      Niku().width(5),
      infoTooltip(
          'Time that you will receieve your token after joining the pool')
    ].row.crossCenter().paddingSymmetric(vertical: 5);
