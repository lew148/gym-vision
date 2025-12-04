import 'package:flutter/material.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';

class CategoryPicker extends StatefulWidget {
  final List<Category>? selectedCategories;
  final void Function(List<Category> c) onChange;
  final bool includeMiscCategories;

  const CategoryPicker({
    super.key,
    this.selectedCategories = const [],
    required this.onChange,
    this.includeMiscCategories = true,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
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
        child: CustomCard(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
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
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Column(children: [
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.splitCategories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              const CustomDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.split2Categories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              const CustomDivider(),
              Wrap(
                alignment: WrapAlignment.center,
                children: SplitHelper.muscleGroupCategories.map((c) => getCategoryDisplay(c)).toList(),
              ),
              if (widget.includeMiscCategories) ...[
                const CustomDivider(),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: SplitHelper.miscCategories.map((c) => getCategoryDisplay(c)).toList(),
                ),
              ],
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button.clear(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onChange([]);
                  },
                ),
                Button.submit(onTap: () {
                  Navigator.pop(context);
                  widget.onChange(selectedCategories);
                }),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}
