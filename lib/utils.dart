import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:niku/niku.dart';

import 'constants.dart';
import 'extensions.dart';

export 'constants.dart';
export 'extensions.dart';

void changePagePop(String routeName) {
  if (routeName.isNotEmpty && Get.currentRoute != routeName)
    Get.offNamedUntil(routeName, ModalRoute.withName(routeName));
}

String? defaultDecimalValidator(String? val) {
  if (val == null || val.isEmpty) return 'empty value';
  if (Decimal.tryParse(val) == null || Decimal.parse(val).isNegative)
    return 'wrong value';
  if (Decimal.parse(val) == Decimal.zero) return 'zero value';
  return null;
}

String? defaultTokenValidator(String? val) {
  if (val == null || val.isEmpty) return 'empty address';
  if (val.length != 42) return 'address length != 42';
  if (!val.startsWith('0x')) return 'address prefix is not 0x';
  if (!val.startsWith(RegExp(r'[a-zA-Z0-9]{42}')))
    return 'address contains special character';
  return null;
}

String formatToReadable(dynamic number) =>
    NumberFormat.compact().format(number);

Widget infoTooltip(String tooltipText,
        {double size = 14, Color color = kGrey}) =>
    Icon(CupertinoIcons.info, size: 14, color: kGrey).showTooltip(tooltipText);

Widget placeholderBox([double width = 40, double height = 20]) =>
    Niku().height(height).width(width).boxDecoration(
          BoxDecoration(
            color: kGrey,
            borderRadius: BorderRadius.circular(10),
          ),
        );

String processDecimal(Decimal dec) {
  final int decLength = dec.toString().split('.').last.length;
  final int intLength = dec.toString().split('.').first.length;
  if (dec.hasFinitePrecision) {
    if (intLength > 8) return formatToReadable(dec.toInt());
    if (decLength < 4)
      return dec.toString();
    else
      return dec.toStringAsFixed(4);
  }
  return dec.toStringAsFixed(4);
}

BigInt toBase(Decimal amount, [int decimals = 18]) {
  Decimal baseUnit = Decimal.fromInt(10).pow(decimals);
  Decimal inbase = amount * baseUnit;

  return BigInt.parse(inbase.toString());
}

Decimal toDecimal(BigInt amount, [int decimals = 18]) {
  Decimal baseUnit = Decimal.fromInt(10).pow(decimals);

  var d = Decimal.parse(amount.toString());
  d = d / baseUnit;

  return d;
}
