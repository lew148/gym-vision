import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/globals.dart';

stringValidator(value, canBeBlank, label) =>
    !canBeBlank && (value == null || value == '') ? '$label cannot be blank' : null;

class CustomFormFields {
  static stringField({
    required TextEditingController controller,
    required String label,
    bool autofocus = false,
    bool canBeBlank = false,
    int? maxLength,
  }) =>
      TextFormField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        maxLength: maxLength,
        validator: (v) => stringValidator(v, canBeBlank, label),
      );

  static textArea({
    required TextEditingController controller,
    required String label,
    bool autofocus = false,
    bool canBeBlank = false,
  }) =>
      TextFormField(
        controller: controller,
        // textInputAction: TextInputAction.go,
        autofocus: autofocus,
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        decoration: InputDecoration(labelText: label),
        validator: (v) => stringValidator(v, canBeBlank, label),
      );

  static doubleField({
    required TextEditingController controller,
    required String label,
    required String unit,
    String? last,
    String? max,
    bool autofocus = false,
    bool hideNone = false,
  }) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
            autofocus: autofocus,
            decoration: InputDecoration(
              labelText: label,
              suffix: Text(unit),
            ),
            validator: (value) =>
                value != null && value != '' && stringToDouble(value) == null ? 'Please enter a valid weight' : null,
          ),
        ),
        Row(children: [
          if (!hideNone)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: TextButton(
                onPressed: () => controller.clear(),
                child: const Text('None'),
              ),
            ),
          if (last != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (last == '0') {
                    controller.clear();
                    return;
                  }

                  controller.value = TextEditingValue(
                    text: last,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: last.length),
                    ),
                  );
                },
                child: const Text('Last'),
              ),
            ),
          if (max != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (max == '0') {
                    controller.clear();
                    return;
                  }

                  controller.value = TextEditingValue(
                    text: max,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: max.length),
                    ),
                  );
                },
                child: const Text('Max'),
              ),
            ),
        ]),
      ]);

  static intField({
    required TextEditingController controller,
    required String label,
    String unit = '',
    bool autofocus = false,
    List<int>? selectableValues,
    bool showNone = false,
    bool canBeBlank = true,
  }) {
    onSelectableValueButtonClick(int num) {
      String newValue = num.toString();

      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newValue.length),
        ),
      );
    }

    getSelectableValueButtons() => selectableValues!
        .map((sv) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () => onSelectableValueButtonClick(sv),
                child: Text(sv.toString()),
              ),
            ))
        .toList();

    getNoneButton() => Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: TextButton(
            onPressed: () => controller.clear(),
            child: const Text('None'),
          ),
        );

    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffix: Text(unit),
          ),
          validator: (value) => !canBeBlank && (value == null || value == '') ? '' : null,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
      if (showNone) getNoneButton(),
      if (selectableValues != null && selectableValues.isNotEmpty) ...getSelectableValueButtons()
    ]);
  }

  static checkbox(
    BuildContext context,
    bool value,
    Function(bool?) onChange,
  ) =>
      Checkbox(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        checkColor: Theme.of(context).colorScheme.surface,
        activeColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.shadow, width: 1.5),
        value: value,
        shape: const CircleBorder(),
        onChanged: onChange,
      );

  static checkboxWithLabel(
    BuildContext context,
    String label,
    bool value,
    Function(bool?) onChange,
  ) =>
      FormField(
        builder: (field) => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: value,
          onChanged: onChange,
          side: BorderSide(color: Theme.of(context).colorScheme.shadow, width: 1.5),
          activeColor: Theme.of(context).colorScheme.primary,
          checkColor: Theme.of(context).colorScheme.surface,
          checkboxShape: const CircleBorder(),
        ),
      );

  static durationField(
    String label,
    BuildContext context,
    Duration duration,
    void Function(Duration newDuration) onChanged,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.shadow),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              showCupertinoModalPopup<void>(
                context: context,
                builder: (BuildContext context) => Container(
                  height: 216,
                  padding: const EdgeInsets.only(top: 6.0),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  child: SafeArea(
                    top: false,
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hms,
                      initialTimerDuration: duration,
                      onTimerDurationChanged: onChanged,
                    ),
                  ),
                ),
              );
            },
            child: Text(
              duration.toString().split('.').first.padLeft(8, "0"),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      );
}
