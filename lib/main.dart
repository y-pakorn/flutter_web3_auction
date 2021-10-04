import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';

import 'controllers/web3controller.dart';
import 'pages/fixed_swap/home.dart';
import 'routes.dart';
import 'utils.dart';

void main() async {
  setPathUrlStrategy();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: urlPrefixWithoutHttp,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: kBlack,
        textTheme:
            GoogleFonts.mPlusRounded1cTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: kScaffold,
      ),
      initialBinding: BindingsBuilder(() {
        final web3 = Get.put<Web3Controller>(Web3Controller(), permanent: true);
        web3.connectToLocalProvider();
      }),
      getPages: Routes.pages,
      initialRoute: Routes.initialRoute,
      unknownRoute: Routes.unknownPage,
      defaultTransition: Transition.fadeIn,
      transitionDuration: 150.milliseconds,
    );
  }
}
