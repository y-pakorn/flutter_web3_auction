import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RedirectPage extends StatefulWidget {
  final String redirectRoute;
  const RedirectPage(this.redirectRoute, {Key? key}) : super(key: key);

  static String routeName = '/404';

  @override
  _RedirectPageState createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  bool inRedirect = false;

  redirect() async {
    if (!inRedirect) {
      inRedirect = true;
      await 1.seconds.delay();
      Get.offAndToNamed(widget.redirectRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    redirect();
    return Scaffold();
  }
}
