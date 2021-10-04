import 'package:get/get.dart';

import 'controllers/fixed_swap/create_controller.dart';
import 'controllers/fixed_swap/home_controller.dart';
import 'controllers/fixed_swap/pool_controller.dart';
import 'pages/fixed_swap/create.dart';
import 'pages/fixed_swap/home.dart';
import 'pages/fixed_swap/pool.dart';
import 'pages/redirect.dart';

class Routes {
  static String fixedSwapPrefix = '/fixed-swap';
  static String initialRoute = FixedSwapHomePage.routeName;

  static GetPage unknownPage = GetPage(
    name: RedirectPage.routeName,
    page: () => RedirectPage(FixedSwapHomePage.routeName),
  );

  static List<GetPage> pages = [
    GetPage(
      name: FixedSwapHomePage.routeName,
      page: () => FixedSwapHomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FixedSwapHomeController>(() => FixedSwapHomeController());
      }),
    ),
    GetPage(
      name: FixedSwapPoolPage.routeName,
      page: () => FixedSwapPoolPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FixedSwapPoolController>(() =>
            FixedSwapPoolController(int.parse(Get.parameters['id'] ?? '-1')));
      }),
    ),
    GetPage(
      name: FixedSwapCreatePage.routeName,
      page: () => FixedSwapCreatePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FixedSwapCreateController>(
            () => FixedSwapCreateController());
      }),
    ),
    //GetPage(
    //name: fixedSwapPrefix + '/pool',
    //page: () => RedirectPage(FixedSwapHome.routeName)),
  ];
}
