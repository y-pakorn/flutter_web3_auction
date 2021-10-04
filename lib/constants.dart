import 'package:flutter/material.dart';

const String zeroAddress = '0x0000000000000000000000000000000000000000';
const String deadAddress = '0x000000000000000000000000000000000000dEaD';

const String nativeCurrency = '\$';

const String createPoolHash =
    '0xf0c7ec244d49d58eef14e694e65db680ae31537c7ec51dac51dfec1cddec8786';

const String urlPrefix = 'https://auction.yoisha.dev';
const String urlPrefixWithoutHttp = 'auction';

const double kFeesPercent = 2.00;

const Duration kAccountPollingRate = Duration(seconds: 5);
const Duration kPollingRate = Duration(seconds: 5);

const int kFlex = 6;

const Color kLightGrey = Color(0xFFE0E0E0);
const Color kGrey = Color(0xFFBDBDBD);
const Color kDarkerGrey = Color(0xFF757575);
const Color kDarkGrey = Color(0xFF9E9E9E);
const Color kScaffold = Color(0xFFF5F5F5);
const Color kBlack = Colors.black;
const Color kWhite = Colors.white;
const Color kRed = Color(0xFFBD1F36);
const Color kDarkRed = Color(0xFF85182A);
const Color kDarkGreen = Color(0xFF296813);
const Color kGreen = Color(0xFF3E9639);
const Color kLightGreen = Color(0xFF96E072);

List<BoxShadow> get defaultShadow => [
      BoxShadow(
        color: Colors.grey.shade400.withOpacity(0.3),
        offset: Offset(2, 2),
        blurRadius: 2,
        spreadRadius: 1,
      )
    ];

BoxDecoration get defaultPoolItemBoxDecoration => BoxDecoration(
      color: Colors.white,
      boxShadow: defaultShadow,
      borderRadius: BorderRadius.circular(20),
    );

BoxDecoration get roundedBoxDeco => BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: kBlack,
        width: 2,
      ),
    );

const EdgeInsets roundedBoxPadding =
    EdgeInsets.symmetric(vertical: 5, horizontal: 10);

const EdgeInsets roundedBoxPaddingBig =
    EdgeInsets.symmetric(vertical: 10, horizontal: 15);
