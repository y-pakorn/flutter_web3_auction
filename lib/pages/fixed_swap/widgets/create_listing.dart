import 'package:flutter/material.dart';
import 'package:typeweight/typeweight.dart';
import 'package:niku/niku.dart';
import '../../../utils.dart';

class CreateListing extends StatefulWidget {
  final String textToDisplay;
  final IconData? icon;
  final Color? color;
  final Color? bgColor;
  final EdgeInsets padding;
  final double fontSize;

  const CreateListing({
    Key? key,
    required this.textToDisplay,
    this.padding = roundedBoxPadding,
    this.fontSize = 16,
    this.color,
    this.bgColor,
    this.icon,
  }) : super(key: key);

  @override
  _CreateListingState createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListing> {
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
          '${widget.textToDisplay}'
              .text(TypeWeight.extraBold)
              .fontSize(widget.fontSize)
              .color(
                widget.color != null
                    ? widget.color!
                    : isHovering
                        ? kBlack
                        : kWhite,
              ),
          if (widget.icon != null) ...[
            Niku().width(5),
            Icon(
              widget.icon,
              size: widget.fontSize + 2,
              color: widget.color != null
                  ? widget.color!
                  : isHovering
                      ? kBlack
                      : kWhite,
            )
          ],
        ]
            .row
            .crossCenter()
            .mainCenter()
            .mainSize(MainAxisSize.min)
            .niku()
            //.center()
            .padding(widget.padding)
            .boxDecoration(
              roundedBoxDeco.copyWith(
                color: widget.color != null
                    ? widget.bgColor ?? kBlack
                    : isHovering
                        ? widget.bgColor
                        : kBlack,
                border: widget.color != null && widget.bgColor != null
                    ? Border.all(style: BorderStyle.none)
                    : null,
              ),
            ));
  }
}
