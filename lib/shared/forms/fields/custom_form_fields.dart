import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormFields {
  static stringField({
    required TextEditingController controller,
    required String label,
    bool autofocus = false,
    bool canBeBlank = false,
  }) =>
      TextFormField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        validator: (value) => !canBeBlank && (value == null || value == '') ? '$label cannot be blank' : null,
      );

  static weightField({
    required TextEditingController controller,
    required String label,
    bool isSingle = true,
    bool autofocus = false,
    String? last,
    String? max,
  }) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
            autofocus: autofocus,
            decoration: InputDecoration(
              labelText: label,
              prefix: isSingle ? const Text('') : const Text('2 x '),
              suffix: const Text('kg'),
            ),
            validator: (value) =>
                value != null && value != '' && double.tryParse(value) == null ? 'Please enter a valid weight' : null,
          ),
        ),
        Row(children: [
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

  static intField(
      {required TextEditingController controller,
      required String label,
      bool autofocus = false,
      List<int>? selectableValues}) {
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

    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
          decoration: InputDecoration(labelText: label),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
      ...getSelectableValueButtons()
    ]);
  }

  static checkbox(
    BuildContext context,
    String label,
    bool value,
    Function(bool?) onChange,
  ) =>
      FormField(
        builder: (field) => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.shadow),
          ),
          value: value,
          onChanged: onChange,
          activeColor: Theme.of(context).colorScheme.primary,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      );
}
