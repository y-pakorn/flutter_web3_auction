import 'package:flutter/material.dart';
import 'package:typeweight/typeweight.dart';

import '../routes.dart';
import '../utils.dart';

class LogoLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    return [
      (isSmall
              ? '${urlPrefixWithoutHttp.split('.').first}'
              : '$urlPrefixWithoutHttp')
          .text(TypeWeight.black)
          .fontSize(26),
    ].wrap.crossCenter().changePagePop(Routes.initialRoute);
  }
}
