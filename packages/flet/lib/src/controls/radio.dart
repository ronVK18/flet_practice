import 'package:flutter/material.dart';

import '../flet_control_backend.dart';
import '../models/control.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import 'create_control.dart';
import 'cupertino_radio.dart';
import 'error.dart';
import 'flet_store_mixin.dart';
import 'list_tile.dart';

enum LabelPosition { right, left }

class RadioControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final bool parentDisabled;
  final bool? parentAdaptive;
  final FletControlBackend backend;

  const RadioControl(
      {super.key,
      this.parent,
      required this.control,
      required this.parentDisabled,
      required this.parentAdaptive,
      required this.backend});

  @override
  State<RadioControl> createState() => _RadioControlState();
}

class _RadioControlState extends State<RadioControl> with FletStoreMixin {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    widget.backend.triggerControlEvent(
        widget.control.id, _focusNode.hasFocus ? "focus" : "blur");
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChange(String ancestorId, String? value) {
    var svalue = value ?? "";
    debugPrint(svalue);
    widget.backend.updateControlState(ancestorId, {"value": svalue});
    widget.backend.triggerControlEvent(ancestorId, "change", svalue);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Radio build: ${widget.control.id}");

    return withPagePlatform((context, platform) {
      bool? adaptive =
          widget.control.attrBool("adaptive") ?? widget.parentAdaptive;
      if (adaptive == true &&
          (platform == TargetPlatform.iOS ||
              platform == TargetPlatform.macOS)) {
        return CupertinoRadioControl(
            control: widget.control,
            parentDisabled: widget.parentDisabled,
            backend: widget.backend);
      }

      String label = widget.control.attrString("label", "")!;
      String value = widget.control.attrString("value", "")!;
      LabelPosition labelPosition = LabelPosition.values.firstWhere(
          (p) =>
              p.name.toLowerCase() ==
              widget.control.attrString("labelPosition", "")!.toLowerCase(),
          orElse: () => LabelPosition.right);
      bool autofocus = widget.control.attrBool("autofocus", false)!;
      bool disabled = widget.control.isDisabled || widget.parentDisabled;

      TextStyle? labelStyle =
          parseTextStyle(Theme.of(context), widget.control, "labelStyle");
      if (disabled && labelStyle != null) {
        labelStyle = labelStyle.apply(color: Theme.of(context).disabledColor);
      }

      return withControlAncestor(widget.control.id, "radiogroup",
          (context, viewModel) {
        debugPrint("Radio StoreConnector build: ${widget.control.id}");

        if (viewModel.ancestor == null) {
          return const ErrorControl(
              "Radio control must be enclosed with RadioGroup.");
        }

        String groupValue = viewModel.ancestor!.attrString("value", "")!;
        String ancestorId = viewModel.ancestor!.id;

        var radio = Radio<String>(
            autofocus: autofocus,
            focusNode: _focusNode,
            groupValue: groupValue,
            value: value,
            activeColor: HexColor.fromString(Theme.of(context),
                widget.control.attrString("activeColor", "")!),
            fillColor: parseMaterialStateColor(
                Theme.of(context), widget.control, "fillColor"),
            onChanged: !disabled
                ? (String? value) {
                    _onChange(ancestorId, value);
                  }
                : null);

        ListTileClicks.of(context)?.notifier.addListener(() {
          _onChange(ancestorId, value);
        });

        Widget result = radio;
        if (label != "") {
          var labelWidget = disabled
              ? Text(label, style: labelStyle)
              : MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(label, style: labelStyle));
          result = MergeSemantics(
              child: GestureDetector(
                  onTap: !disabled
                      ? () {
                          _onChange(ancestorId, value);
                        }
                      : null,
                  child: labelPosition == LabelPosition.right
                      ? Row(children: [radio, labelWidget])
                      : Row(children: [labelWidget, radio])));
        }

        return constrainedControl(
            context, result, widget.parent, widget.control);
      });
    });
  }
}
