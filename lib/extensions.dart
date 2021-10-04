import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:niku/niku.dart';
import 'package:shimmer/shimmer.dart';
import 'package:typeweight/typeweight.dart';
import 'package:url_launcher/url_launcher.dart' as l;

import 'controllers/web3controller.dart';
import 'models/chain.dart';
import 'models/pool.dart';
import 'utils.dart';

extension IterableExtension<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}

class WidgetMover extends StatefulWidget {
  final Widget child;
  final double translate;
  final Axis axis;
  const WidgetMover(this.child, this.translate, this.axis);

  @override
  _WidgetMoverState createState() => _WidgetMoverState();
}

class WidgetScaler extends StatefulWidget {
  final Widget child;
  final double scale;
  const WidgetScaler(this.child, this.scale);

  @override
  _WidgetScalerState createState() => _WidgetScalerState();
}

class _WidgetMoverState extends State<WidgetMover> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    var hover = Matrix4.identity()
      ..translate(widget.axis == Axis.horizontal ? widget.translate : 0,
          widget.axis == Axis.vertical ? -widget.translate : 0);
    return MouseRegion(
      //cursor: SystemMouseCursors.click,
      onEnter: (p) => setState(() {
        isHovering = true;
      }),
      onExit: (p) => setState(() {
        isHovering = false;
      }),
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: isHovering ? hover : Matrix4.identity(),
        duration: 200.milliseconds,
        child: widget.child,
      ),
    );
  }
}

class _WidgetScalerState extends State<WidgetScaler> {
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      //cursor: SystemMouseCursors.click,
      onEnter: (p) => setState(() {
        isHovering = true;
      }),
      onExit: (p) => setState(() {
        isHovering = false;
      }),
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: isHovering
            ? Matrix4.identity()
                .scaled(widget.scale, widget.scale, widget.scale)
            : Matrix4.identity(),
        duration: 200.milliseconds,
        child: widget.child,
      ),
    );
  }
}

extension BigIntExtension on BigInt {
  String get string => this.toString();
}

extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}

extension DurationExtension on Duration {
  int get inDaysDiv => this.inDays.remainder(60).toInt();
  int get inHoursDiv => this.inHours.remainder(60).toInt();
  int get inMinutesDiv => this.inMinutes.remainder(60).toInt();
  int get inSecondsDiv => this.inSeconds.remainder(60).toInt();
}

extension IntExtension on int {
  String get paddedTwoZero => this.toString().paddedTwoZero;
}

extension ListWidgetExtension on List<Widget> {
  NikuWrap get wrap => NikuWrap(this);
  NikuColumn get column => NikuColumn(this);
  NikuRow get row => NikuRow(this);
}

extension PoolStatusExtension on PoolStatus {
  String get string => this.toString().split('.').last;

  Color get color {
    switch (this) {
      case PoolStatus.Pending:
        return kGrey;
      case PoolStatus.Live:
        return kGreen;
      case PoolStatus.Closed:
        return kRed;
      case PoolStatus.Filled:
        return kBlack;
    }
  }
}

extension TextExtension on String {
  NikuSelectableText get selectableText => NikuSelectableText(this);
  NikuTextField get textField => NikuTextField(this);
  //NikuText get text => NikuText(this);
  NikuText text([FontWeight fontWeight = TypeWeight.regular]) =>
      NikuText(this).style(GoogleFonts.mPlusRounded1c(fontWeight: fontWeight));
  String get paddedTwoZero => this.padLeft(2, '0');
}

extension WidgetExtension on Widget {
  Widget showTooltip(String? hint) {
    if (hint != null)
      return Tooltip(
        message: hint,
        child: this,
        textStyle:
            TextStyle(fontSize: 14, color: kWhite, fontWeight: TypeWeight.bold),
        padding: EdgeInsets.all(10),
      );
    return this;
  }

  Widget get shimmer => this;

  Widget shimmerEnabled([bool enabled = true]) => Shimmer.fromColors(
        child: this,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        period: 1.5.seconds,
        enabled: enabled,
      );

  Widget onTap(void Function()? function) {
    if (function != null)
      return GestureDetector(
        child: MouseRegion(
          child: this,
          cursor: SystemMouseCursors.click,
        ),
        onTap: function,
      );
    return this;
  }

  Widget launch(String? url) {
    if (url == null || url.isEmpty) return this;
    return onTap(
      () async {
        if (await l.canLaunch(url)) l.launch(url);
      },
    );
  }

  Widget supportTapUnfocus(BuildContext context) => GestureDetector(
        child: this,
        onTap: () {
          if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
        },
      );

  /// Launch Block Explorer; [url] prefix must be '/'
  Widget launchBlockExplorer(String? url) {
    if (url == null) return this;
    Chain? chain = Web3Controller.to.currentChain;
    if (chain != null)
      return launch(chain.blockExplorerUrl + url);
    else
      return this;
  }

  Widget launchAddress(String? url) =>
      launchBlockExplorer(url == null ? null : '/address/$url');

  Widget launchTX(String? tx) =>
      launchBlockExplorer(tx == null ? null : '/tx/$tx');

  Widget launchBlock(String? block) =>
      launchBlockExplorer(block == null ? null : '/block/$block');

  Widget changePage(String? routeName) {
    if (routeName == null) return this;
    return onTap(() {
      if (routeName.isNotEmpty && Get.currentRoute != routeName)
        Get.toNamed(routeName);
      //Get.offNamedUntil(routeName, ModalRoute.withName(routeName));
    });
  }

  Widget changePagePop(String routeName) {
    return onTap(() {
      if (routeName.isNotEmpty && Get.currentRoute != routeName)
        Get.offNamedUntil(routeName, ModalRoute.withName(routeName));
    });
  }

  Widget scale([double scale = 1.1]) => WidgetScaler(this, scale);

  Widget moveY([double translate = 5]) =>
      WidgetMover(this, translate, Axis.vertical);

  Widget moveX([double translate = 5]) =>
      WidgetMover(this, translate, Axis.horizontal);
}
