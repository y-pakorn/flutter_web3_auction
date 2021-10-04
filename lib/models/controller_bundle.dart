import 'package:flutter/material.dart';

class ControllerBundle {
  TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();

  String? errorText;
  String? Function(String? value) validator;
  void Function()? extraFunction;

  bool get tokenIsError => errorText != null;

  String get text => textController.text.trim();

  void changeTextControllerValue(dynamic value) {
    textController.value = TextEditingValue(
        text: value.toString(),
        selection: TextSelection.collapsed(offset: value.toString().length));
  }

  String? tokenValidator(String? val) {
    if (val == null || val.isEmpty) return 'empty address';
    if (val.length != 42) return 'address length != 42';
    if (!val.startsWith('0x')) return 'address prefix is not 0x';
    if (!val.startsWith(RegExp(r'[a-zA-Z0-9]{42}')))
      return 'address contains special character';
    return null;
  }

  void clear() {
    textController.clear();
    focusNode.unfocus();
    errorText = null;
  }

  bool validate() {
    errorText = validator(text);
    return !tokenIsError;
  }

  ControllerBundle({required this.validator, this.extraFunction});
}
