import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apidash/consts.dart';
import 'package:json_text_field/json_text_field.dart';

class TextFieldEditor extends StatefulWidget {
  const TextFieldEditor({
    super.key,
    required this.fieldKey,
    this.onChanged,
    this.initialValue,
    this.contentType,
  });

  final String fieldKey;
  final Function(String)? onChanged;
  final String? initialValue;
  final ContentType? contentType;
  @override
  State<TextFieldEditor> createState() => _TextFieldEditorState();
}

class _TextFieldEditorState extends State<TextFieldEditor> {
  final JsonTextFieldController controller = JsonTextFieldController();
  late final FocusNode editorFocusNode;
  String? error;

  void insertTab() {
    String sp = "  ";
    int offset = math.min(
        controller.selection.baseOffset, controller.selection.extentOffset);
    String text = controller.text.substring(0, offset) +
        sp +
        controller.text.substring(offset);
    controller.value = TextEditingValue(
      text: text,
      selection: controller.selection.copyWith(
        baseOffset: controller.selection.baseOffset + sp.length,
        extentOffset: controller.selection.extentOffset + sp.length,
      ),
    );
    widget.onChanged?.call(text);
  }

  @override
  void initState() {
    super.initState();
    if (widget.contentType == ContentType.json) {
      controller.formatJson(sortJson: false);
    }
    editorFocusNode = FocusNode(debugLabel: "Editor Focus Node");
  }

  @override
  void dispose() {
    editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialValue != null) {
      controller.text = widget.initialValue!;
    }
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.tab): () {
          insertTab();
        },
      },
      child: widget.contentType == ContentType.json
          ? _buildJsonTextField(
              context: context,
              codeTheme: Theme.of(context).brightness == Brightness.light
                  ? kLightCodeTheme
                  : kDarkCodeTheme)
          : _buildTextFormField(context),
    );
  }

  TextFormField _buildTextFormField(BuildContext context) {
    return TextFormField(
        key: Key(widget.fieldKey),
        controller: controller,
        focusNode: editorFocusNode,
        keyboardType: TextInputType.multiline,
        expands: true,
        maxLines: null,
        style: kCodeStyle,
        textAlignVertical: TextAlignVertical.top,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: "Enter content (body)",
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.outline.withOpacity(
                  kHintOpacity,
                ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kBorderRadius8,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(
                    kHintOpacity,
                  ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kBorderRadius8,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          filled: true,
          hoverColor: kColorTransparent,
          fillColor: Color.alphaBlend(
              (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.primaryContainer)
                  .withOpacity(kForegroundOpacity),
              Theme.of(context).colorScheme.surface),
        ));
  }

  Widget _buildJsonTextField(
      {required BuildContext context,
      required Map<String, TextStyle> codeTheme}) {
    var codeTheme = Theme.of(context).brightness == Brightness.light
        ? kLightCodeTheme
        : kDarkCodeTheme;

    Key key = Theme.of(context).brightness == Brightness.light
        ? Key("${widget.fieldKey}light")
        : Key("${widget.fieldKey}dark");

    return Stack(
      children: [
        JsonTextField(
          cursorHeight: 26,
          stringHighlightStyle: kCodeStyle.copyWith(
            color: codeTheme['string']?.color,
            fontSize: 16.7,
            height: 1.5,
          ),
          keyHighlightStyle: kCodeStyle.copyWith(
              color: codeTheme['keyword']?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16.7,
              height: 1.5),
          numberHighlightStyle: kCodeStyle.copyWith(
            color: codeTheme['number']?.color,
            fontSize: 16.7,
            height: 1.5,
          ),
          boolHighlightStyle: kCodeStyle.copyWith(
              color: codeTheme['boolean']?.color, fontSize: 16.7, height: 1.5),
          nullHighlightStyle: kCodeStyle.copyWith(
              color: codeTheme['boolean']?.color, fontSize: 16.7, height: 1.5),
          specialCharHighlightStyle: kCodeStyle.copyWith(
              color: codeTheme['subst']?.color, fontSize: 16.7, height: 1.5),
          commonTextStyle: kCodeStyle.copyWith(
              color: codeTheme['subst']?.color, fontSize: 16.7, height: 1.5),
          onError: (error) {},
          showErrorMessage: false,
          isFormatting: true,
          key: Key(codeTheme.toString()),
          controller: controller,
          focusNode: editorFocusNode,
          keyboardType: TextInputType.multiline,
          expands: true,
          maxLines: null,
          style: kCodeStyle.copyWith(
            height: 1.5,
            fontSize: 16.7,
          ),
          textAlignVertical: TextAlignVertical.top,
          onChanged: (value) {
            widget.onChanged?.call(value);
            if (widget.contentType == ContentType.json) {
              controller.formatJson(sortJson: false);
            }
          },
          decoration: InputDecoration(
            hintText: "Enter content (body)",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.outline.withOpacity(
                    kHintOpacity,
                  ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: kBorderRadius8,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                      kHintOpacity,
                    ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: kBorderRadius8,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            filled: true,
            hoverColor: kColorTransparent,
            fillColor: Color.alphaBlend(
                (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.primaryContainer)
                    .withOpacity(kForegroundOpacity),
                Theme.of(context).colorScheme.surface),
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: error != null ? 1 : 0,
            child: FloatingActionButton(
                tooltip: error,
                onPressed: null,
                child: Icon(
                  Icons.error,
                  color: Theme.of(context).brightness == Brightness.light
                      ? kColorLightDanger
                      : kColorDarkDanger,
                )),
          ),
        )
      ],
    );
  }
}
