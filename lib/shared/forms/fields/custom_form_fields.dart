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
      Row(children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 5, 0),
          child: OutlinedButton(
            onPressed: () => controller.clear(),
            child: const Text('None'),
          ),
        ),
        if (last != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
            child: OutlinedButton(
              onPressed: () {
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
            padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
            child: OutlinedButton(
              onPressed: () {
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
      ]);

  static intField(
      {required TextEditingController controller,
      required String label,
      bool autofocus = false,
      List<int>? selectableValues}) {
    onOperationButtonClick(int num) {
      int? currentValue = int.tryParse(controller.text) ?? 0;
      String newValue = (currentValue + num).toString();

      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newValue.length),
        ),
      );
    }

    onSelectableValueButtonClick(int num) {
      String newValue = num.toString();

      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newValue.length),
        ),
      );
    }

    getArrowButtons() => [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: OutlinedButton(
              onPressed: () => onOperationButtonClick(-1),
              child: const Icon(Icons.remove_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: OutlinedButton(
              onPressed: () => onOperationButtonClick(1),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ];

    getSelectableValueButtons() => selectableValues!
        .map((sv) => Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: OutlinedButton(
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
      const Padding(padding: EdgeInsets.all(5)),
      ...(selectableValues == null ? getArrowButtons() : getSelectableValueButtons())
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
