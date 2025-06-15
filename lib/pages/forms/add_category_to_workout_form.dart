import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class CateogryPickerModal extends StatefulWidget {
  final List<Category> selectedCategories;
  final void Function(List<Category> c) onChange;

  const CateogryPickerModal({
    super.key,
    required this.selectedCategories,
    required this.onChange,
  });

  @override
  State<CateogryPickerModal> createState() => _CateogryPickerModalState();
}

class _CateogryPickerModalState extends State<CateogryPickerModal> {
  late List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories;
  }

  Widget getCategoryDisplay(Category category) => GestureDetector(
        onTap: () => setState(() {
          selectedCategories.contains(category)
              ? selectedCategories.remove(category)
              : selectedCategories.add(category);
        }),
        child: CommonUI.getCard(
          context,
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                width: 2,
                color:
                    selectedCategories.contains(category) ? Theme.of(context).colorScheme.primary : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(category.displayName),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonUI.getSectionTitleWithCloseButton(context, 'Categories'),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Column(children: [
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.splitCategories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              CommonUI.getDefaultDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.split2Categories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              CommonUI.getDefaultDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.muscleGroupCategories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              CommonUI.getDefaultDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.miscCategories.map((c) => getCategoryDisplay(c)).toList(),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonUI.getPrimaryButton(ButtonDetails(
                  text: 'Clear',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onChange([]);
                  },
                )),
                CommonUI.getPrimaryButton(ButtonDetails(
                  text: 'Save',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onChange(selectedCategories);
                  },
                )),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}
