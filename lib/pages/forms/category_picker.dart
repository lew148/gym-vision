import 'package:flutter/material.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class CateogryPicker extends StatefulWidget {
  final List<Category>? selectedCategories;
  final void Function(List<Category> c) onChange;
  final bool includeMiscCategories;

  const CateogryPicker({
    super.key,
    this.selectedCategories = const [],
    required this.onChange,
    this.includeMiscCategories = true,
  });

  @override
  State<CateogryPicker> createState() => _CateogryPickerState();
}

class _CateogryPickerState extends State<CateogryPicker> {
  late List<Category> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories ?? [];
  }

  Widget getCategoryDisplay(Category category) => GestureDetector(
        onTap: () => setState(() {
          selectedCategories.contains(category)
              ? selectedCategories.remove(category)
              : selectedCategories.add(category);
        }),
        child: CommonUI.getCard(
          context,
          CommonUI.getSelectedContainer(
            context,
            child: Text(category.displayName),
            selected: selectedCategories.contains(category),
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
              CommonUI.getDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.split2Categories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              CommonUI.getDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.muscleGroupCategories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              if (widget.includeMiscCategories) ...[
                CommonUI.getDivider(),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: SplitHelper.miscCategories.map((c) => getCategoryDisplay(c)).toList(),
                ),
              ],
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonUI.getTextButton(ButtonDetails(
                  text: 'Clear',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onChange([]);
                  },
                )),
                CommonUI.getTextButton(ButtonDetails(
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
