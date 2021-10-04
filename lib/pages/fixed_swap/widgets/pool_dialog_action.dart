import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niku/niku.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:typeweight/typeweight.dart';

import '../../../utils.dart';

class PoolDialogAction extends StatefulWidget {
  final String textToDisplay;
  final String loadingText;
  final String doneText;

  final bool isEnabled;
  final bool isLoading;
  final bool isDone;

  final void Function() onTap;

  const PoolDialogAction({
    required this.loadingText,
    required this.doneText,
    required this.textToDisplay,
    required this.isEnabled,
    required this.isDone,
    required this.isLoading,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  PoolDialogActionState createState() => PoolDialogActionState();
}

class PoolDialogActionState extends State<PoolDialogAction> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (p) => setState(() {
        isHovering = true;
      }),
      onExit: (p) => setState(() {
        isHovering = false;
      }),
      child: [
        (widget.isDone
                ? widget.doneText
                : widget.isLoading
                    ? widget.loadingText
                    : widget.textToDisplay)
            .text(TypeWeight.extraBold)
            .fontSize(18)
            .color(!widget.isEnabled
                ? kDarkGrey
                : isHovering || widget.isLoading || widget.isDone
                    ? kBlack
                    : kWhite),
        if (widget.isDone) ...[
          Niku().width(10),
          Icon(
            CupertinoIcons.checkmark_seal,
            color: !widget.isEnabled
                ? kDarkGrey
                : isHovering || widget.isLoading || widget.isDone
                    ? kBlack
                    : kWhite,
          )
        ] else if (widget.isLoading) ...[
          Niku().width(10),
          JumpingText(
            '...',
            end: Offset(0, -0.2),
            style: TextStyle(
                fontWeight: TypeWeight.black, fontSize: 22, color: kBlack),
          ).niku().height(25),
        ]
      ]
          .row
          .crossCenter()
          //.center()
          .mainCenter()
          //.spacing(10)
          //.runSpacing(10)
          .niku()
          .center()
          .width(300)
          .padding(EdgeInsets.symmetric(horizontal: 15, vertical: 10))
          .boxDecoration(
            roundedBoxDeco.copyWith(
              color: !widget.isEnabled
                  ? Colors.grey.shade300
                  : isHovering || widget.isLoading || widget.isDone
                      ? kWhite
                      : kBlack,
              border: !widget.isEnabled
                  ? Border.all(style: BorderStyle.none)
                  : null,
            ),
          )
          .margin(EdgeInsets.all(5))
          .onTap(widget.isEnabled && !(widget.isLoading || widget.isDone)
              ? widget.onTap
              : null),
    );
  }
}
