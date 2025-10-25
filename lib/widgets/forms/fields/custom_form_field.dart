import 'package:flutter/material.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final String? suffix;
  final bool canBeBlank;
  final bool autofocus;
  final List<Button>? buttons;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final IconData? prefixIcon;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.suffix,
    this.autofocus = false,
    this.buttons,
    this.keyboardType,
    this.canBeBlank = true,
    this.maxLength,
    this.maxLines,
    this.prefixIcon,
  });

  factory CustomFormField.string({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    String? unit,
    bool autofocus = false,
    bool canBeBlank = true,
    List<Button>? buttons,
    int? maxLength,
    IconData prefixIcon = Icons.abc_rounded,
  }) =>
      CustomFormField(
        controller: controller,
        label: label,
        validator: validator,
        suffix: unit,
        autofocus: autofocus,
        canBeBlank: canBeBlank,
        buttons: buttons,
        prefixIcon: prefixIcon,
      );

  factory CustomFormField.textArea({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    String? unit,
    bool autofocus = false,
    bool canBeBlank = true,
    List<Button>? buttons,
    int? maxLength,
    int maxLines = 2,
    IconData prefixIcon = Icons.abc_rounded,
  }) =>
      CustomFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: maxLines,
        label: label,
        validator: validator,
        suffix: unit,
        autofocus: autofocus,
        canBeBlank: canBeBlank,
        buttons: buttons,
        prefixIcon: prefixIcon,
      );

  factory CustomFormField.int({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    String? unit,
    bool autofocus = false,
    bool canBeBlank = true,
    List<Button>? buttons,
    IconData prefixIcon = Icons.numbers_rounded,
  }) =>
      CustomFormField(
        controller: controller,
        label: label,
        keyboardType: const TextInputType.numberWithOptions(),
        validator: validator,
        suffix: unit,
        autofocus: autofocus,
        canBeBlank: canBeBlank,
        buttons: buttons,
        prefixIcon: prefixIcon,
      );

  factory CustomFormField.double({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    String? unit,
    bool autofocus = false,
    bool canBeBlank = true,
    List<Button>? buttons,
    IconData prefixIcon = Icons.numbers_rounded,
  }) =>
      CustomFormField(
        controller: controller,
        label: label,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: validator,
        suffix: unit,
        autofocus: autofocus,
        canBeBlank: canBeBlank,
        buttons: buttons,
        prefixIcon: prefixIcon,
      );

  static const Color errorColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    OutlineInputBorder getBorder({bool errored = false}) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: errored ? errorColor : colorScheme.shadow, width: 1.5),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: (String? s) {
                if (!canBeBlank && (s == null || s.isEmpty)) return '$label cannot be blank';
                if (validator != null) validator!(s);
                return null;
              },
              keyboardType: keyboardType,
              cursorErrorColor: errorColor,
              // obscureText: true, // for passwords
              autofocus: autofocus,
              maxLength: maxLength,
              maxLines: maxLines,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: colorScheme.secondary),
                filled: true,
                fillColor: colorScheme.surface,
                labelText: label,
                labelStyle: TextStyle(color: colorScheme.secondary),
                errorStyle: const TextStyle(color: errorColor, fontSize: 10, fontWeight: FontWeight.w500),
                suffixText: suffix,
                suffixStyle: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.all(10),
                enabledBorder: getBorder(),
                focusedBorder: getBorder(),
                errorBorder: getBorder(errored: true),
                focusedErrorBorder: getBorder(errored: true),
              ),
            ),
          ),
          buttons == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsetsGeometry.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: buttons!
                        .map((b) => Padding(padding: const EdgeInsetsGeometry.symmetric(horizontal: 5), child: b))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
